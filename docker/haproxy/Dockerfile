FROM haproxy:2.8-alpine
# Create a non-root system user.
# HAProxy needs to bind to port 8080 — non-privileged, so no capabilities needed.
# We drop to this user in the config itself via the 'user' global directive.
RUN addgroup -g 1001 -S haproxy-grp && \
    adduser  -u 1001 -S haproxy-usr -G haproxy-grp
# Copy the single config file.
# No COPY for certs — HAProxy in this stack doesn't terminate TLS.
# Nginx handles TLS upstream. HAProxy deals in plain HTTP internally.
COPY haproxy.cfg /etc/haproxy/haproxy.cfg
# Set correct ownership on the config.
RUN chown haproxy-usr:haproxy-grp /etc/haproxy/haproxy.cfg
# Port 8080 receives traffic from Nginx.
# Not exposed in docker-compose.yml — only reachable on the backend network.
EXPOSE 8080
# Health check: HAProxy's built-in stats page at /haproxy?health
# Returns 200 when HAProxy is running and has at least one healthy backend.
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/haproxy?health || exit 1
# Run as non-root. The 'user' directive in haproxy.cfg also enforces this
# at the HAProxy process level — belt and suspenders.
USER haproxy-usr:haproxy-grp
CMD ["haproxy", "-f", "/etc/haproxy/haproxy.cfg"]

