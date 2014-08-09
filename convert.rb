require 'bundler'
Bundler.require
Dotenv.load

WEBM_OPTIONS = {
  video_codec: 'libvpx',
  video_bitrate: 1500,
  custom: '-deadline best -qmin 0 -qmax 50 -crf 5',
  threads: 4
}.freeze

MP4_OPTIONS = {
  video_codec: 'libx264',
  video_bitrate: 1500,
  x264_vprofile: "high",
  x264_preset: "slow",
  threads: 4
}.freeze

mediawiki = MediawikiApi::Client.new "http://eng.tekkenpedia.com/api.php"
mediawiki.log_in ENV['LOGIN'], ENV['PASSWORD']

# convert to mp4
Dir["./input/*"].each do |file|
  puts "Converting: #{file}"
  movie = FFMPEG::Movie.new(file)
  transcoded_movie = movie.transcode("./output/#{File.basename(file).chomp(File.extname(file))}.mp4", MP4_OPTIONS)
  puts "Created: #{transcoded_movie.path}"
end

# convert to webm
Dir["./input/*"].each do |file|
  puts "Converting: #{file}"
  movie = FFMPEG::Movie.new(file)
  transcoded_movie = movie.transcode("./output/#{File.basename(file).chomp(File.extname(file))}.webm", WEBM_OPTIONS)
  puts "Created: #{transcoded_movie.path}"
end

# upload to Tekkenpedia
Dir["./output/*"].each do |file|
  puts "Uploading: #{File.basename(file)}"
  mediawiki.upload_image File.basename(file), file, "Automatic movie upload from converter", true
end

# cleanup
Dir["./input/*"].each do |file|
  File.delete(file)
end

Dir["./output/*"].each do |file|
  File.delete(file)
end