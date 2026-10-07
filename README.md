# PostgreSQL Server rock
[![Release to GHCR][release-badge]][release-link]

This repository contains the packaging metadata for creating a rock of PostgreSQL built from
the official ubuntu PostgreSQL package from the Ubuntu repository.
For more information on rocks, visit the [rockcraft repository][repo-rockcraft].

## Using Rock

As simple as pull, run, connect. Pull:
```bash
docker pull ubuntu/postgres:18-26.04_edge
```

Start a new container:
```bash
# Generate password
tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24 | tee postgres_password.txt
sudo chown 584792:584792 postgres_password.txt
sudo chmod 400 postgres_password.txt

docker run -d \
    --name mypostgres \
    -p 5432:5432 \
    --volume mypgdata:/var/lib/postgresql/ \
    --mount type=bind,source="$PWD/postgres_password.txt",destination=/run/secrets/postgres_password,readonly \
    ubuntu/postgres:18-26.04_edge
    
# (Optional) Allow remote users to log in
# See https://www.postgresql.org/docs/current/auth-pg-hba-conf.html for more information
# Consider restricting to specific IP addresses instead of allowing all IP addresses
docker exec mypostgres sh -c 'echo "host all all all scram-sha-256" >> "$PGDATA/pg_hba.conf"'
docker restart mypostgres
```

Connect using psql from the container:
```bash
docker exec -it mypostgres psql

> psql (18.6 (Ubuntu 18.6-0ubuntu0.26.04.1))
> Type "help" for help.
>
> postgres=#
```

Connect using local psql (if available):
```bash
sudo apt install -y postgresql-client
psql -h 127.0.0.1 --user postgres

> psql (18.6 (Ubuntu 18.6-0ubuntu0.26.04.1))
> Type "help" for help.
>
> postgres=#
```

### (Re)start/stop rock

To stop/start running rock, use common actions:
```bash
docker ps

> CONTAINER ID   IMAGE                           COMMAND                  CREATED         STATUS          PORTS                                         NAMES
> f935801018a2   ubuntu/postgres:18-26.04_edge   "/usr/bin/pebble ent…"   4 minutes ago   Up 40 seconds   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp   mypostgres

docker stop mypostgres

docker start mypostgres

docker exec -it mypostgres psql

> psql (18.6 (Ubuntu 18.6-0ubuntu0.26.04.1))
> Type "help" for help.
>
> postgres=#
```

### Delete running rock

To delete the running rock (note: ensure data stored in persistent volume!):
```bash
docker ps --format "table {{.Names}}\t{{.Mounts}}"
> NAMES        MOUNTS
> some_pg                 <<< DB stored inside container (will be removed with container)
> mypostgres   mypgdata   <<< DB stored on percistent volume (survives container removal)

docker volume inspect mypgdata

docker stop mypostgres
docker rm mypostgres
```

### PostgreSQL configuration
Start PostgreSQL with non-default configurations (during the initial docker run):
```bash
docker run -d \
    -p 5432:5432 \
    --name mypostgres \
    --volume mypgdata:/var/lib/postgresql/ \
    --mount type=bind,source="$PWD/postgres_password.txt",destination=/run/secrets/postgres_password,readonly \
    ubuntu/postgres:18-26.04_edge \
        --args postgres \
            -c max_connections=242 \
            -c fsync=off \
            -c full_page_writes=off \
            -c shared_buffers=256MB


docker exec -it mypostgres psql -c 'show max_connections;'

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
sudo rockcraft.skopeo --insecure-policy copy oci-archive:postgres_18.6_amd64.rock docker-daemon:${USER}/postgres:latest
docker run --rm -it -p 5432:5432 --name mypostgres --volume mypgdata:/var/lib/postgresql/ --mount type=bind,source="$PWD/postgres_password.txt",destination=/run/secrets/postgres_password,readonly -d ${USER}/postgres:latest
```

### Connecting to PostgreSQL
From inside the container:
```bash
docker exec -it mypostgres psql
```

From outside the container:
```bash
sudo apt install -y postgresql-client
psql -h 127.0.0.1 --user postgres
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
