# xing-android-docker
This is Docker image is based on [butomo1989/docker-android](https://github.com/butomo1989/docker-android).
It contains an Android Emulator running a Nexus 5 on Android 8.0

The Image exposes 1 port:

| Port | Function       |
|------|----------------|
| 6080 | noVNC          |

## How to Build
Emulator Image:  
```sh
make build-emulator-image IMAGE_NAME=android-docker
```
Android Base Image:  
```sh
make build-base-image IMAGE_NAME=android-base
```
will build an image with the tag `android-docker`. If you ommit the `IMAGE_NAME` the image will be tagged with ` docker.dc.xing.com/mobile-releases/android-emulator.

**If you change the userdata image rember to zip it before commiting**

## How to run the image
Run the image with
```sh
docker run --privileged -d -p 6080:6080 --name android-container android-docker
```

After the Container started you can connect to noVNC by open http://localhost:6080 in your browser.

## Updating and pushing the image
If you changed the image and want to publish it to our [docker registry](https://registry.dc.xing.com/home) you have to

1. login to the registry
    ```sh
    docker login docker.dc.xing.com
    ```
    and provide your **xing email** and **ldap password**

2. build the and push the images
Release Base Image:  
```sh
make release_base
```
Release Emulator Image:  
```sh
make release_emulator
```

## Updating user data
- Build a new container `make build-emulator-image`  removing this line: https://source.xing.com/mobile-releases/xing-android-docker/blob/master/src/app.py#L100
- Run Docker container: `docker run --privileged -d -p 6080:6080 -e DEVICE='Nexus 5X' --name calabash_emulator_11 docker.dc.xing.com/mobile-releases/android-emulator:latest`
- After device is booted check if there is no crashes or popups and close it to get a Snapshot saved
- rm -rf android_emulator_dump/ && rm user_data/android_emulator
- Copy/zip/push folder from docker to local folder and git:   
```
docker cp calabash_emulator_11:/root/android_emulator .  
apt-get install zip  
zip -r android_emulator.zip android_emulator  
mv android_emulator.zip user_data/android_emulator.zip  
git add user_data/android_emulator.zip && git commit -m 'upload emulator.zip' && git push  
```
