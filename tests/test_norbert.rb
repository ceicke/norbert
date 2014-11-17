require "./lib/norbert.rb"
require "test/unit"

class TestNorbert < Test::Unit::TestCase

  def setup
    @dir = '/tmp/music/'
    system 'mkdir', '-p', "#{@dir}/1"
    system 'touch', "#{@dir}/1/01.mp3"
    system 'touch', "#{@dir}/1/02.mp3"
  end

  def teardown
    system 'rm', '-rf', @dir
  end

  def test_album_number
    a = Album.new('1',@dir)
    assert_equal('1', a.album_number)
  end

  def test_track_loading
    a = Album.new('1',@dir)
    assert_equal(2, a.tracks.size)
  end

  def test_track_loading_of_unknown_album
    a = Album.new('2',@dir)
    assert_equal(0, a.tracks.size)
  end

  def test_playback
    a = Album.new('1',@dir)
    @pid = a.play
    assert_not_nil(@pid)
  end

  def test_stop
    a = Album.new('1',@dir)
    @pid = a.play
    a = Album.new('q',@dir)
    @pid = a.play
    assert_equal(false, @pid)
  end

end
