require 'nfc'
require 'ruby-mpd'
require 'json'
require 'rpi_gpio'

require 'pry'

ctx = NFC::Context.new
dev = ctx.open nil

$mpd = MPD.new
$mpd.connect

file = File.read('/root/norbert-database.json')
database = JSON.parse(file)

statusLED = 12
stopButton = 26
nextButton = 16
previousButton = 13
volumeUpButton = 20
volumeDownButton = 19

RPi::GPIO.set_numbering :bcm

RPi::GPIO.setup statusLED, :as => :output
RPi::GPIO.set_high statusLED

controlButtons = [stopButton, nextButton, previousButton, volumeUpButton, volumeDownButton]

RPi::GPIO.setup statusLED, :as => :output
RPi::GPIO.set_high statusLED

controlButtons.each do |controlButton|
  RPi::GPIO.setup controlButton, :as => :input, :pull => :up
end

def toggle_pause 
  $mpd.pause=($pause_state)
  $pause_state = !$pause_state
end

def set_volume(volume)
  $mpd.volume=(volume)
end

def increase_volume
  if $current_volume <= 98
    $current_volume += 2
    set_volume($current_volume)
  end
end

def decrease_volume
  if $current_volume >= 50
    $current_volume -= 2
    set_volume($current_volume)
  end
end

$currently_playing_uuid = nil
$pause_state = true
$current_volume = 70
set_volume($current_volume)
$mpd.stop
$mpd.clear

loop do
  card_uuid = dev.poll.to_s
  if card_uuid != '-90'
    database.each do |entry|
      if entry['card_uuid'] == card_uuid && card_uuid != $currently_playing_uuid
        $currently_playing_uuid = card_uuid
        $mpd.stop
        $mpd.clear
        $mpd.where({album: entry['album']}, {add: true})
        $mpd.play
      end
      "Card: #{card_uuid}"
    end
  end
  toggle_pause if RPi::GPIO.low? stopButton
  $mpd.next if RPi::GPIO.low? nextButton
  $mpd.previous if RPi::GPIO.low? previousButton
  increase_volume() if RPi::GPIO.low? volumeUpButton
  decrease_volume() if RPi::GPIO.low? volumeDownButton
end
