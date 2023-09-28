
# Docker file 

The DockerF.yaml

# docker build

# example: docker built -T debian:bookworm -f Dockerfile-Debian-bookworm . > build.log 2>&1

```
docker build -t <myimage> -f <Dockerfile> . > build.log 2>&1
```

# docker run

```

```


# clear data from system
```
docker system prune -a
```

# docker run checks

```
docker ps -q
```

# list the images

```
docker images ls
```

# stop a docker image

```
docker image stop 761a40699cd7
```

# see the logs on an image
```
docker logs 761a40699cd7
```

# remove a docker image

```
docker image rm 761a40699cd7 --force
```