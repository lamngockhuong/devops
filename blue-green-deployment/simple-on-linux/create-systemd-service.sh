#!/bin/bash

# example-web-blue.service
cat > /etc/systemd/system/example-web-blue.service << EOF
[Unit]
Description=Example Web (blue)
After=syslog.target

[Service]
User=deploy
ExecStart=/usr/bin/java -jar /home/deploy/app/app-blue.jar --server.port=8080 --spring.profiles.active=dev
SuccessExitStatus=143

StandardOutput=append:/home/deploy/log/app-blue.log
StandardError=append:/home/deploy/log/app-blue.error.log

[Install]
WantedBy=multi-user.target
EOF

# example-web-green.service
cat > /etc/systemd/system/example-web-green.service << EOF
[Unit]
Description=Example Web (green)
After=syslog.target

[Service]
User=deploy
ExecStart=/usr/bin/java -jar /home/deploy/app/app-green.jar --server.port=8081 --spring.profiles.active=dev
SuccessExitStatus=143

StandardOutput=append:/home/deploy/log/app-green.log
StandardError=append:/home/deploy/log/app-green.error.log

[Install]
WantedBy=multi-user.target
EOF
