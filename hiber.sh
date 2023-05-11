#!/system/bin/sh
# Copyright (c) 2020-2021 The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


VERSION=1.0
echo "Current hibernation script version is $VERSION"

echo Y > /sys/module/printk/parameters/ignore_loglevel
echo N > /sys/module/printk/parameters/console_suspend
echo 0 > /d/tracing/tracing_on

# Turn BT off. Here keyevents (23:KEYCODE_DPAD_CENTER, 22:KEYCODE_DPAD_RIGHT)
# are used to allow this script to turn off BT.
am start -a android.bluetooth.adapter.action.REQUEST_DISABLE && input keyevent 23 && input keyevent 22 && input keyevent 23

echo none > /sys/bus/platform/devices/a600000.ssusb/mode
#echo none > /sys/bus/platform/devices/a800000.ssusb/mode

echo "Putting all connected USB devices to auto suspend forcefully"
for j in /sys/bus/usb/devices/*/power/control;
do echo auto > $j;
done


killall qcarcam_edrm_rvc
killall qcarcam_test
killall qcarcam_rvc

sda=`ls -l /dev/block/by-name/swap_a | awk '{print $NF}' | awk -F'[/]' '{print $4}'`
major=`ls -l /dev/block/${sda} | awk '{print $5}' | grep -o '[0-9]*'`
minor=`ls -l /dev/block/${sda} | awk '{print $6}' | grep -o '[0-9]*'`
echo "${major}:${minor}" > /sys/power/resume
sleep 3

echo "enable swap partition"
mkswap /dev/block/sda13
swapon /dev/block/sda13 -p 0

echo 100 > /proc/sys/vm/swappiness
echo 0 > /sys/power/image_size
echo "UI turn off"
cat /proc/swaps

sync

#drop caches
echo "drop page caches"
sleep 2

echo stop > /sys/class/remoteproc/remoteproc0/state
echo stop > /sys/class/remoteproc/remoteproc1/state

hiber_attempts="1"
while true
do
  echo 3 > /proc/sys/vm/drop_caches
  #echo 1 > /sys/module/lpm_levels/parameters/sleep_disabled
  sync
  #hibernate
  echo "Start Hibernation"
  echo 8 > /proc/sys/kernel/printk

  echo shutdown > /sys/power/disk
  echo disk > /sys/power/state
  if [ $? -eq 0 ]
  then
	echo "Hibernation Successful!"
	break
  else
	echo "Hibernation failed!" >&2

	if [ "$hiber_attempts" -ge "5" ]
	then
	  echo "Fatal: Hibernation attemps >= 5" >&2
	  echo c > /proc/sysrq-trigger
	fi
  fi
  hiber_attempts=$((hiber_attempts + 1))
  sleep 2
done

# Post Restore

echo start > /sys/class/remoteproc/remoteproc0/state
echo start > /sys/class/remoteproc/remoteproc1/state

setprop persist.vendor.usb.config diag,adb
echo peripheral > /sys/bus/platform/devices/a600000.ssusb/mode
swapoff /dev/block/sda13
echo "restart keymaster service and keystore daemon"
killall android.hardware.keymaster@4.1-service-qti
pkill keystore2
echo "restart qseecomd deamon"
pkill qseecomd
