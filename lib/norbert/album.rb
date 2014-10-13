class Album

  @@pid = nil
  
  attr_accessor :album_number, :tracks

  def initialize(album_number, music_dir = Dir.home + "/music/")
    @album_number = album_number
    @music_dir = music_dir
    load_tracks

    if album_number == 'q'
      kill_other_procs
      return 0
    end
  end
  
  def play
   if @tracks.size == 0
     return false
   end
   
   kill_other_procs
   
   tracklist = ''
   for track in @tracks
     tracklist += "'#{track}' "
   end  

   @@pid = Process.spawn("mpg123 #{tracklist}", :out => '/dev/null', :err => '/dev/null')
   p @@pid
  end

  private
  def load_tracks
    @tracks = Dir.glob @music_dir + "#{@album_number}/*.mp3"
  end

  def kill_other_procs
    p @@pid
    unless @@pid.nil?
      Process.kill('SIGTERM', @@pid)
      @@pid = nil
    end
  end

end

