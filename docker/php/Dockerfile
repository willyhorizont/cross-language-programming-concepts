FROM php:8.5.6-cli

COPY --from=composer/composer:2.9.8-bin /composer /usr/bin/composer

WORKDIR /workspace

CMD ["bash"]