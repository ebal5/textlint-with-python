# alpine-textlint-with-python
![Linting Dockerfile](https://github.com/ebal5/textlint-with-python/workflows/Linting%20Dockerfile/badge.svg?branch=master)
![Docker Image CI](https://github.com/ebal5/textlint-with-python/workflows/Docker%20Image%20CI/badge.svg)

A textlint docker image with python (for ReStructuredText).

- [What is it?](##What-is-it?)
- [How to use this?](##How-to-use-this?)
- [Licenses](##Licenses)

## What is it?

Linting text with textlint. Textlint is npm package. So, this Docker image is based on node image.

To add support for ReStructuredText, this requires Python. That is why this named "with-python".

## How to use this?

```shell
docker run -it --rm -v $(pwd):/root/doc  ebal/textlint-with-python textlint /root/doc
```

### DockerHub

```shell
docker pull ebal/textlint-with-python:latest
```

### Build

```shell
docker build -t alpine-textlint-with-python .
docker run -it --rm alpine-textlint-with-python
```

## History

- **2021-01-14** Release version 1.2 as v1.2

## Licenses

The code in this repository, unless otherwise noted, is MIT licensed. See the `LICENSE` file in this repository.
