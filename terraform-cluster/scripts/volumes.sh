#!/bin/bash

# wait until the drive is attached to the instance
while ! [ -e ${DEVICE} ]
  do sleep 1 ;echo "waiting for EBS drive ${DEVICE} to appear"
done

# refresh the LVM state
vgchange -ay

# output the filesystem of the device, if it already has one
DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`

# if there is no filesystem on the device, format it
if [ "`echo -n $DEVICE_FS`" == "" ] ; then
    # create a physical volume - initialize the DEVICE disk for use by LVM
    pvcreate ${DEVICE}

    # create a volume group (i.e. a "pool" of storage space) named data
    # and include the newly created physical volume
    vgcreate data ${DEVICE}

    # create a logical volume in the data volume group named volume1,
    # which occupies the entire volume group
    lvcreate --name volume1 -l 100%FREE data

    # create an ext4 filesystem within the newly created logical volume
    mkfs.ext4 /dev/data/volume1
fi

# create a /data directory to mount the logical volume,
# or do nothing if it already exists (-p flag)
mkdir -p /data

# insert a new line in the /etc/fstab file for the automatic mounting of 
# the new volume whenever the instance reboots
echo '/dev/data/volume1 /data ext4 defaults 0 0' >> /etc/fstab

# mount the new volume
mount /data