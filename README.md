# aac

Engine-agnostic MyAAC website image for OT servers (TFS 1.x lineage, including
8.60 downgrades). Extracted from the Canary quickstart so AAC deployments do
not depend on a canary-branded image.

## Image

`ghcr.io/woz-94/aac:latest` — built by `.github/workflows/container-images.yml`
on every push to `main`. In MyAAC 2.x against the engine's `accounts`/
`players` schema; bootstraps MyAAC schema, migrations, and an admin account
into the database the engine itself uses.

## Contract

| Variable | Default | Purpose |
| --- | --- | --- |
| `AAC_DB_HOST` | `db` | Database host |
| `AAC_DB_PORT` | `3306` | Database port |
| `AAC_DB_NAME` | `aac` | Database name |
| `AAC_DB_USER` | `otserver` | Database user |
| `AAC_DB_PASSWORD` | `otserver` | Database password |
| `AAC_SERVER_NAME` | `OT Server` | Displayed in status widget |
| `AAC_SERVER_IP` | `127.0.0.1` | IP for the client download button |
| `AAC_SERVER_LOCATION` | `BRA` | Status location |
| `AAC_LOGIN_PORT` | `7171` | Login protocol port |
| `AAC_GAME_PORT` | `7172` | Game protocol port |
| `AAC_STATUS_PORT` | `7173` | Status protocol port |
| `AAC_STATUS_TIMEOUT` | `5000` | Status socket timeout (ms) |
| `AAC_DATA_PACK` | `data` | Datapack directory name under `MYAAC_SERVER_PATH` |
| `MYAAC_SERVER_PATH` | `/srv/` | Where the server datapack copy is mounted |
| `MYAAC_ADMIN_ACCOUNT` | `myaacadmin` | Admin account name (first boot) |
| `MYAAC_ADMIN_EMAIL` | `admin@localhost.local` | Admin email (first boot) |
| `MYAAC_ADMIN_PASSWORD` | `admin123` | Admin password (set as a secret) |
| `MYAAC_ADMIN_PLAYER` | `MyAAC Admin` | Admin character name (first boot) |
| `MYAAC_CLIENT_VERSION` | `1513` | Client version for downloads/login |
| `MYAAC_TIMEZONE` | `America/Fortaleza` | Site timezone |

Behavior notes:

- The entrypoint waits for the `accounts`/`players` tables in the configured
  database (engine-provided), then installs MyAAC's schema, migrations, and
  admin account on first boot.
- `config.lua` written into the datapack copy is for MyAAC's status widget
  only; the actual server process renders its own config.
- Default `vocations.xml`/`groups.xml` are written only if the datapack does
  not ship them.
