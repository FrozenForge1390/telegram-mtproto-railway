# Telegram MTProto Proxy on Railway

A minimal, reusable Railway deployment for Telegram's official MTProto proxy Docker image.

- No personal domain is hard-coded.
- Includes a ready-to-use built-in project secret, so Railway variables are optional.
- Uses the official `telegrammessenger/proxy:latest` image.
- Runs the proxy on **TCP port 443 inside the container**.
- Works with Railway's public **TCP Proxy** networking.

## Deploy on Railway — no variables required

1. In Railway, create a new service from this GitHub repository.
2. Do **not** add any variables. The repository already contains:
   - a built-in, project-level 32-character `SECRET`
   - automatic `WORKERS=2`

   Built-in project secret:

   ```text
   916d568abce960c5b03d8b77e103388b
   ```

   Because this repository is public, this default secret is public and shared by every deployment unless overridden.
3. Open the service's **Settings → Networking → TCP Proxy**.
4. Create a TCP Proxy for application port **443**.
5. Redeploy the service once after creating the TCP Proxy.
6. Open **Deploy Logs**. The ready-to-click `https://t.me/proxy?...` and `tg://proxy?...` links are printed under `[auto-config]`.

That is all. No domain, secret, or worker variable is required.

### Optional overrides

You may still set these variables manually:

| Variable | Required | Description |
|---|---:|---|
| `SECRET` | No | Exactly 32 lowercase hexadecimal characters; generate with `openssl rand -hex 16` |
| `WORKERS` | No | Worker count; default `2` |
| `TAG` | No | Tag issued by Telegram's `@MTProxybot` |

If `SECRET` is absent or invalid, the wrapper uses the built-in project secret shown above.

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
docker compose up -d --build
docker compose logs -f
```

No `.env` file is required. Create one only if you want to override the built-in secret or worker count.

The local proxy is available on TCP port `443`. Change the left side of `443:443/tcp` in `docker-compose.yml` to expose another host port.

## Security

- Revoke any GitHub or Railway access token accidentally pasted into chats or logs.
- Rotate a proxy secret if it was exposed unintentionally.
- Do not commit `.env`.
- Use `TAG` only if you intentionally register the proxy with Telegram's `@MTProxybot`.
