#!/usr/bin/env bash


function prompt-for-password() {
    if [ -z "$XAUTHORITY" ]; then
        echo $(read -p "$1 " -s xyzzy && echo $xyzzy)
    else
        echo $(zenity --entry --text="$1")
    fi
}

# Ex.
# `get-blockdev-path-by-id "scsi-SATA_ST3000DM001-1E6_W1F2W9LH"`
#   -> "/dev/sdb"
function get-blockdev-path-by-id() {
    readlink -f "/dev/disk/by-id/$1"
}

########

function truecrypt-list-mounted-volumes() {
    # Column 1 is the "TrueCrypt slot number";
    #        2        the path of the volume or device being mounted
    #        3        the path of the TrueCrypt mapper (/dev/mapper/truecryptN)
    #        4        the path where the volume or device is mounted
    truecrypt --text --list 2> /dev/null | cut -d ' ' -f 2
}

function truecrypt-volume-is-mounted() {
    local MOUNTED_VOLUMES=`truecrypt-list-mounted-volumes`
    for MOUNTED_VOLUME in $MOUNTED_VOLUMES; do
        if [[ "$MOUNTED_VOLUME" == "$1" ]]; then return 0; fi
    done
    return 1
}

function truecrypt-mount-volume()  {
    local BLOCKDEV=`get-blockdev-path-by-id "$1"`

    if truecrypt-volume-is-mounted "$BLOCKDEV"; then
        echo "tc-mount: already mounted: $2 ($BLOCKDEV, \"$1\")"
    else
        # Assumes volumes use same passphrase; prompts only the first time.
        if [[ -z "$TRUECRYPT_PASSPHRASE" ]]; then
            TRUECRYPT_PASSPHRASE=$(prompt-for-password "TrueCrypt volume password?")
        fi

        echo "tc-mount: mounting: $2 ($BLOCKDEV, \"$1\")"
	    sudo mkdir -p "$2" && sudo chown kelleyk:kelleyk "$2"
	    truecrypt --mount --password="$TRUECRYPT_PASSPHRASE" "$BLOCKDEV" "$2"
    fi
}

# The block device must be mounted by truecrypt; we umount the partition so that we can work on it,
# then re-mount it.
function truecrypt-fsck-volumes () {
    local IFS=$'\n'  # Let's loop over lines instead of words.
    for LINE in $(truecrypt --text --list 2> /dev/null); do
        local TC_MAPPER_NO=$(echo "$LINE" | cut -d ' ' -f 1)
        local TC_MAPPER_NO=${TC_MAPPER_NO%:}  # "42:" -> "42"
        local TC_MOUNT_PATH=$(echo "$LINE" | cut -d ' ' -f 4)

        # This is the TrueCrypt "block device"; it's a symlink to one of the /dev/dm-NN special
        # files provided via device-mapper.
        local TC_MAPPER_PATH="/dev/mapper/truecrypt${TC_MAPPER_NO}"

        # XXX: Assert that mapper path exists.
        echo "$TC_MOUNT_PATH (#$TC_MAPPER_NO) - umounting and fscking..."
        sudo umount "$TC_MOUNT_PATH"
        sudo fsck -C -f -y "$TC_MAPPER_PATH"  # -C: show progress bars; -y: always try to fix errors
        sudo mount "$TC_MAPPER_PATH" "$TC_MOUNT_PATH"
        echo "...done!\n"
    done
}


# TrueCrypt options to explore:
# --backup-headers=VOLUME_PATH
# --create=VOLUME_PATH
# -d, --dismount [=MOUNTED_VOLUME] (or don't specify, to unmount all)
# --volume-properties[=MOUNTED_VOLUME]
# --version
# --test
# --slot=SLOT   (use specified mapper # slot when mounting or dismounting or listing a volume)
# -v, --verbose
