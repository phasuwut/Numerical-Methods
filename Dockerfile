# ใช้ base image เป็น Nginx
FROM nginx:alpine
COPY web/ /usr/share/nginx/html/
EXPOSE 80
