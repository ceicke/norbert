require 'norbert/album'
require 'pi_piper'
include PiPiper

class Norbert

  def initialize
    @current_album = nil

    PiPiper::Pin.new(:pin => 21, :direction => :in, :pull => :up)
    PiPiper::Pin.new(:pin => 16, :direction => :in, :pull => :up)
  end

  def run

    after :pin => 21, :goes => :low do
      unless @current_album == 1
        a = Album.new('1')
        if a.play
          @current_album = a.album_number
        end
      end
    end

    after :pin => 16, :goes => :low do
      unless @current_album == 2
        a = Album.new('2')
        if a.play
          @current_album = a.album_number
        end
      end
    end

    PiPiper.wait

  end
end
