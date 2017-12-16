require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'fileutils'
require 'securerandom'

class Webserver < Sinatra::Base

  set :environment, :development
  set :bind, '0.0.0.0'
  set :port, 80
  set :sessions, true
  set :public_folder, Proc.new { File.join(root, "webserver", "public") }
  set :views, Proc.new { File.join(root, "webserver", "views") }
  register Sinatra::Flash
  
  get '/' do
    @albums = Album.all.order(:album_name)
    haml :index, format: :html5, layout: :layout
  end

  get '/new' do
    @uuid = $current_configuration_card_uuid
    haml :new, format: :html5, layout: :layout
  end

  post '/upload' do
    dirname = "/var/lib/mpd/music/#{params[:card_uuid]}"
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    $log.info "New file received: #{params[:file][:filename]}"

    filename = SecureRandom.uuid + '.mp3'
    file = params[:file][:tempfile]

    File.open("#{dirname}/#{filename}", 'wb') do |f|
      f.write(file.read)
    end

    if Album.where(card_uuid: params[:card_uuid]).length == 0
      $log.info "Creating new album for card: #{params[:card_uuid]}"
      Album.create(card_uuid: params[:card_uuid], album_name: params[:album_title], listen_count: 0)
    end
    
    flash[:success] = 'File successfully uploaded!'
    $log.info "Success! File: #{dirname}/#{filename}"

    $mpd.rescan

    status 201
    body ''
  end
end
