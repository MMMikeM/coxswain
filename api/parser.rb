class ConfigParser
  def initialize(file_name)
    @file_name = file_name
  end

  def parse
    blocks = File.read(@file_name).split("\n#---\n")
    servers = []
    upstreams = []

    blocks.each do |block|
      server = parse_server(block) if block.start_with?("server")
      upstream = parse_upstream(block) if block.start_with?("upstream")
      servers << server if server
      upstreams << upstream if upstream
    end

    [servers, upstreams]
  end

  def parse_server(block)
    url_regex = /.*server_name\s(?<url>.*)\;/
    host_regex = /.*proxy_pass\shttp\:\/\/(.*)\;/
    ssl_cert_regex = /.*ssl_certificate\s(.*)\;/
    ssl_cert_key_regex = /.*ssl_certificate_key\s(.*)\;/
    listen_regex = /.*listen\s\[::\]:(.*)\;/
    basic_auth_regex = /.*auth_basic\s\"(.*)\"\;/

    lines = block.split("\n")
    server = {}
    lines.each do |line|
      server[:url] = line.match(url_regex)[1] if line.match?(url_regex)
      server[:host] = line.match(host_regex)[1].split(":")[0] if line.match?(host_regex)
      server[:port] = line.match(host_regex)[1].split(":")[1] if line.match?(host_regex)
      server[:exposed_port] = line.match(listen_regex)[1].strip if line.match?(listen_regex)
      server[:ssl_certificate] = line.match(ssl_cert_regex)[1] if line.match?(ssl_cert_regex)
      server[:ssl_certificate_key] = line.match(ssl_cert_key_regex)[1] if line.match?(ssl_cert_key_regex)
      if line.match?(basic_auth_regex)
        message = line.match(basic_auth_regex)[1]
        server[:basic_auth] = {}
        server[:basic_auth][:message] = message
      end
    end

    return server
  end

  def parse_upstream(block)
    name_regex = /.*upstream\s(.*)\s\{/
    host_regex = /.*server\s(.*)\:(.*)\sweight=(.*)\;/
    lines = block.split("\n")
    upstream = {}
    lines.each do |line|
      upstream[:name] = line.match(name_regex)[1] if line.match?(name_regex)
    end

    upstream[:hosts] = []
    lines.each do |line|
      if line.match?(host_regex)
        host = {}
        host[:name] = line.match(host_regex)[1] if line.match?(host_regex)
        host[:port] = line.match(host_regex)[2] if line.match?(host_regex)
        host[:weight] = line.match(host_regex)[3] if line.match?(host_regex)
        upstream[:hosts] << host
      end
    end

    return upstream
  end
end
