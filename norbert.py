#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import signal
import time
import sys
import subprocess
import glob
import RPi.GPIO as GPIO
import sqlite3 as lite

class Album:

    pid = None
    playing_album = None

    def __init__(self, album_id, con):
        with con:
            cur = con.cursor()
            cur.execute('INSERT INTO AlbumStarts VALUES (?,?)', (album_id, int(time.time()) ))

        self.album_id = album_id

    def album_id():
        self.album_id

    def play(self):
        if Album.pid is not None:
            #os.kill(Album.pid,15)
            subprocess.call(['killall','mpg123'])

        music_directory = '/home/norbert/music/' + self.album_id + '/*.mp3'
        playlist = ''
        for file in sorted(glob.glob(music_directory)):
            playlist += ' "' + file + '"'
        Album.pid = subprocess.Popen(['mpg123 ' + playlist], shell=True, stdout=open('/dev/null', 'w'), stderr=open('/dev/null', 'w')).pid
        Album.playing_album = self.album_id

def main():

    con = lite.connect('norbert.db')

    with con:
        cur = con.cursor()
        cur.execute('CREATE TABLE IF NOT EXISTS AlbumStarts(AlbumNumber INTEGER, StartTime INTEGER)')

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
        a = Album(button_albums[channel], con)
        if a.album_id is not Album.playing_album:
            a.play()

    for input_button in button_albums.keys():
        GPIO.setup(input_button, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.add_event_detect(input_button, GPIO.FALLING, callback=buttonPressed, bouncetime=300)

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

