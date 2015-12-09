#!/usr/bin/env ruby

require "json"

puts ARGV

if ARGV.count < 2
  puts "\nUsage: prepare.rb <image set path> <input image path or color started with \\#>"
  puts "\n\n"
  exit(0)
end

asset_catalog_folder = ARGV[0]
if ARGV.count > 2
  input_files = ARGV[1..ARGV.count - 1]
else
  input_file = ARGV[1]
end

# p "argv: #{ARGV.count}"
# p "input_file = #{input_file}"
# p "input_files = #{input_files}"
# p "asset_catalog_folder = #{asset_catalog_folder}"

asset_json_file = File.join asset_catalog_folder, "Contents.json"

if input_file and input_file[0] == "#"
  input_color = input_file
  input_file = nil
end

# remove the old
`rm -rf #{File.join asset_catalog_folder, "*.png"}`

parsed = JSON.parse(File.read(asset_json_file))
puts parsed
images = parsed["images"]
images.each do |image|
  w = 0
  h = 0
  scale = image["scale"].to_i
  size = image["size"]
  if size
    sizes = size.split("x")
    w = sizes[0].to_f
    h = sizes[1].to_f
  else
    puts image
    key = (image["orientation"] or "") + image["idiom"] + (image["subtype"] or "") + ((image["extent"]!="full-screen" ? image["extent"] : "") or "")
    launch_image_size_map = {"portraitiphone736h" => [414,736] ,
      "landscapeiphone736h" => [736,414] ,
      "portraitiphone667h" => [375,667] ,
      "portraitiphone" => [320,480] ,
      "portraitiphoneretina4" => [320,568],
      "portraitipad" => [768,1024],
      "landscapeipad" => [1024,768],
      "portraitipadto-status-bar" => [768,1004],
      "landscapeipadto-status-bar" => [1024,748]
      }
    sizes = launch_image_size_map[key]
    if sizes
      w = sizes[0]
      h = sizes[1]
    else
      puts "#{key} is not supported for now. Add this into the launch_image_size_map in #{__FILE__}"
    end
  end
  if w > 0 and h > 0
    actual_w = (w * scale).to_i
    actual_h = (h * scale).to_i
    filename = scale > 1 ? "#{w.to_i}x#{h.to_i}@#{scale}x.png" : "#{w.to_i}x#{h.to_i}.png"
    filepath = File.join asset_catalog_folder, filename
    if input_files
      file_to_use = input_files[0]
      minDiff = 1000.0
      using_file_w = 0
      using_file_h = 0
      for file in input_files
        info = `identify #{file}`.scan(/\s(\d+)x(\d+)\s/)[0]
        file_w = info[0].to_f
        file_h = info[1].to_f
        diff = (file_w / file_h - actual_w.to_f / actual_h.to_f).abs
        if diff < minDiff
          file_to_use = file
          minDiff = diff
          using_file_w = file_w
          using_file_h = file_h
        end
      end
      crop_cmd = ""
      if using_file_w * actual_h > using_file_h * actual_w
        # file is wider than we want, make it narrower
        crop_cmd = "-gravity Center -crop #{(using_file_h * actual_w / actual_h).round()}x#{using_file_h}+0+0 +repage"
      elsif using_file_w * actual_h < using_file_h * actual_w
        crop_cmd = "-gravity Center -crop #{using_file_w}x#{(using_file_w * actual_h / actual_w).round()}+0+0 +repage"
      end
      cmd = "convert \"#{file_to_use}\" #{crop_cmd} -resize #{actual_w}x#{actual_h}! #{filepath}"
      p cmd
      system cmd
    elsif input_file
      `convert "#{input_file}" -resize #{actual_w}x#{actual_h}! #{filepath}`
    elsif input_color
      `convert -size #{actual_w}x#{actual_h} xc:#{input_color} #{filepath}`
    end
    image["filename"] = filename
  end
end

File.write(asset_json_file, JSON.pretty_generate(parsed))
puts `ls #{asset_catalog_folder}`
puts `cat #{asset_json_file}`

# For itunes store
if asset_catalog_folder.index("AppIcon") and input_file
  `convert "#{input_file}" -resize 1024x1024! #{File.join asset_catalog_folder, "..", "..", "iTunesArtwork@2x.png"}`
  `convert "#{input_file}" -resize 512x512! #{File.join asset_catalog_folder, "..", "..", "iTunesArtwork.png"}`
end
