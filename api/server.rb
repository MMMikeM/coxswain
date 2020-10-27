require 'sinatra/base'
require 'json'
require 'pry'
require 'sinatra/cross_origin'
require_relative 'parser'
require_relative 'config_generator'

CONFIG_FILE_NAME="/etc/nginx/conf.d/#{ENV['CONFIG_FILE_NAME']}"

def authenticate(auth_token)
  token = ENV['TOKEN']
  halt 401 if token != auth_token
end

def render_current_config
  servers, upstreams = ConfigParser.new(CONFIG_FILE_NAME).parse
  {
    version: File.read('current_version.txt').to_i,
    servers: servers,
    upstreams: upstreams
  }.to_json
end

def update_nginx_config(config, upstreams)
  ConfigGenerator.new(CONFIG_FILE_NAME, config, upstreams).generate
  ConfigParser.new(CONFIG_FILE_NAME).parse.to_json
end

class SinatraApp < Sinatra::Base
  set :bind, '0.0.0.0'
  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end
  
  get '/' do
    'OK'
  end

  get '/nginx/start' do
    content_type :json
    authenticate(params[:token])
    response = `service nginx start`
    {
      action: 'starting',
      console: response
    }.to_json
  end

  get '/nginx/stop' do
    content_type :json
    authenticate(params[:token])
    response = `service nginx stop`
    {
      action: 'stopping',
      console: response
    }.to_json
  end

  get '/nginx/restart' do
    content_type :json
    authenticate(params[:token])
    response = `service nginx restart`
    {
      action: 'restarting',
      console: response
    }.to_json
  end

  get '/nginx/status' do
    content_type :json
    authenticate(params[:token])
    response = `service nginx status`

    if response == "nginx is running.\n"
      {
        console: response,
        status: 'running'
      }.to_json
    else
      {
        console: response,
        status: 'stopped'
      }.to_json
    end
  end

  get '/nginx/config' do
    content_type :json
    authenticate(params[:token])
    render_current_config
  end

  put '/nginx/config' do
    content_type :json
    authenticate(params[:token])
    parsed_body = JSON.parse(request.body.read)
    config = parsed_body["servers"]
    upstreams = parsed_body["upstreams"]
    update_nginx_config(config, upstreams)
    render_current_config
  end

  get '/nginx/rollback' do
    content_type :json
    authenticate(params[:token])
    ConfigGenerator.new(CONFIG_FILE_NAME, []).rollback
    render_current_config
  end

  get '/nginx/logs' do
    content_type :json
    authenticate(params[:token])
    logs = {}
    logs[:access] = File.read('/var/log/nginx/access.log').split("\n")
    logs[:errors] = File.read('/var/log/nginx/error.log').split("\n")
    logs.to_json
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  end
end

def process_error_log(log)
  dt = log.split(" ")[0] + " " + log.split(" ")[1]
  date_time = DateTime.parse(dt)
  {
    "type" => "error",
    "date_time" => date_time,
    "details" => log
  }
end

def process_access_log(log)
  det = JSON.parse(log)
  {
    "type" => "access",
    "date_time" => DateTime.parse(det["time_local"].split(":", 2).join(" ")),
    "details" => det
  }
end
