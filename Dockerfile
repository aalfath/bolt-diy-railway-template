# bolt.diy for Railway: the official image, pinned, with a small Caddy proxy
# in front that adds a login (HTTP basic auth) and a /healthz endpoint.
FROM caddy:2.11.9@sha256:4e2425f6009577e7c651010f16679c28f7d12df3e7b1914f941a7a3370746b3c AS caddy

FROM ghcr.io/stackblitz-labs/bolt.diy:v1.0.3@sha256:89f1061e2ffad4f51125c6f931f18a4b2aaec2a1010799ea6b9608f399d7c99e

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/bolt/Caddyfile
COPY start.sh /usr/local/bin/bolt-start
RUN chmod 0755 /usr/local/bin/bolt-start

ENV PORT=8080 \
    VITE_LOG_LEVEL=info
EXPOSE 8080

CMD ["/usr/local/bin/bolt-start"]
