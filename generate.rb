# This file generates all the little shit images to be stored on IPFS
# Run with ruby generate.rb
# ImageMagick needs to be installed on the system

def special_back_paths(bodypath, facepath, outfitpath, accessorypath)
  # Give wings to the demon
  result = [nil]
  result << "./artwork/special_backs/1.png" if outfitpath && outfitpath.include?('/12.png')
  return result
end

def special_front_paths(bodypath, facepath, outfitpath, accessorypath)
  # Give the staff to the sorcerer
  result = [nil]
  result << "./artwork/special_fronts/1.png" if outfitpath && outfitpath.include?('/7.png')
  return result
end


parts = {}
layers = %w(special_backs bodies faces outfits accessories)
for layer in layers
  Dir.glob("./artwork/#{layer}/*.png") do |path|
    matches = path.match /\.\/artwork\/#{layer}\/(?<partid>.+?)\.png/
    
    parts[layer] ||= []
    parts[layer] << path
  end
end

parts['outfits'] << nil
parts['accessories'] << nil

`mkdir -p generated`
id = 0
generated_files = {}
for bodypath in parts['bodies']
  for facepath in parts['faces']
    for outfitpath in parts['outfits']
      for accessorypath in parts['accessories']
        for special_back_path in special_back_paths(bodypath, facepath, outfitpath, accessorypath)
          for special_front_path in special_front_paths(bodypath, facepath, outfitpath, accessorypath)
            id += 1
            paths = []
            paths << special_back_path if special_back_path
            paths << bodypath << facepath
            paths << outfitpath if outfitpath
            paths << accessorypath if accessorypath
            paths << special_front_path if special_front_path
            arg = paths.map { |path| "#{path} -composite "}.join
            path = "./generated/#{id}.png"
            `convert -size 1024x1024 xc:none #{arg} #{path}`
            generated_files[id] = path
          end
        end
      end
    end
  end
end


puts "generated #{generated_files.size} little shits"
