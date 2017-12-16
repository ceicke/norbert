require 'ruby-mpd'
require 'json'
require 'rpi_gpio'
require 'ruby-nfc'
require 'syslog/logger'
require 'active_record'

require_relative 'album'
require_relative 'webserver'

BASE_DIR = '/root/norbert/'

$log = Syslog::Logger.new 'Norbert'
$log.info 'Norbert is starting'

$mpd = MPD.new
$mpd.connect

$log.info 'MPD connected'

$statusLED = 12
$stopButton = 26
$nextButton = 16
$previousButton = 13
$volumeUpButton = 20
$volumeDownButton = 19

RPi::GPIO.set_numbering :bcm

RPi::GPIO.set_warnings(false)

RPi::GPIO.setup $statusLED, :as => :output
RPi::GPIO.set_high $statusLED

controlButtons = [$stopButton, $nextButton, $previousButton, $volumeUpButton, $volumeDownButton]

controlButtons.each do |controlButton|
  RPi::GPIO.setup controlButton, :as => :input, :pull => :up
end

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  BASE_DIR + 'norbert.sqlite3.db'
)

def toggle_pause
  $log.info "Toggling pause to #{!$pause_state}"
  $mpd.pause=($pause_state)
  $pause_state = !$pause_state
end

def set_volume(volume)
  $log.info "Setting volume to #{volume}"
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
$current_configuration_card_uuid = nil
$pause_state = true
$current_volume = 80
set_volume($current_volume)
$mpd.stop
$mpd.clear

def blink
  while(true)
    RPi::GPIO.set_high $statusLED
    sleep(1)
    RPi::GPIO.set_low $statusLED
    sleep(1)
  end
end

def webserver
  Webserver.run!
end

def card_control(config_mode = false)

  $log.info 'Card control thread started'

  begin

    readers = NFC::Reader.all
    readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
      card_uuid = tag.uid_hex.upcase
      if !config_mode
        album = Album.where(card_uuid: card_uuid).first
        if album && (card_uuid != $currently_playing_uuid or $mpd.stopped?)
          $log.info "Starting new playback for card #{card_uuid}: #{album.album_name}"
          $currently_playing_uuid = card_uuid
          $mpd.stop
          $mpd.clear
          $mpd.where({album: album.album_name}, {add: true})
          $mpd.play
          album.update_attributes(listen_count: album.listen_count + 1)
        else
          $log.info "Unknown card: #{card_uuid}"
        end
      else
        $log.info "Card: #{card_uuid}"
        fork{ exec 'mpg123','-q', BASE_DIR + 'media/chime.mp3' }
        $current_configuration_card_uuid = card_uuid
      end
    end
  rescue Exception => e
    $log.info "Exception: #{e}"
  end
end

def button_control
  $log.info 'Button control thread started'

  begin
  
    while(true) 
      toggle_pause if RPi::GPIO.low? $stopButton
      $mpd.next if RPi::GPIO.low? $nextButton
      $mpd.previous if RPi::GPIO.low? $previousButton
      increase_volume() if RPi::GPIO.low? $volumeUpButton
      decrease_volume() if RPi::GPIO.low? $volumeDownButton
      sleep(0.2)
    end

  rescue Exception => e
    $log.info "Exception: #{e}"
  end
end

if RPi::GPIO.low? $stopButton
  $log.info 'Entering configuration mode'
  fork{ exec 'mpg123','-q', BASE_DIR + 'media/chime_long.mp3' }
  blink_thread = Thread.new{blink()}
  webserver_thread = Thread.new{webserver()}
  card_control_thread = Thread.new{card_control(true)}
  blink_thread.join
  webserver_thread.join
  card_control_thread.join
end

button_thread = Thread.new{button_control()}
card_thread = Thread.new{card_control()}
button_thread.join
card_thread.join
