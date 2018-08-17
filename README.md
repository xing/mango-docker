# mango-docker
This Docker image is based on [butomo1989/docker-android](https://github.com/butomo1989/docker-android).
It contains an Android Emulator running a Nexus 5 on Android 8.0 with instance boot and no Appium dependency.

The Image exposes 1 port:

| Port | Function       |
|------|----------------|
| 6080 | noVNC          |

## How to Build
Android Base Image:  
```sh
docker build -t mango-base -f dockerfiles/AndroidBase .
```
Emulator Image:  
```sh
unzip -quo user_data/android_emulator.zip -d android_emulator_dump
docker build -t mango-docker -f dockerfiles/AndroidEmulator .
```

**If you change the userdata image rember to zip it before commiting**

## How to run the image
Run the image with
```sh
docker run --privileged -d -p 6080:6080 --name android-container mango-docker
```

After the Container started you can connect to noVNC by open http://localhost:6080 in your browser.

## Updating user data
- Build a new container
- Run Docker container
- After device is booted check if there is no crashes or popups and close it to get a Snapshot saved
- rm -rf android_emulator_dump/ && rm user_data/android_emulator
- Copy/zip/push folder from docker to local folder and git:   
```
docker cp android-container:/root/android_emulator .  
apt-get install zip  
zip -r android_emulator.zip android_emulator  
mv android_emulator.zip user_data/android_emulator.zip  
git add user_data/android_emulator.zip && git commit -m 'upload emulator.zip' && git push  
```