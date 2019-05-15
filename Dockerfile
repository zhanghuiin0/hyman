FROM nginx:stable-alpine
COPY ["nginx/html","/usr/share/nginx/html"]
COPY ["nginx/conf.d/netmis.8888play.com.conf","/etc/nginx/conf.d/default.conf"]
EXPOSE 8080
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
