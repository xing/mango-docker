#!/usr/bin/env python3

import json
import logging
import os
import subprocess

from src import ROOT
from src import log

log.init()
logger = logging.getLogger('app')


def symlink_force(target, link_name):
    try:
        os.symlink(target, link_name)
    except OSError as e:
        import errno
        if e.errno == errno.EEXIST:
            os.remove(link_name)
            os.symlink(target, link_name)


def get_or_raise(env: str) -> str:
    """
    Check if needed environment variables are given.

    :param env: key
    :return: value
    """
    env_value = os.getenv(env)
    if not env_value:
        raise RuntimeError('The environment variable {0:s} is missing.'
                           'Please check docker image or Dockerfile!'.format(env))
    return env_value

ANDROID_HOME = get_or_raise('ANDROID_HOME')
ANDROID_VERSION = get_or_raise('ANDROID_VERSION')
API_LEVEL = get_or_raise('API_LEVEL')
SYS_IMG = get_or_raise('SYS_IMG')
IMG_TYPE = get_or_raise('IMG_TYPE')

logger.info('Android version: {version} \n'
            'API level: {level} \n'
            'System image: {img} \n'
            'Image type: {img_type}'.format(version=ANDROID_VERSION, level=API_LEVEL, img=SYS_IMG, img_type=IMG_TYPE))

def prepare_avd(device: str, avd_name: str):
    """
    Create and run android virtual device.

    :param device: Device name
    :param avd_name: Name of android virtual device / emulator
    """

    device_name_bash = device.replace(' ', '\ ')
    skin_name = device.replace(' ', '_').lower()

    # For custom hardware profile
    profile_dst_path = os.path.join(ROOT, '.android', 'devices.xml')
    if 'samsung' in device.lower():
        # profile file name = skin name
        profile_src_path = os.path.join(ROOT, 'devices', 'profiles', '{profile}.xml'.format(profile=skin_name))
        logger.info('Hardware profile resource path: {rsc}'.format(rsc=profile_src_path))
        logger.info('Hardware profile destination path: {dst}'.format(dst=profile_dst_path))
        symlink_force(profile_src_path, profile_dst_path)

    avd_path = '/'.join([ANDROID_HOME, 'android_emulator'])
    creation_cmd = 'avdmanager create avd -f -n {name} -b {img_type}/{sys_img} -k "system-images;android-{api_lvl};' \
        '{img_type};{sys_img}" -d {device} -p {path}'.format(name=avd_name, img_type=IMG_TYPE, sys_img=SYS_IMG,
                                                             api_lvl=API_LEVEL, device=device_name_bash,
                                                             path=avd_path)
    logger.info('Command to create avd: {command}'.format(command=creation_cmd))
    subprocess.check_call(creation_cmd, shell=True)

    skin_path = '/'.join([ANDROID_HOME, 'devices', 'skins', skin_name])
    config_path = '/'.join([avd_path, 'config.ini'])
    with open(config_path, 'a') as file:
        file.write('skin.path={sp}'.format(sp=skin_path))
    logger.info('Skin was added in config.ini')

def run():
    """Run app."""
    device = os.getenv('DEVICE', 'Nexus 5X')
    logger.info('Device: {device}'.format(device=device))

    avd_name = '{device}_{version}'.format(device=device.replace(' ', '_').lower(), version=ANDROID_VERSION)
    logger.info('AVD name: {avd}'.format(avd=avd_name))

    logger.info('Preparing emulator...')

    prepare_avd(device, avd_name)

    logger.info('Run emulator...')
    cmd = 'emulator/emulator @{name} -cores 6 -gpu off -no-boot-anim -no-audio -verbose'.format(name=avd_name)
    subprocess.Popen(cmd.split(), stdout=subprocess.PIPE).communicate()

if __name__ == '__main__':
    run()
