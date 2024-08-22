#!/bin/sh

. /opt/muos/script/var/func.sh

NAME=$1
CORE=$2
ROM=$3

export HOME=$(GET_VAR "device" "board/home")

export SDL_HQ_SCALER="$(GET_VAR "device" "sdl/scaler")"
export SDL_ROTATION="$(GET_VAR "device" "sdl/rotation")"
export SDL_BLITTER_DISABLED="$(GET_VAR "device" "sdl/blitter_disabled")"

SET_VAR "system" "foreground_process" "retroarch"

ROMPATH=$(echo "$ROM" | awk -F'/' '{NF--; print}' OFS='/')

mkdir -p "$ROMPATH/.$NAME"

PRBC="$ROMPATH/.$NAME/prboom.cfg"

# Compensate for Windows wild cuntery
dos2unix -n "$ROMPATH/$NAME.doom" "$ROMPATH/$NAME.doom"

IWAD=$(awk -F'"' '/parentwad/ {print $2}' "$ROMPATH/$NAME.doom")

cp -f "$ROMPATH/$NAME.doom" "$PRBC"
cp -f "/run/muos/storage/bios/prboom.wad" "$ROMPATH/.$NAME/prboom.wad"
cp -f "$ROMPATH/.IWAD/$IWAD" "$ROMPATH/.$NAME/$IWAD"

RA_CONF="$(GET_VAR "device" "storage/rom/mount")/MUOS/retroarch/retroarch.cfg"

sed -i -e '/^system_directory/d' \
	-e '/^input_remapping_directory/d' \
	-e '/^rgui_config_directory/d' \
	-e '/^savefile_directory/d' \
	-e '/^savestate_directory/d' \
	-e '/^screenshot_directory/d' "$RA_CONF"

{
	echo "system_directory = \"/run/muos/storage/bios\""
	echo "input_remapping_directory = \"/run/muos/storage/info/config/remaps\""
	echo "rgui_config_directory = \"/run/muos/storage/info/config\""
	echo "savefile_directory = \"/run/muos/storage/save/file\""
	echo "savestate_directory = \"/run/muos/storage/save/state\""
	echo "screenshot_directory = \"/run/muos/storage/screenshot\""
} >>"$RA_CONF"

retroarch -v -f -c "$RA_CONF" -L "$(GET_VAR "device" "storage/rom/mount")/MUOS/core/prboom_libretro.so" "$ROMPATH/.$NAME/$IWAD" &
RA_PID=$!

wait $RA_PID
