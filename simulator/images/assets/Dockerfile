FROM registry:2 AS reg
FROM nginx:1.27-alpine
COPY --from=reg /bin/registry /usr/local/bin/registry
COPY registry.yml /etc/registry.yml
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
