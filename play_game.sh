#!/bin/sh

killall "RobloxStudio"
sleep 0.1
rm -fv game.rbxl* game?.rbxl*
sleep 0.1
rojo build -o game.rbxl
sleep 0.1
open /Applications/RobloxStudio.app game.rbxl
