
#!/bin/bash

set -e

export PGPASSWORD

if [ -z "$PGPASSWORD" ]; then
  echo "Must supply PGPASSWORD to open database shell"
  exit 1
fi

host=${PGHOST-doltlab_doltlabdb_1}
port=${PGPORT-5432}
network=${DOLTLAB_NETWORK-doltlab_doltlab}

doltlabadmin_username="dolthubadmin"
doltlabapi_dbname="dolthubapi"

docker run \
--rm \
-it \
--network "$network" \
-e PGPASSWORD="$PGPASSWORD" \
postgres:13-bullseye \
bash -c \
"psql --host=$host --port=$port --username=$doltlabadmin_username --dbname=$doltlabapi_dbname"

