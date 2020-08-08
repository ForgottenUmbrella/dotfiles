#!/bin/sh
# (Re)start polybar.

killall polybar
#polybar main &
polybar left &
polybar mid &
polybar right &
