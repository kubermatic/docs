FROM composer:latest

RUN composer global require couscous/couscous && \
    ln -s /composer/vendor/bin/couscous /usr/local/bin

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["couscous"]

EXPOSE 8000
