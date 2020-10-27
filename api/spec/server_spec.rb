require 'rspec'
require File.expand_path '../spec_helper.rb', __FILE__

describe 'Sinatra App' do
  def app
    SinatraApp.new
  end

  it "renders status check" do 
    get '/'
  
    expect(last_response.body).to include("OK")
  end

  context "when accessing protected routes" do
    context "and no token or a incorrect token is provided" do
      it "renders 401" do 
        get '/nginx/status'
      
        expect(last_response.status).to eq(401)
      end
      
      it "renders 401" do 
        get '/nginx/status?token=def'
      
        expect(last_response.status).to eq(401)
      end
    end

    context "and the correct token is provided" do
      it "renders 200" do 
        get '/nginx/status?token=abc'
      
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("nginx is not running ... failed!\n")
      end
    end

    context "and starting nginx" do
      it "starts nginx" do 
        get '/nginx/start?token=abc'
      
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("Starting nginx: nginx failed!\n")
      end
    end

    context "and stopping nginx" do
      it "starts nginx" do 
        get '/nginx/stop?token=abc'
      
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("Stopping nginx: nginx.\n")
      end
    end

    context "and restarting nginx" do
      it "restarts nginx" do 
        get '/nginx/restart?token=abc'
      
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("Restarting nginx: nginx failed!\n")
      end
    end

    context "and getting the current config" do
      it "returns the current config" do 
        InitialConfigGenerator.run

        get '/nginx/config?token=abc'
      
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("Restarting nginx: nginx failed!.\n")
      end
    end
  end
end