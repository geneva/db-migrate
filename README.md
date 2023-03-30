# Building notes
If you get an error upon attempting to build that looks like:
"multiple platforms feature is currently not supported for docker driver",
check the output of `docker buildx ls`.

You may need to switch to a different builder, which you can create by:

`docker buildx create --name buildx-container --driver=docker-container`

Then during building, specify the builder `buildx-container`. For example:

`just build-commit buildx-container`.
