FROM alpine:latest
RUN apk add --no-cache bash cpulimit procps
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
