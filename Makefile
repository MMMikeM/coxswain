build:
	docker-compose -f docker-compose.yml build

console:
	docker-compose -f docker-compose-dev.yml exec coxswain ash

run:
	docker-compose -f docker-compose-dev.yml up

test:
	docker-compose -f docker-compose.yml run --rm nginx rspec spec/server_spec.rb
