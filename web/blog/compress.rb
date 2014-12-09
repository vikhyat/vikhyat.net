#!/usr/bin/env ruby
file = ARGV[0]

content = false

if not File.directory? file

  initial = `wc -c #{file}`.split[0].to_i

  if file =~ /\.html$/

    # Compress the HTML
    content = `cat #{file} | htmlcompressor --compress-js --compress-css --js-compressor closure`

  elsif file =~ /\.css$/

    # Compress the CSS
    content = `cat #{file} | yuicompressor --type css`

  elsif file =~ /\.js$/

    # Compress the JS
    content = `cat #{file} | closure-compiler`

  elsif file =~ /\.png$/

    # Compress the PNG
    append = (rand 999).to_s + (rand 999).to_s
    newfile = file + append
    system "pngcrush #{file} #{newfile} 2> /dev/null 1> /dev/null"
    system "mv #{newfile} #{file}"

  end

  if content
    File.open(file, 'w') {|f| f.puts content }
  end

  final = `wc -c #{file}`.split[0].to_i

  puts "Done compressing: #{file}. (Saving: #{sprintf "%.2f", (initial-final)*100.0/initial}%)"
end
