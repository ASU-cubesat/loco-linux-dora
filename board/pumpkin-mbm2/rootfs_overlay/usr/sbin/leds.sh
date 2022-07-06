#!/bin/sh

# User LEDS options generally are: none mmc0 mmc1 timer oneshot heartbeat gpio cpu cpu0 default-on

usage="  
  Turn the user LEDs on or off.

  Syntax: leds.sh on|off
  options:
    on    Enable LEDs to standard BeagleBone Black 
          configuration:
              LED 0: heartbeat
              LED 1: mmc0
              LED 2: cpu0
              LED 3: mmc1

    off   Disable LEDs by setting LED 0-3 to 'none'
"

case $1 in

    off)
        # Disable all user LEDS by setting their triggers to none
        echo none > /sys/class/leds/beaglebone\:green\:usr0/trigger
        echo none > /sys/class/leds/beaglebone\:green\:usr1/trigger
        echo none > /sys/class/leds/beaglebone\:green\:usr2/trigger
        echo none > /sys/class/leds/beaglebone\:green\:usr3/trigger
        echo "LEDs off"
        ;;
    on)
        # Enable all user LEDS to their standard BeagleBone Black configuration
        echo heartbeat > /sys/class/leds/beaglebone\:green\:usr0/trigger
        echo mmc0 > /sys/class/leds/beaglebone\:green\:usr1/trigger
        echo cpu0 > /sys/class/leds/beaglebone\:green\:usr2/trigger
        echo mmc1 > /sys/class/leds/beaglebone\:green\:usr3/trigger
        echo "LEDs on"
        ;;
    *)
        echo "Error: Argument \"$1\" not recognized" >&2
        echo "$usage" >&2
esac


