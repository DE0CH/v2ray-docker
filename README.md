```bash
docker buildx build --platform linux/amd64,linux/arm64 -t de0ch/v2ray:latest --load --push .
```

example docker config

```yaml
services:
  v2ray:
    image: de0ch/v2ray
    restart: unless-stopped
    volumes:
    	- ${PWD}/config.json:/app/config.json

  # This is the Cloudflared service.
  # It will proxy traffic to your application.
  cloudflared:
    image: cloudflare/cloudflared:latest
    restart: unless-stopped
    network_mode: "service:v2ray"
    depends_on:
      - v2ray

    command: tunnel --no-autoupdate run --token <TOKEN>
```

example docker config 2

```yaml
services:
  v2ray:
    image: de0ch/v2ray
    restart: unless-stopped

    command: |
        /bin/sh -c '
        cat > /app/config.json <<EOF
        {
          "log": {
            "loglevel": "warning"
          },
          "routing": {
            "domainStrategy": "AsIs",
            "rules": [
              {
                "type": "field",
                "ip": [
                  "geoip:private"
                ],
                "outboundTag": "block"
              }
            ]
          },
          "inbounds": [
            {
              "listen": "0.0.0.0",
              "port": 1234,
              "protocol": "vmess",
              "settings": {
                "clients": [
                  {
                    "id": "06000fdc-0223-474d-9ff7-1fb316f19759",
                    "security": "auto"
                  }
                ]
              },
              "streamSettings": {
                "network": "ws",
                "wsSettings": {
                  "path": "/websocket"
                }
              }
            }
          ],
          "outbounds": [
            {
              "protocol": "freedom",
              "tag": "direct"
            },
            {
              "protocol": "blackhole",
              "tag": "block"
            }
          ]
        }
        EOF

        nginx && ./v2ray run -c /etc/v2ray/config.json
        '


  # This is the Cloudflared service.
  # It will proxy traffic to your application.
  cloudflared:
    image: cloudflare/cloudflared:latest
    restart: unless-stopped
    network_mode: "service:v2ray"
    depends_on:
      - v2ray

    command: tunnel --no-autoupdate run --token <TOKEN>

```

example config (the port must be 1234)

```json
{
  "log": {
    "loglevel": "warning"
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "block"
      }
    ]
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 1234,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "06000fdc-0223-474d-9ff7-1fb316f19759",
            "security": "auto"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/websocket"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ]
}
```
