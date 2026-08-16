# Official Telegram MTProto Proxy image.
# The proxy listens on TCP 443 inside the container.
FROM telegrammessenger/proxy:latest

EXPOSE 443/tcp
