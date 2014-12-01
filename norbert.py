#!/usr/bin/env python

import os
import signal
import time
import sys
import subprocess
import glob
import RPi.GPIO as GPIO

class Album:

    pid = None

    def __init__(self, album_id):
        self.album_id = album_id

    def play(self):
        if Album.pid is not None:
            #os.kill(Album.pid,15)
            subprocess.call(['killall','mpg123'])

        music_directory = '/home/norbert/music/' + self.album_id + '/*.mp3'
        playlist = ''
        for file in glob.glob(music_directory):
            playlist += ' "' + file + '"'
        Album.pid = subprocess.Popen(['mpg123 ' + playlist], shell=True, stdout=open('/dev/null', 'w'), stderr=open('/dev/null', 'w')).pid

def main():

    GPIO.setmode(GPIO.BCM)

    # Status LED
    GPIO.setup(12, GPIO.OUT)
    GPIO.output(12, GPIO.HIGH)

    # Buttons
    input_buttons = [16, 19, 21, 20, 26]

    for input_button in input_buttons:
        GPIO.setup(input_button, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    #GPIO.setup(16, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    #GPIO.setup(21, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    #GPIO.setup(20, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    #GPIO.setup(19, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    #GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    def buttonPressed(channel):
        a = None
        if channel == 21:
            a = Album('1')
        elif channel == 16:
            a = Album('2')
        elif channel == 20:
            a = Album('3')
        elif channel == 19:
            a = Album('4')
        elif channel == 26:
            a = Album('5')
        if a is not None:
            a.play()
    for input_button in input_buttons:
        GPIO.add_event_detect(input_button, GPIO.FALLING, callback=buttonPressed, bouncetime=300)

    #GPIO.add_event_detect(16, GPIO.FALLING, callback=buttonPressed, bouncetime=300)
    #GPIO.add_event_detect(21, GPIO.FALLING, callback=buttonPressed, bouncetime=300)
    #GPIO.add_event_detect(20, GPIO.FALLING, callback=buttonPressed, bouncetime=300)
    #GPIO.add_event_detect(19, GPIO.FALLING, callback=buttonPressed, bouncetime=300)
    #GPIO.add_event_detect(26, GPIO.FALLING, callback=buttonPressed, bouncetime=300)

    while True:
        time.sleep(0.0)


def exit_gracefully(signum, frame):
    GPIO.output(12, GPIO.LOW)
    GPIO.cleanup()
    if Album.pid is not None:
        #os.kill(Album.pid,15)
        subprocess.call(['killall','mpg123'])
    sys.exit(1)


if __name__=="__main__":
    signal.signal(signal.SIGINT, exit_gracefully)
    main()

