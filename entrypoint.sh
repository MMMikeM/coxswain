htpasswd -cb .htpasswd "admin" "camamy"
touch current_version.txt
ruby api/initial_config_generator.rb
rackup -p 3000 -o 0.0.0.0

