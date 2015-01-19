# HAProxy Reloadable

a HAProxy Docker container with easy reload interface.

Based on [docker-library/haproxy](https://github.com/docker-library/haproxy)

To reload the HAProxy configuration file (mounted using a volume) send a USR2
signal to the docker container.

For a live example see [test.sh](test.sh)

### Running the tests

To run the tests you need `boot2docker`.

In the project folder run: `make test`
