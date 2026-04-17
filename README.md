# PostgreSQL Server rock
[![Release to GHCR][release-badge]][release-link]

This repository contains the packaging metadata for creating a rock of PostgreSQL built from
the official ubuntu PostgreSQL package from the Ubuntu repository.
For more information on rocks, visit the [rockcraft repository][repo-rockcraft].

## Using Rock

As simple as pull, run, connect. Pull:
```bash
docker pull ubuntu/postgres:16-24.04_edge
```

Start a new container:
```bash
docker run -it -d \
    -e POSTGRES_PASSWORD=myS3cr3tp@ss \
    --name mypostgres \
    -p 3432:5432 \
    --volume pg-data:/var/lib/postgresql/ \
    ubuntu/postgres:16-24.04_edge
```

Connect using psql from the container:
```bash
docker exec -it \
    -e PGPASSWORD=myS3cr3tp@ss \
    mypostgres psql -h 127.0.0.1 -p 5432 -U postgres -d postgres

> psql (16.13 (Ubuntu 16.13-0ubuntu0.24.04.1))
> Type "help" for help.
>
> postgres=#
```

Connect using local psql (if available):
```bash
sudo apt install -y postgresql-client-*
PGPASSWORD=myS3cr3tp@ss psql -h 127.0.0.1 -p 3432 -U postgres -d postgres

> psql (16.13 (Ubuntu 16.13-0ubuntu0.24.04.1))
> Type "help" for help.
>
> postgres=#
```

### (Re)start/stop rock

To stop/start running rock, use common actions:
```bash
docker ps

> CONTAINER ID   IMAGE                           COMMAND                  CREATED         STATUS          PORTS                                         NAMES
> f935801018a2   ubuntu/postgres:16-24.04_edge   "/usr/bin/pebble ent…"   4 minutes ago   Up 40 seconds   0.0.0.0:3432->5432/tcp, [::]:3432->5432/tcp   mypostgres

docker stop mypostgres

docker start mypostgres

docker exec -it -e PGPASSWORD=myS3cr3tp@ss mypostgres psql -h 127.0.0.1 -p 5432 -U postgres -d postgres

> psql (16.13 (Ubuntu 16.13-0ubuntu0.24.04.1))
> Type "help" for help.
>
> postgres=#
```

### Delete running rock

To delete the running rock (note: ensure data stored in persistent volume!):
```bash
docker ps --format "table {{.Names}}\t{{.Mounts}}"
> NAMES        MOUNTS
> some_pg                <<< DB stored inside container (will be removed with container)
> mypostgres   pg-data   <<< DB stored on percistent volume (survives container removal)

docker volume inspect pg-data

docker stop mypostgres
docker rm mypostgres
```

### PostgreSQL configuration
Start PostgreSQL with non-default configurations (during the initial docker run):
```bash
docker run -it -d \
    -e POSTGRES_PASSWORD=myS3cr3tp@ss \
    -p 3432:5432 \
    --name mypostgres \
    --volume pg-data:/var/lib/postgresql/ \
    ubuntu/postgres:16-24.04_edge \
        --args postgres \
            -c max_connections=242 \
            -c fsync=off \
            -c full_page_writes=off \
            -c shared_buffers=256MB


docker exec -it -e PGPASSWORD=myS3cr3tp@ss mypostgres \
    psql -h 127.0.0.1 -p 5432 -U postgres -d postgres \
        -c 'show max_connections;'

 max_connections
-----------------
 242
(1 row)
```

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
sudo snap install rockcraft --classic
sudo snap install docker
sudo snap install lxd
```

### Configuring Prerequisites
```bash
sudo usermod -aG docker $USER
sudo lxd init --auto
```

### Packing the rock
```bash
rockcraft pack
```

### Running the rock
```bash
VERSION=$(awk '/^version: /{gsub(/'"'"'/, "", $2); print $2;exit}' rockcraft.yaml)
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

## Troubleshooting:
```bash
docker exec -it mypostgres pebble logs
docker exec -it mypostgres pebble services
docker exec -it mypostgres pebble restart postgres
```

## Testing rock
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
