#!/usr/bin/env ruby

require 'open3'

def exif_data_for(filename)
  Open3.popen2e("exiftool \"#{filename}\"") do |_, out, wait_thr|
    pid = wait_thr.pid
    exit_status = wait_thr.value
    if exit_status.exitstatus == 0
      out.read
    else
      $stderr.puts "Fetching the exif for '#{filename}' failed."
      $stderr.puts out.read
    end
  end
end

def user_comment_from_exif(exif)
  exif.split("\n").map { |exif_line|
    if exif_line.include? "User Comment"
      exif_line.match(/^User Comment\s+:\s+(.*)$/m)[1]
    end
  }.compact.join(" ")
end

Dir["**/*.jpg"].each do |f|
  exif = exif_data_for f
  user_comments = user_comment_from_exif exif
  if exif.include? "VSCOcam"
    puts f
    $stderr.puts "#{f} #{user_comments}"
  end
end
