# Telegram MTProto Proxy on Railway

A minimal, reusable Railway deployment for Telegram's official MTProto proxy Docker image.

- No personal domain is hard-coded.
- No proxy secret is committed to GitHub.
- Uses the official `telegrammessenger/proxy:latest` image.
- Runs the proxy on **TCP port 443 inside the container**.
- Works with Railway's public **TCP Proxy** networking.

## Deploy on Railway

1. In Railway, create a new service from this GitHub repository.
2. Add these service variables:

   | Variable | Required | Example |
   |---|---:|---|
   | `SECRET` | Yes | Generate with `openssl rand -hex 16` |
   | `WORKERS` | No | `2` |
   | `TAG` | No | Tag issued by Telegram's `@MTProxybot` |

   `SECRET` must be exactly 32 lowercase hexadecimal characters. Generate the value first; do **not** paste sample or explanatory text into Railway. Never commit your production secret to GitHub.

   Valid example shape (generate your own value):

   ```text
   c096301b5edd234d89c602ce4a83cd4e
   ```

   Invalid example:

   ```text
   replace_with_exactly_32_lowercase_hex_characters
   ```

3. Open the service's **Settings → Networking → TCP Proxy**.
4. Create a TCP Proxy for application port **443**.
5. Railway returns an endpoint similar to:

   ```text
   example.proxy.rlwy.net:12345
   ```

6. Build the Telegram link using Railway's hostname, assigned public port, and your secret:

   ```text
   https://t.me/proxy?server=example.proxy.rlwy.net&port=12345&secret=YOUR_SECRET
   ```

   Or:

   ```text
   tg://proxy?server=example.proxy.rlwy.net&port=12345&secret=YOUR_SECRET
   ```

## Ports: must MTProto use 443?

No. MTProto Proxy can be exposed on any reachable **TCP** port.

The official container listens on internal TCP port `443`. On a normal VPS or Docker host, map any external port to it:

```bash
docker run -d \
  --name mtproto-proxy \
  --restart unless-stopped \
  -p 8443:443/tcp \
  -e SECRET="$(openssl rand -hex 16)" \
  -e WORKERS=2 \
  telegrammessenger/proxy:latest
```

Clients would then use port `8443`.

### Railway limitation

Railway assigns the external public port for its TCP Proxy. You choose the internal application port (`443` here), but normally you **cannot choose Railway's public port**. To expose several public ports, you generally need separate Railway services/TCP proxies. On a VPS, Docker, HAProxy, or firewall redirects can expose many external TCP ports to the same internal proxy.

Port `443` is common because restrictive networks are less likely to block it, but it is not mandatory.

## Local Docker Compose

```bash
cp .env.example .env
# Edit .env and set SECRET to the output of: openssl rand -hex 16
docker compose up -d --build
docker compose logs -f
```

The local proxy is available on TCP port `443`. Change the left side of `443:443/tcp` in `docker-compose.yml` to expose another host port.

## Security

- Revoke any GitHub or Railway access token accidentally pasted into chats or logs.
- Rotate a proxy secret if it was exposed unintentionally.
- Do not commit `.env`.
- Use `TAG` only if you intentionally register the proxy with Telegram's `@MTProxybot`.
