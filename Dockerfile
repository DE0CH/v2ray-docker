FROM alpine:latest

RUN apk add --no-cache curl unzip nginx

ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}
ENV V2RAY_VERSION=v4.31.0

WORKDIR /app

RUN case "${TARGETARCH}" in \
    amd64) ARCH_SUFFIX="64" ;; \
    arm64) ARCH_SUFFIX="arm64-v8a" ;; \
    *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -L -o v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-${ARCH_SUFFIX}.zip && \
    unzip v2ray.zip && \
    rm v2ray.zip && \
    chmod +x v2ray v2ctl

COPY blog.conf /etc/nginx/http.d/default.conf
COPY www/blog/ /var/www/blog/

CMD ["sh", "-c", "nginx && /app/v2ray run -c /etc/v2ray/config.json"]
