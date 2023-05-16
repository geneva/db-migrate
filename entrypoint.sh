#!/usr/bin/env sh

set -eo pipefail

export PGPASSWORD="$DB_PASS"

function print_usage {
  cat <<- EOF
Usage: db command

Available commands are:
  status          Show status of migrations
  reset [--force] Reset the database to latest schema.sql
                    --force will suppress the manual confirmation
  up              Migrates the database to the most recent version available
  down            Undoes the most recent database migration
  psql            Drops you into the postgres terminal
  new [name]      Creates a new migration with the specified name
EOF
}

function confirm {
  QUESTION="$1"
  CONTINUE="nil"
  while [ "$CONTINUE" != "yes" ]; do
    printf "%s" "$1 (yes/no) "
    read CONTINUE
    if [ "$CONTINUE" == "no" ]; then
      exit 1
    fi
  done
}

function db_dump {
  pg_dump --dbname="$DB_NAME" --host="$DB_HOST" --username="$DB_USER" "$@"
}

function update_schema_sql {
  if [ "$UPDATE_SCHEMA_SQL" != "true" ]; then
    echo "UPDATE_SCHEMA_SQL is not true, skipping schema.sql update"
    return
  fi

  pg_dumpall --roles-only --host="$DB_HOST" --username="$DB_USER" > /schema.sql
  db_dump --schema-only >> /schema.sql
  db_dump --data-only --table migrations >> /schema.sql
}

case "$1" in
  status)
    sql-migrate status -env=${MIGRATE_ENV:-default}
    ;;
  reset)
    if [[ "$2" != "--force" ]] ; then
      confirm "This will destroy all data and reset schema to schema.sql. Are you sure?"
    fi
    dropdb --if-exists --host="$DB_HOST" --username="$DB_USER" "$DB_NAME"
    createdb --host="$DB_HOST" --username="$DB_USER" "$DB_NAME"
    psql --quiet --dbname="$DB_NAME" --host="$DB_HOST" --username="$DB_USER" < /schema.sql
    ;;
  up)
    sql-migrate up --env=${MIGRATE_ENV:-default}
    update_schema_sql
    ;;
  new)
    if [ -z "$2" ]; then
      print_usage
      exit 1
    fi
    sql-migrate new --env=${MIGRATE_ENV:-default} "$2"
    ;;
  down)
    sql-migrate "$@" --env=${MIGRATE_ENV:-default}
    update_schema_sql
    ;;
  psql)
    psql --dbname="$DB_NAME" --host="$DB_HOST" --username="$DB_USER"
    ;;
  *)
    print_usage
    exit 1
    ;;
esac
