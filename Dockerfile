# ใช้ base image เป็น Nginx
FROM nginx:alpine

# คัดลอกไฟล์ HTML ไปยังโฟลเดอร์ /usr/share/nginx/html/ ใน container
COPY . /usr/share/nginx/html/

# เปิดพอร์ต 80 สำหรับ web server
EXPOSE 80
