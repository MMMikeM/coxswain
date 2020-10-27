build:
	docker-compose -f docker-compose.yml build

test:
	docker-compose -f docker-compose.yml run --rm nginx rspec spec/server_spec.rb
