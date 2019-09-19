FROM nginx:mainline

ADD octodocs/ /srv/www
ADD nginx.conf /etc/nginx/conf.d/default.conf
