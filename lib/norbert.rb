require 'norbert/album'

class Norbert

  def initialize
    @current_album = nil
  end

  def run
    while true
      print 'Enter album number: '
      album_number = gets
      album_number.chomp!

      if @current_album != album_number
        a = Album.new(album_number)
        if a.play
          @current_album = a.album_number
        end
      end
    end
  end
end

