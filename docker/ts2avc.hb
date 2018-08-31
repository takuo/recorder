#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-

file = File::expand_path( ARGV[0] )
out  = ARGV[1]
sizeopt = "-w 1280 -l 720"
program = nil
audios = 0
IO::popen("ffmpeg -i '#{file}' 2>&1") do |io|
 while line = io.gets
   begin
     if /Program (\d+)/ =~ line and program.nil?
       program = $1.to_i
     end
     if /Stream #([\d:]+)\[.+?Video/ =~ line
       if /DAR 4:3/ =~ line
         sizeopt = "-w 640 -l 480"
       end
       if /720x480 \[SAR 32:27 DAR 16:9\]/ =~ line
         # sizeopt = "720x480 -aspect 16:9 -flags +ilme+ildct -top -1 -x264opts weightp=0"
         sizeopt = "-w 720 -l 480 "
       end
       if /1440x1080 \[SAR 4:3 DAR 16:9\]/ =~ line
         # sizeopt = "1440x1080 -aspect 16:9 -flags +ilme+ildct -top -1 -x264opts weightp=0"
         sizeopt = "-w 1280 -l 720"
       end
     end
     if /Stream #([\d:]+)\[.+?Audio: aac/ =~ line
       audios += 1
     end
   rescue
   end
 end
end

cmd = [ "HandBrakeCLI -i #{file} -o #{out} -f mp4" ]
cmd.push "--aencoder faac -aq 110 --encoder x264 -q 23.0"
cmd.push "-O --custom-anamorphic --keep-display-aspect"
cmd.push sizeopt
if audios >= 1
 a = (1..audios).to_a.join(",")
 cmd.push "-a #{a}"
end
cmd.push "-x direct=auto:weightb=1:weightp=2:mbtree=0:8x8dct=1:keyint=250:bframes=3:b-adapt=1:min-keyint=25:me=umh:merange=32:trellis=2:qpmax=51:qpstep=8:qpmin=16:qcomp=0.60:chroma-qp-offset=0:ref=3:subme=5:deblock=0,0:aq-mode=1:aq-strength=0.5"

command = cmd.join(' ')

print "\nExecute command: #{command}\n\n"
system(command)
exit $?.exitstatus
