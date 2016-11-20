#!/system/bin/sh
# 

# Mount
mount -o remount,rw -t auto /system
mount -o remount,rw -t auto /data
mount -t rootfs -o remount,rw rootfs


# init.d support
if [ ! -e /system/etc/init.d ]; then
   mkdir /system/etc/init.d
   chown -R root.root /system/etc/init.d
   chmod -R 755 /system/etc/init.d
fi

# start init.d
for FILE in /system/etc/init.d/*; do
   sh $FILE >/dev/null
done;


# Unmount
mount -t rootfs -o remount,ro rootfs
mount -o remount,rw -t auto /data
mount -o remount,ro -t auto /system
