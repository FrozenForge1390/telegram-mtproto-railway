# Official Telegram MTProto Proxy image with zero-variable Railway bootstrap.
FROM telegrammessenger/proxy:latest

COPY auto-start.sh /auto-start.sh
RUN chmod 755 /auto-start.sh

EXPOSE 443/tcp
ENTRYPOINT ["/auto-start.sh"]
CMD []
