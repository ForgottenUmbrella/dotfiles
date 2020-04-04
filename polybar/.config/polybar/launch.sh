#!/usr/bin/env bash
# Restart polybar.

killall polybar
#polybar main &
polybar left &
polybar mid &
polybar right &
