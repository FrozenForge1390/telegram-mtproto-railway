# Telegram MTProto Proxy on Railway

A minimal Railway deployment using Telegram's official `telegrammessenger/proxy` image.

- No personal domain is included.
- No production secret is committed to GitHub.
- The container listens on internal TCP port `443`.

## Deploy

1. Create a Railway service from this GitHub repository.
2. Open the service's **Variables** tab and add:

   ```env
   SECRET=YOUR_32_CHARACTER_LOWERCASE_HEX_SECRET
   WORKERS=2
   ```

   Generate a secret locally with:

   ```bash
   openssl rand -hex 16
   ```

   `SECRET` must contain exactly 32 lowercase hexadecimal characters, with no quotes or spaces.

3. Apply/deploy the staged variable changes.
4. Open **Settings → Networking → TCP Proxy**.
5. Create a TCP Proxy for application port:

   ```text
   443
   ```

6. Railway returns a public endpoint such as:

   ```text
   example.proxy.rlwy.net:12345
   ```

7. Create the Telegram link:

   ```text
   https://t.me/proxy?server=example.proxy.rlwy.net&port=12345&secret=YOUR_SECRET
   ```

## Variables

| Name | Required | Value |
|---|---:|---|
| `SECRET` | Yes | Exactly 32 lowercase hexadecimal characters |
| `WORKERS` | No | `2` recommended for Railway |
| `TAG` | No | Only if issued by Telegram's `@MTProxybot` |

Do not add `PORT`; Railway's TCP Proxy should target internal application port `443`.

## Custom ports

MTProto does not require public port 443. The official container listens on internal TCP 443, while Railway assigns a public TCP port. On a VPS, any external TCP port can be mapped to container port 443.

## Local Docker

```bash
cp .env.example .env
# Fill SECRET in .env
docker compose up -d --build
docker compose logs -f
```

## Security

- Never commit `.env` or a production secret.
- Rotate exposed GitHub, Railway, or proxy credentials.
