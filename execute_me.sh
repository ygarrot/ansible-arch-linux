#/bin/bash

# ANSIBLE_HOSTS=ansible/resources/hosts
SCRIPTS_DIR=$(readlink -m "$(dirname $0)")
CHROOT_SCRIPTS_DIR=/$(basename $SCRIPTS_DIR)
INSTALL_DIR=/mnt

echo 'increasing /run/archiso/cowspace size for ansible download'
mount -o remount, size=1G /run/archiso/cowspace

echo 'starting installation...'

pacman -S ansible

if [ ! -f $INSTALL_DIR/bin/bash ]; then
  # runs ansible pre_install script
  echo 'configuring disks and installing base system...'
  ansible-playbook  $SCRIPTS_DIR/tasks/pre_setup.yml
fi

if [  $? == 0 ]; then
  cp -R $SCRIPTS_DIR $INSTALL_DIR$CHROOT_SCRIPTS_DIR
  # runs ansible install script while chrooted
  echo 'configuring base system...'
  arch-chroot $INSTALL_DIR ansible-playbook $CHROOT_SCRIPTS_DIR/tasks/setup.yml

  if [  $? == 0 ]; then
    echo 'installation finished successfully, rebooting...'
    umount --recursive $INSTALL_DIR
    reboot
  fi
fi
