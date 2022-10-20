build *args="latest":
  docker buildx build --platform linux/arm64,linux/amd64 -t genevachat/db-migrate:{{ args }} .

push *args="latest":
  docker push genevachat/db-migrate:{{ args }}

build-commit:
  #!/usr/bin/env bash
  set -eux

  if !(git diff-index --quiet HEAD);
  then
    echo git repo dirty
    exit 1
  fi

  commit_hash=$(git rev-parse --short HEAD)
  image_tag=genevachat/db-migrate:$commit_hash
  docker buildx build --platform linux/arm64,linux/amd64 -t $image_tag .
  echo built: $image_tag
