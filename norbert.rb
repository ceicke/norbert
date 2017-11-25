require 'ruby-mpd'
require 'json'
require 'rpi_gpio'
require 'ruby-nfc'
require 'pry'


$mpd = MPD.new
$mpd.connect

statusLED = 12
$stopButton = 26
$nextButton = 16
$previousButton = 13
$volumeUpButton = 20
$volumeDownButton = 19

RPi::GPIO.set_numbering :bcm

RPi::GPIO.setup statusLED, :as => :output
RPi::GPIO.set_high statusLED

controlButtons = [$stopButton, $nextButton, $previousButton, $volumeUpButton, $volumeDownButton]

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
  if Time.now.hour < 7
    max_volume = 90
  else
    max_volume = 100
  end
  if $current_volume <= max_volume
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
$current_volume = 80
set_volume($current_volume)
$mpd.stop
$mpd.clear


def card_control

  file = File.read('/root/norbert-database.json')
  database = JSON.parse(file)

  readers = NFC::Reader.all
  readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
    card_uuid = tag.uid_hex.upcase
    database.each do |entry|
      if entry['card_uuid'] == card_uuid && (card_uuid != $currently_playing_uuid or $mpd.stopped?)
        $currently_playing_uuid = card_uuid
        $mpd.stop
        $mpd.clear
        $mpd.where({album: entry['album']}, {add: true})
        $mpd.play
      end
    end
  end
end

def button_control
  while(true)
    toggle_pause if RPi::GPIO.low? $stopButton
    $mpd.next if RPi::GPIO.low? $nextButton
    $mpd.previous if RPi::GPIO.low? $previousButton
    increase_volume() if RPi::GPIO.low? $volumeUpButton
    decrease_volume() if RPi::GPIO.low? $volumeDownButton
    sleep(0.2)
  end
end

button_thread = Thread.new{button_control()}
card_thread = Thread.new{card_control()}
button_thread.join
card_thread.join
