#!/bin/bash

# example-web.blue.conf
cat > /etc/nginx/sites-available/example-web.blue.conf << EOF
server {
    listen 80;
    server_name example-web.example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# example-web.green.conf
cat > /etc/nginx/sites-available/example-web.green.conf << EOF
server {
    listen 80;
    server_name example-web.example.com;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
