require 'optparse'

DEFAULT_TARGET_SIZE = 1000
DEFAULT_QUALITY = 70
SAMPLING_FACTOR = '4:2:0'
INTERLACE = 'JPEG'
COLOR_SPACE = 'RGB'

options = {}
OptionParser.new do |opts|
    opts.banner = 'Usage: ruby image_resize.rb [options]'

    opts.on('-s', '--source-directory SOURCE', 'Source Directory. Required.') do |v| 
        options[:source] = v 
    end

    opts.on('-d', '--desitination-directory DESTINATION', 'Destination Directory. Required.') do |v| 
        options[:destination] = v 
    end

    opts.on('-t', '--target-size TARGET_SIZE', 'Target Size to resize, default is 1000px.') do |v| 
        options[:target_size] = v
    end

    opts.on('-q', '--quality QUALITY', 'Image quality, default is 70%.') do |v|
        options[:quality] = v
    end

    opts.on('-h', '--help', "Help") do 
        puts opts
        exit
    end
end.parse!

if options[:target_size].nil?
    options[:target_size] = DEFAULT_TARGET_SIZE
end

if options[:quality].nil?
    options[:quality] = DEFAULT_QUALITY
end

p options

if options[:source].nil?
    p 'ERROR: Source directory is missing'
    p 'Please provide source directory'
    exit
end

if !Dir.exist?(options[:source]) 
    p 'ERROR: Source directory not found'
    p 'Please provide a valid path to a directory'
end

if options[:destination].nil? || options[:destination].empty? 
    p 'ERROR: Destination directory is missing'
    p 'Please provide destination directory'
    exit
end

if !Dir.exist?(options[:destination]) 
    Dir.mkdir(options[:destination])
end

Dir.foreach(options[:source]) do |file_name|
    next if file_name == '.' || file_name == '..'
    source_file_path = "#{options[:source]}/#{file_name.gsub(/\s/, '\\ ')}"
    dest_file_path = "#{options[:destination]}/#{file_name.gsub(/\s/, '\\ ').gsub(/.png/, '.jpg')}"

    cmd = "magick #{source_file_path} -resize #{options[:target_size]}x#{options[:target_size]} -sampling-factor #{SAMPLING_FACTOR} -strip -quality #{options[:quality]} -interlace #{INTERLACE} -colorspace #{COLOR_SPACE} #{dest_file_path}"
    p cmd
    fork { exec(cmd) }
end