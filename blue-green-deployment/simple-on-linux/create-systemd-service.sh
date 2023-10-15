#!/bin/bash

# create log path & grant the permission
log_path="/var/log/example-web"
mkdir -p $log_path
chown "$USER:$USER" $log_path

# example-web-blue.service
cat > /etc/systemd/system/example-web-blue.service << EOF
[Unit]
Description=Example Web (blue)
After=syslog.target

[Service]
User=deploy
ExecStart=/usr/bin/java -jar /home/deploy/app/app-blue.jar --server.port=8080 --spring.profiles.active=dev
SuccessExitStatus=143

StandardOutput=append:$log_path/access-blue.log
StandardError=append:$log_path/error-blue.log

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

StandardOutput=append:$log_path/access-green.log
StandardError=append:$log_path/error-green.log

[Install]
WantedBy=multi-user.target
EOF
