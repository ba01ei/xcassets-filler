#!/usr/bin/env ruby

require "json"

puts ARGV

if ARGV.count < 2
  puts "\nUsage: prepare.rb <input image path or color started with \\#> <image set path>"
  puts "\n\n"
  exit(0)
end

input_file = ARGV[0]
asset_catalog_folder = ARGV[1]

asset_json_file = File.join asset_catalog_folder, "Contents.json"

if input_file[0] == "#"
  input_color = input_file
  input_file = nil
end

# remove the old
`rm -rf #{File.join asset_catalog_folder, "*.png"}`

parsed = JSON.parse(File.read(asset_json_file))
images = parsed["images"]
images.each do |image|
  w = 0
  h = 0
  scale = image["scale"].to_i
  size = image["size"]
  if size
    sizes = size.split("x")
    w = sizes[0].to_i
    h = sizes[1].to_i
  else
    key = image["orientation"] + image["idiom"] + (image["subtype"] or "") + (image["extent"]!="full-screen" ? image["extent"] : "")
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
    actual_w = w * scale
    actual_h = h * scale
    filename = scale > 1 ? "#{w}x#{h}@#{scale}x.png" : "#{w}x#{h}.png"
    filepath = File.join asset_catalog_folder, filename
    if input_file
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
