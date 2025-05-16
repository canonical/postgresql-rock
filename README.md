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
git clone git@github.com:canonical/postgresql-rock.git
cd postgresql-rock
```

### Installing Prerequisites
```bash
sudo snap install rockcraft --edge
sudo snap install docker
sudo snap install lxd
sudo snap install skopeo --edge --devmode
```

### Configuring Prerequisites
```bash
sudo usermod -aG docker $USER
sudo lxd init --auto
```

*_NOTE:_* You will need to open a new shell for the group change to take effect (i.e. `su - $USER`)

### Packing and Running the rock
```bash
rockcraft pack
sudo skopeo --insecure-policy copy oci-archive:postgresql*.rock docker-daemon:<username>/postgresql:<tag>
docker run --rm -it <username>/postgresql-server:<tag>
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
