#!/usr/bin/env python

import os
import signal
import time
import sys
import RPi.GPIO as GPIO

def main():

    GPIO.setmode(GPIO.BCM)

    # Status LED
    GPIO.setup(12, GPIO.OUT)
    GPIO.output(12, GPIO.HIGH)

    # Buttons
    button_albums = {}
    button_albums[13] = '1'
    button_albums[16] = '2'
    button_albums[19] = '3'
    button_albums[20] = '4'
    button_albums[26] = '5'

    def buttonPressed(channel):
        print "Button pressed: " + str(channel)

    for input_button in button_albums.keys():
        GPIO.setup(input_button, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.add_event_detect(input_button, GPIO.FALLING, callback=buttonPressed, bouncetime=300)

    while True:
        time.sleep(0.0)


def exit_gracefully(signum, frame):
    GPIO.output(12, GPIO.LOW)
    GPIO.cleanup()
    sys.exit(1)


if __name__=="__main__":
    signal.signal(signal.SIGINT, exit_gracefully)
    main()

