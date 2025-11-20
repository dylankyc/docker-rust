# build in arm64 ok

make build-local


# build, push and run


```bash
# build and push 
docker buildx build --platform linux/amd64,linux/arm64 -t dylandylandy/axum-helloworld:0.0.1 -f Dockerfile.from-docker-example --push .

# run server
docker run -p 13000:3000 dylandylandy/axum-helloworld:0.0.1
# sent request
curl 0:13000
```

