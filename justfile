build-latest:
  docker build -t genevachat/db-migrate:latest .

build-commit:
  #!/usr/bin/bash
  set -eux

  if !(git diff-index --quiet HEAD);
  then
    echo git repo dirty
    exit 1
  fi

  commit_hash=$(git rev-parse --short HEAD)
  image_tag=genevachat/db-migrate:$commit_hash
  docker build -t $image_tag .
  echo built: $image_tag
