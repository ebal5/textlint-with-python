# alpine-textlint-with-python

A textlint docker image with python (for ReStructuredText).

- [alpine-textlint-with-python](#alpine-textlint-with-python)
 + [What is it?](##What is it?)
 + [How to use this?](##How to use this?)
 + [Licenses](##Licenses)

## What is it?

Linting text with textlint. Textlint is npm package. So, this Docker image is based on node image.

To add support for ReStructuredText, this requires Python. That is why this named "with-python".

## How to use this?

```shell
docker run -it --rm -v $(pwd):/root/doc  ebal/textlint-with-python textlint /root/doc
```

### DockerHub

```shell
docker pull ebal/textlint-with-python
```

### Build

```shell
docker build -t alpine-textlint-with-python .
docker run -it --rm alpine-textlint-with-python
```

## Licenses

The code in this repository, unless otherwise noted, is MIT licensed. See the `LICENSE` file in this repository.

- [docker-library/python](https://github.com/docker-library/python) 3.7-alpine :: MIT
