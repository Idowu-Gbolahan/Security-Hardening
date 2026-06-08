# Stage 1: Build nginx from source for minimal attack surface
FROM nginx:1.30.2-alpine3.23 AS base
# Remove default configs
RUN rm -rf /etc/nginx/conf.d/*
# Create non-root user
RUN addgroup -g 1001 -S nginx-grp && \
    adduser  -u 1001 -S nginx-usr -G nginx-grp
# Copy hardened configs
COPY nginx.conf      /etc/nginx/nginx.conf
COPY security.conf   /etc/nginx/conf.d/security.conf
COPY ssl.conf        /etc/nginx/conf.d/ssl.conf
# Set permissions
RUN chown -R nginx-usr:nginx-grp /var/cache/nginx \
    /var/log/nginx /etc/nginx && \
    chmod 750 /var/cache/nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx-usr /var/run/nginx.pid
# Drop to non-root
USER nginx-usr:nginx-grp
# Expose non-privileged port
EXPOSE 8443
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
