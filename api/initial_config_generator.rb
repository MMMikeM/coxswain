require_relative 'config_generator'

class InitialConfigGenerator
  def self.run
    File.open("current_version.txt","w") do |f|
      f.write("0")
      f.close
    end

    config_file_name = "#{ENV['CONFIG_FILE_NAME']}"

    unless File.file?(config_file_name)
      servers = [
        {
          "type" => "forward",
          "url" => ENV['PROXY_URL'],
          "host" => ENV['PROXY_DOCKER_CONTAINER_NAME'],
          "port" => ENV['PROXY_DOCKER_CONTAINER_PORT']
        }
      ]

      ConfigGenerator.new(config_file_name, servers, []).generate
    end

    FileUtils.cp(config_file_name, "versions/0")
  end
end

InitialConfigGenerator.run
