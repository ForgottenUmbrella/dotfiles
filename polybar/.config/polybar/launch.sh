#!/usr/bin/env bash
# Restart polybar.

killall polybar
polybar left &
polybar mid &
polybar right &
