FROM nginx:1.19.6

LABEL maintainer="enriqueavilac"

COPY proxy.conf /etc/nginx/conf.d/default.conf