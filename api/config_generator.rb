class ConfigGenerator
  def initialize(config_file_name, servers, upstreams)
    @config_file_name = config_file_name
    @servers = servers
    @upstreams = upstreams
  end

  def generate
    new_config = @servers.map do |server_config|
      convert_to_basic_nginx_config(server_config)
    end

    current_version = File.read('current_version.txt').strip.to_i
    new_version = current_version + 1

    new_config << base_config
		joined_config = new_config.join("\n#---\n")
    joined_upstreams = converted_upstreams.join("\n#---\n")
    new_config = [joined_config, joined_upstreams].compact.join("\n#---\n")
    File.write("versions/#{new_version}", new_config)
    File.write(@config_file_name, new_config)
    File.write('current_version.txt', new_version.to_s)
  end

  def base_config
    config = [
      "server {",
      "  listen 80;",
      "  listen [::]:80;",
      "  server_name localhost;",
      "  client_max_body_size 0;",
      "  location / {",
      "    root                /var/www/root/html;",
      "    proxy_set_header    Host                $http_host;",
      "    proxy_set_header    X-Real-IP           $remote_addr;",
      "    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;",
      "    proxy_set_header    Upgrade             $http_upgrade;",
      "    proxy_set_header    Connection          'Upgrade';",
      "  }",
      "  location /api/v1/ {",
      "    proxy_pass          http://127.0.0.1:3000;",
      "    proxy_set_header    Host                $http_host;",
      "    proxy_set_header    X-Real-IP           $remote_addr;",
      "    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;",
      "    proxy_set_header    Upgrade             $http_upgrade;",
      "    proxy_set_header    Connection          'Upgrade';",
      "  }",
      "}\n"
    ].compact.join("\n")
  end

  def converted_upstreams
    return [] if @upstreams.nil?

    @upstreams.map do |upstream|
      convert_to_upstream_nginx_config(upstream)
    end
  end

  def rollback
    current_version = File.read('current_version.txt').strip.to_i
    version = current_version.to_i
    version = current_version.to_i - 1 if current_version != 0
    config = File.read("versions/#{version}")

    File.write(@config_file_name, config)
    File.write('current_version.txt', version.to_s)
  end

  private

  def convert_to_upstream_nginx_config(upstream)
    config = [
      "upstream #{upstream['name']} {",
      "",
      "}",
    ]

    config[1] = upstream['hosts'].map do |host|
      "  server #{host['name']}:#{host['port']} weight=#{host['weight']};"
    end

    config.join("\n")
  end

  def proxy_pass(config)
    if config['root']
      ""
    else
      "    proxy_pass #{config['url']}"
    end
  end

  def convert_to_basic_nginx_config(config)
    ssl_certificate = config['ssl_certificate'] || ENV['SSL_CERTIFICATE']
    ssl_certificate_key = config['ssl_certificate_key'] || ENV['SSL_CERTIFICATE_KEY']
    url = "http://#{config['host']};"

    if config['port']
      url = "http://#{config['host']}:#{config['port']};"
    end

    ssl_cert = ""
    listen = "  listen #{config['exposed_port']};"
    if config['ssl_certificate']
      ssl_cert = [
        "  ssl_certificate #{ssl_certificate};",
        "  ssl_certificate_key #{ssl_certificate_key};",
      ].join("\n")
      listen = "  listen #{config['exposed_port']} ssl;"
    end

    basic_auth = ""
    if config["basic_auth"]
      basic_auth = [
        "  auth_basic \"#{config["basic_auth"]["message"]}\";",
        "  auth_basic_user_file /app/.htpasswd;"
      ].join("\n")
    end

    root = ""
    if config["root"]
      root = "  root #{config['root']};";
    end

    config = [
      "server {",
      listen,
      "  listen [::]:#{config['exposed_port']};",
      "  server_name #{config['url']};",
      root,
      ssl_cert,
      basic_auth,
      "  client_max_body_size 0;",
      "  location / {",
      proxy_pass(config),
      "    proxy_set_header    Host                $http_host;",
      "    proxy_set_header    X-Real-IP           $remote_addr;",
      "    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;",
      "    proxy_set_header    Upgrade             $http_upgrade;",
      "    proxy_set_header    Connection          'Upgrade';",
      "  }",
      "}\n"
    ].compact.join("\n")
  end
end
