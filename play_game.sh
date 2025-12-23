#!/bin/sh

killall "RobloxStudio"
sleep 0.1
rm -fv game.rbxl* game?.rbxl*
sleep 0.1
rojo build -o game.rbxl
sleep 0.1
if [ ! -f game.rbxl ]; then
	echo "Error: game.rbxl was not generated. Aborting launch."
	exit 1
fi
open /Applications/RobloxStudio.app game.rbxl
