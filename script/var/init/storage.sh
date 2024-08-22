#!/bin/sh

. /opt/muos/script/var/func.sh

# Make sure both VARS and LOCS match the same index as required
STORAGE_VARS="bios catalogue config fav fav fav music save screenshot theme"
STORAGE_LOCS="bios info/catalogue info/config info/core info/favourite info/history music save screenshot theme"

# Shouldn't need to touch any of the below logic unless a critical failure occurs!
S_=0
for S_VAR in $STORAGE_VARS; do
	S_LOC=$(echo "$STORAGE_LOCS" | cut -d' ' -f$((S_ + 1)))

	mkdir -p "/run/muos/storage/$S_VAR"
	case "$(GET_VAR "global" "storage/$S_VAR")" in
		0)
			MOUNT="$(GET_VAR "device" "storage/rom/mount")"
			;;
		1)
			MOUNT="$(GET_VAR "device" "storage/sdcard/mount")"
			;;
		2)
			MOUNT="$(GET_VAR "device" "storage/usb/mount")"
			;;
		*)
			printf "Storage not valid! Skipping...\n"
			S_=$((S_ + 1))
			continue
			;;
	esac

	echo mount --bind "$MOUNT/MUOS/$S_LOC" "/run/muos/storage/$S_LOC"

	if ! mount --bind "$MOUNT/MUOS/$S_LOC" "/run/muos/storage/$S_VAR"; then
		MOUNT="$(GET_VAR "device" "storage/rom/mount")"
		if ! mount --bind "$MOUNT/MUOS/$S_LOC" "/run/muos/storage/$S_VAR"; then
			/opt/muos/extra/muxstart "$(printf "Critical Mount Failure\n\nFailed to mount '%s' on '%s'!\nDirectory '%s' not found!" "$S_LOC" "$MOUNT" "$S_VAR")" && sleep infinity
		fi
	fi

	S_=$((S_ + 1))
done
