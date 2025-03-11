# How to use

These file are there to help generate an image based on the awesome Jacky Zhao's [Quartz](https://github.com/jackyzha0/quartz) repository. The images are [available on Docker Hub](https://hub.docker.com/r/techrail/quartz). The target image is supposed to be a portable Docker image (to be built for ARM64 and AMD64 platforms against Linux only) which contains a script to build a site. The image expects the paths `/source` and `/destination` to be mounted and runs the script against these paths.

**NOTE**: Please check the _How to build a new version of this image_ section below to understand how to build a new version of the image.

These paths are supposed to be bind mounted into the container from the host file system and then the script is to be run. The script will read the source from the `/source` directory and output the result in `/destination/html`. This is actually done using the `build_site.sh` script that is copied into the container. The script read the argument list, and runs some commands to generate the site. Here is what the script assumes and does. Hence the structure and content of the `source` directory has to confirm to the expected structure.

The expectations and behavior of the `build_site.sh` are as follows:

1. The entire obsidian vault contents must be inside `/source` directory.
2. The config and layout files should be available in the path `/source/private/quartz.config.ts` and `/source/private/config.layout.ts`. Hence the files have to be contained in the vault itself.
3. If these files are not present, the script will print the relevant error and exit. 
4. The output will be generated in the `/destination/html` directory. 
5. The `uid` and `gid` to which the resulting files should belong must also have been sent to the script. Once the generation of the files is done, the file ownership is changed using the `chown` command with the given `uid` and `gid`. 

To run the resulting container to generate a site locally would be like this: 

```
CURR_UID=$(id -u)
CURR_GID=$(id -g)
# Remember to set the values below according to your needs
QZ_SOURCE=/data/dockter/techrail.in/input/site 
QZ_DESTINATION=/data/dockter/techrail.in/output 

docker run -it \
  --mount "type=bind,target=/source,source=$QZ_SOURCE" \
  --mount "type=bind,target=/destination,source=$QZ_DESTINATION" \
  techrail/quartz:v4.4.0 \
  /bin/bash /usr/src/app/build_site.sh $CURR_UID $CURR_GID
```

## Using this thing with GitLab CI system
I use this image with GitLab CI to keep both [techrail.in](https://techrail.in) and [my personal site](https://vaibhavkaushal.com) updated! The pipeline is just a single step. You can check out the script I use in the `.gitlab-ci.yml` file in the project root. In case you have questions, you can open an issue here or ask me on [Techrail Discord server](https://discord.gg/aKkWFghPrV).

## How to build a new version of this image
**IMPORTANT**: To build a new version of the docker image, you need to have the [original repo of quartz](https://github.com/jackyzha0/quartz) cloned on top of project root (the `quartz` directory should be at the same level as the `Dockerfile`).

To build a new version of the image, take the following steps: 

1. Go to the `quartz` directory inside this folder: `cd quartz`. This folder contains the source code for the project. 
2. Reset the git status: `git reset --hard`
3. Checkout master (this will bring you into a normal state): `git checkout master`
4. Fetch from origin: `git fetch origin`
5. Now switch to the tag you want to build the docker image against (assuming the tag you want to switch to is `v4.4.3`): `git checkout v4.4.3`
6. Now copy the script from this directory into the `quartz` directory. Assuming you are already inside the quartz directory, run: `cp ../build_site.sh .`
7. Make sure that the script is executable: `chmod +x ./build_site.sh`
8. Now build the image: `docker build -t techrail/quartz:v4.4.3 .` (or if you want to do a multiplatform build and push it: `docker buildx build --platform linux/amd64,linux/arm64 -t techrail/quartz:v4.4.3 --push .`)

That should give you an image that can be used to build the image which can then be used to build the sites that we need.

