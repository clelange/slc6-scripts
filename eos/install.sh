#!/usr/bin/env bash
# Need to be root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

UNAME=`uname -r`
if [[ "$UNAME" != *el6.x86_64 ]]; then
  echo "This script works only on SLC6"
  exit
fi

echo "Copying YUM repo files..."
cp epel.repo /etc/yum.repos.d/
if [[ "$HOSTNAME" == *cern.ch ]]; then
  echo "Host is inside CERN, using internal EOS6 file."
  cp eos6-stable.repo /etc/yum.repos.d/
else
  echo "Host is outside CERN, using external EOS6 file."
  cp eos6-stable-outside.repo /etc/yum.repos.d/
fi

echo "Installing eos-fuse..."
yum install -y eos-fuse

echo "Copying EOS config..."
cp eos /etc/sysconfig/
cp eos.cms /etc/sysconfig/
cp eos.user /etc/sysconfig/

echo "Appending eosfusebind to sshd pam.d config..."
echo "session optional pam_exec.so debug seteuid /usr/bin/eosfusebind --pam" >> /etc/pam.d/sshd

echo "Starting eos service..."
service eosd start
