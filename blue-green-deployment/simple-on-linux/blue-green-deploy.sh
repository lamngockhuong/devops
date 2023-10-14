#!/bin/bash

root_path="/home/deploy"
project_path="$root_path/example-web/"
deploy_path="$root_path/app"
default_branch=main
jar_filename="web-1.0-SNAPSHOT.jar"
jar_filepath="build/libs/$jar_filename"
slack_hook=https://hooks.slack.com/triggers/xx/xx/xxx
blue=example-web-blue.service
green=example-web-green.service
blue_port=8080
green_port=8081
nginx_target=(
  "/etc/nginx/sites-enabled/example-web.conf"
)

# move to project path
cd "$project_path" || exit

# Ask users if they want to pull the latest source code
read -r -p "Do you want to pull the latest source code? (y/n): " pullLatest

if [ "$pullLatest" = "y" ] || [ "$pullLatest" = "Y" ]; then

    read -r -p "Input the branch name (default is $default_branch): " branch
    branch=${branch:-$default_branch}

    # check branch name exists
    if ! git rev-parse --verify "$branch" > /dev/null 2>&1; then
        echo "Branch '$branch' doest not exist."
        exit 1
    fi

    # checkout & pull new source code
    git checkout "$branch"
    git pull origin "$branch"
else
    echo "You have chosen not to pull the latest source code."
fi

# build jar file
./gradlew build -x test

if [ -f "$jar_filepath" ]; then
  echo "🔎 Jar file found: $jar_filepath"
else
  echo "❌ Build failed or JAR file not found!"
  exit 1
fi

# if blue port doesn't respond, we'll deploy there, otherwise we expect green port next
if ! /usr/bin/nc -z localhost $blue_port;
then
  echo "🚀 Starting blue service ($blue_port), stopping green service ($green_port)"
  cp $jar_filepath "$deploy_path/app-blue.jar"
  current=$green
  next=$blue
  nginxsource=(
    "/etc/nginx/sites-available/example-web.blue.conf"
  )
  port=$blue_port
else
  echo "🚀 Starting green service ($green_port), stopping blue service ($blue_port)"
  cp $jar_filepath "$deploy_path/app-green.jar"
  current=$blue
  next=$green
  nginxsource=(
    "/etc/nginx/sites-available/example-web.green.conf"
  )
  port=$green_port
fi

# start the next service
systemctl start $next

# wait until Spring Boot (eh, Hibernate) starts
i=0
while [[ $i -lt 62 ]]
do
  echo -en "\r👀 Waiting for $next to start $i "
  ((i++))

  if [[ $i -gt 60 ]]; then
    echo "❌ The new process did not start properly"
    exit 1;
  fi

  if /usr/bin/nc -z localhost $port; then
    echo "🍀 ready";
    break;
  fi

  sleep 1
done

# switch the front proxy (nginx here) to use the next service
for i in "${!nginx_target[@]}"; do
  ln -fs "${nginxsource[$i]}" "${nginx_target[$i]}"
done

# must
systemctl reload nginx

# notify the team about the successful deployment (to the Slack)
notify=$(curl -X POST -H "Content-type: application/json" \
  --data "{\"current_service\":\"$next\",\"current_port\":\"$port\"}" $slack_hook)

# check notification
if [[ $notify == '{"ok":true}' ]]; then
  echo "📣 Notified to the team..."
fi

# shut down the obsoleted spring boot process
systemctl stop $current

# set defaults for reboot
systemctl disable $current
systemctl enable $next

echo "️🎉 Version upgrade complete!"
