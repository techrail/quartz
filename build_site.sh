#!/bin/bash

if [[ $# -lt 2 ]]; then
	echo "Usage:"
	echo "$0 UID GID"
	echo "   Where UID is the numerical ID of the host system's user that called this script (run 'id -u' to get it)"
	echo "   Where GID is the numerical ID of the host system's user's group that called this script (run 'id -g' to get it)"
	return 1
fi

echo "UID recieved: $1"
echo "GID recieved: $2"

echo "Starting site build"
echo "Copying source files to content folder"
cp -r /source/* /usr/src/app/content
if [ $? -ne 0 ]; then
    echo "Something did not go well while copying content folder"
    return 1
fi

echo "Copying config file"
cp /source/private/quartz.config.ts /usr/src/app/quartz.config.ts
if [ $? -ne 0 ]; then
    echo "Something did not go well while copying config file"
    return 1
fi

echo "Copying layout file"
cp /source/private/quartz.layout.ts /usr/src/app/quartz.layout.ts
if [ $? -ne 0 ]; then
    echo "Something did not go well while copying layout file"
    return 1
fi

echo "Changing to the app directory"
cd /usr/src/app

echo "Running quartz generator"
npx quartz build -o /destination/html -v

if [ $? -ne 0 ]; then
    echo "Something did not go well while building the site"
    return 1
fi

if [ -f /source/private/robots.txt ]; then
    cp /source/private/robots.txt /destination/html/robots.txt
    if [ $? -ne 0 ]; then 
        echo "Something went wrong when copying the robots.txt file"
        return 1
    fi
fi

echo "Changing destination ownership to $1:$2"
chown -R $1:$2 /destination


