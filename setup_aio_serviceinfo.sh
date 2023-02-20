#!/bin/bash


FILE=~/serviceinfo_api_server.yml.bu

echo "Checking if $FILE exist" 
if [ -f "$FILE" ]; then
    echo "Using $FILE as base."
    cp ~/serviceinfo_api_server.yml.bu ~/serviceinfo_api_server.yml
else 
    echo "$FILE does not exist. Downloading"
    curl -o ~/serviceinfo_api_server.yml https://raw.githubusercontent.com/luisarizmendi/tutorial-secure-onboarding/master/documentation/modules/ROOT/examples/serviceinfo_api_server.yml
    cp -f ~/serviceinfo_api_server.yml.bu ~/serviceinfo_api_server.yml
fi

FILE=/etc/fdo-configs
echo "Checking if default config $FILE exist" 
if [ -d "$FILE" ]; then
    echo "Using $FILE as config."
    
else 
    curl -o ~/fdo-configs.tar.gz https://raw.githubusercontent.com/luisarizmendi/tutorial-secure-onboarding/master/documentation/modules/ROOT/examples/fdo-configs.tar.gz 
    tar xvf ~/fdo-configs.tar.gz -C ~
    sudo cp -r ~/fdo-configs/ /etc
fi

FILE=~/.ssh/id_rsa.pub
if [ -f "$FILE" ]; then
    echo "Using $FILE as SSH_PUB_KEY."
else 
    echo "$FILE does not exist. Let's create a new one"
    ssh-keygen
fi

SSH_PUB_KEY=$(sudo cat ~/.ssh/id_rsa.pub)
echo "Set SSH key to $SSH_PUB_KEY" 

read -p "Path to files [/etc/fdo-configs]: " PATH_FILES
PATH_FILES=${PATH_FILES:-/etc/fdo-configs}
echo $PATH_FILES

#echo "Enter Red Hat Username: "

if [ -z "$RED_HAT_USER" ] 
then
    read -p 'Red Hat Username: ' RED_HAT_USER; 
    RED_HAT_USER=$( echo "$RED_HAT_USER"  | base64 )
fi

#echo "\nEnter Red Hat Password: "
if [ -z "$RED_HAT_PASSWORD" ] 
then
    read -sp 'Red Hat Password: ' RED_HAT_PASSWORD; 
    RED_HAT_PASSWORD=$( echo "$RED_HAT_PASSWORD" | base64 ) 
fi
echo
SERVICE_TOKEN=$(grep service_info_auth_token /etc/fdo/aio/configs/serviceinfo_api_server.yml | awk '{print $2}')
echo "Service Token: $SERVICE_TOKEN"

ADMIN_TOKEN=$(grep admin_auth_token /etc/fdo/aio/configs/serviceinfo_api_server.yml | awk '{print $2}')

echo "Admin Token: $ADMIN_TOKEN"

sed -i "s|<SSH PUB KEY>|${SSH_PUB_KEY}|g" serviceinfo_api_server.yml
sed -i "s|<PATH FILES>|${PATH_FILES}|g" serviceinfo_api_server.yml
sed -i "s|<RED HAT USER>|${RED_HAT_USER}|g" serviceinfo_api_server.yml
sed -i "s|<RED HAT PASSWORD>|${RED_HAT_PASSWORD}|g" serviceinfo_api_server.yml
sed -i "s|<SERVICE TOKEN>|${SERVICE_TOKEN}|g" serviceinfo_api_server.yml
sed -i "s|<ADMIN TOKEN>|${ADMIN_TOKEN}|g" serviceinfo_api_server.yml

sudo cp -f ~/serviceinfo_api_server.yml /etc/fdo/aio/configs/serviceinfo_api_server.yml
