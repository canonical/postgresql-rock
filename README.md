# PostgreSQL Server rock
[![Release to GHCR][release-badge]][release-link]

This repository contains the packaging metadata for creating a rock of PostgreSQL built from
the official ubuntu PostgreSQL package from the Ubuntu repository.
For more information on rocks, visit the [rockcraft repository][repo-rockcraft].

## Building the rock
The steps outlined below are based on the assumption that you are building the rock with the latest LTS of Ubuntu.
If you are using another version of Ubuntu or another operating system, the process may be different.

### Clone Repository
```bash
git clone https://github.com/canonical/postgresql-rock.git
cd postgresql-rock
```

### Installing Prerequisites
```bash
sudo snap install rockcraft --classic --edge
sudo snap install docker
sudo snap install lxd
```

### Configuring Prerequisites
```bash
sudo usermod -aG docker $USER
sudo lxd init --auto
```

### Packing and Running the rock
```bash
VERSION=$(awk '/^version: /{gsub(/'"'"'/, "", $2); print $2;exit}' rockcraft.yaml)
rockcraft pack
sudo rockcraft.skopeo --insecure-policy copy oci-archive:postgres_${VERSION}_amd64.rock docker-daemon:${USER}/postgres:${VERSION}
docker run --rm -it -e POSTGRES_PASSWORD=myS3cr3tp@ss -p 3432:5432 --name mypostgres --volume pg-data:/var/lib/postgresql/ -d ${USER}/postgres:${VERSION}
```

### Connecting to PostgreSQL
From inside the container:
```bash
docker exec -it -e PGPASSWORD=myS3cr3tp@ss mypostgres psql -h 127.0.0.1 -p 5432 -U postgres -d postgres
```

From outside the container:
```bash
sudo apt install -y postgresql-client-*
PGPASSWORD=myS3cr3tp@ss psql -h 127.0.0.1 -p 3432 -U postgres -d postgres
```

Troubleshooting:
```bash
docker exec -it mypostgres pebble logs
docker exec -it mypostgres pebble services
docker exec -it mypostgres pebble restart postgres
```

### Testing rock
Using [Spread](https://github.com/canonical/spread):
```bash
rockcraft test                       # run all tests
ls -la spread/tests/                 # list all tests
rockcraft test -- spread/tests/smoke # run one test suite
rockcraft test --debug               # to open shell for failed test
rockcraft test --shell-after         # to open shell after each step
```

## License
PostgreSQL is licensed under the [PostgreSQL License][pg-license], a liberal Open Source license similar to the BSD or MIT licenses.
PostgreSQL is a trademark or registered trademark of PostgreSQL Global Development Group. Other trademarks are property of their respective owners.
See [LICENSE][repo-license].

[release-badge]: https://github.com/canonical/postgresql-rock/actions/workflows/release.yaml/badge.svg
[release-link]: https://github.com/canonical/postgresql-rock/actions/workflows/release.yaml
[repo-license]: https://github.com/canonical/postgresql-rock/blob/16-24.04/LICENSE
[repo-rockcraft]: https://github.com/canonical/rockcraft
[pg-license]: https://www.postgresql.org/about/licence/
