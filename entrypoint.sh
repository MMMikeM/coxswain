#htpasswd -cb .htpasswd "admin" "camamy"
touch current_version.txt
rm /etc/nginx/conf.d/default.conf
ruby api/initial_config_generator.rb
nginx
rackup -p 3000 -o 0.0.0.0
