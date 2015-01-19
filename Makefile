build:
	docker build -t applicaster/haproxy-reloadable .

release: build
	docker push applicaster/haproxy-reloadable

test: build
	./test.sh

