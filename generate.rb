# This file generates all the little shit images to be stored on IPFS
# Run with ruby generate.rb
# ImageMagick needs to be installed on the system

def get_special_back_ids(bodypath, faceid, outfitid, accessoryid)
  # Give wings to the demon
  result = {0 => nil}
  result[1] = "./artwork/special_backs/1.png" if outfitid.to_i == 12
  return result
end

def get_special_front_ids(bodypath, faceid, outfitid, accessoryid)
  # Give the staff to the sorcerer
  result = {0 => nil}
  result[1] = "./artwork/special_fronts/1.png" if outfitid.to_i == 7
  return result
end


parts = {}
layers = %w(special_backs bodies faces outfits accessories)
for layer in layers
  Dir.glob("./artwork/#{layer}/*.png") do |path|
    matches = path.match /\.\/artwork\/#{layer}\/(?<partid>.+?)\.png/
    
    parts[layer] ||= {}
    parts[layer][matches[:partid]] = path
  end
end

parts['outfits']['0'] = nil
parts['accessories']['0'] = nil

`mkdir -p generated`
generated_files = {}
for bodyid, bodypath in parts['bodies']
  for faceid, facepath in parts['faces']
    for outfitid, outfitpath in parts['outfits']
      for accessoryid, accessorypath in parts['accessories']
        special_back_ids = get_special_back_ids(bodyid, faceid, outfitid, accessoryid)
        special_front_ids = get_special_front_ids(bodyid, faceid, outfitid, accessoryid)
        for special_back_id, special_back_path in special_back_ids
          for special_front_id, special_front_path in special_front_ids
            id = "#{special_back_id.to_s.rjust(2, '0')}#{bodyid.rjust(2, '0')}#{faceid.rjust(2, '0')}#{outfitid.rjust(2, '0')}#{accessoryid.rjust(2, '0')}#{special_front_id.to_s.rjust(2, '0')}" 
            paths = []
            paths << special_back_path if special_back_id.to_i != 0
            paths << bodypath << facepath
            paths << outfitpath if outfitid.to_i != 0
            paths << accessorypath if accessoryid.to_i != 0
            paths << special_front_path if special_front_id.to_i != 0
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
