#!/usr/bin/env sh
D=$(realpath $(dirname $0))
WD=$(pwd)

echo "Creating LDJAM56.love in current directory"
cd $D
zip -r $WD/LDJAM56.love main.lua conf.lua game/