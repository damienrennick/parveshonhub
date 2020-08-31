#!/bin/bash
failed()
{
    echo "Installing Docker-Compose. Please wait..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo -e "\\nThere you go... Docker-Compose version:"
    /usr/bin/docker-compose version
}

echo "Docker-compose version is: "
docker-compose version
if [ $? != 0 ]; then
    echo "Docker-Compose not found..."
    failed
fi

echo $PWD
/usr/bin/docker-compose up -d --force-recreate #Bring the prometheus setup up
ls -ltrh

#/usr/bin/docker-compose down -v #Remove the initial comment to tear down the setup completely

