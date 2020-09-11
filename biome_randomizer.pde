public class biome_randomizer {
  
  public String sketch_path = "";
  
  public boolean randomize_tags;
  public boolean randomize_surface;
  public boolean randomize_base;
  public boolean randomize_features;
  
  public JSONArray tags;
  public String[] blocks;
  
  // used to make sure features can generate on randomized surfaces.
  public JSONArray top_blocks;
  public JSONArray foundation_blocks;
  
  public JSONObject feature_rule_categories;
  
  public biome_randomizer(boolean randomize_tags, boolean randomize_surface, boolean randomize_base, boolean randomize_features) {
    sketch_path = ""; 
    String[] path_apart = split(sketchPath(),"\\");
    for (int i = 0; i < path_apart.length; i++) sketch_path += path_apart[i]+"/";
    this.randomize_tags = randomize_tags;
    this.randomize_surface = randomize_surface;
    this.randomize_base = randomize_base;
    this.randomize_features = randomize_features;
    tags = loadJSONArray(sketch_path+"generator_files/biome_tags.json");
    blocks = loadStrings(sketch_path+"generator_files/blocks.txt");
    feature_rule_categories = loadJSONObject(sketch_path+"generator_files/feature_ids.json");
    top_blocks = new JSONArray();
    foundation_blocks = new JSONArray();
  }
  public biome_randomizer() {
    this(true,true,true,true);
  }
  
  
  public String get_random_block() {
    int chosen_block = (int)(Math.random()*blocks.length);
    return blocks[chosen_block];
  }
  
  public String get_biome_tag() {
    int chosen_tag = (int)(Math.random()*tags.size());
    return tags.getString(chosen_tag);
  }
  
  
  public void randomize_biomes() {
    String[] biome_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/biomes");
    JSONObject[] biome_obj = new JSONObject[biome_file_names.length];
    
    for (int i = 0; i < biome_file_names.length; i ++) {
      biome_obj[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/biomes/"+biome_file_names[i]);
      JSONObject biome = biome_obj[i].getJSONObject("minecraft:biome");
      JSONObject components = biome.getJSONObject("components");
      if (components.hasKey("minecraft:surface_parameters") == true) {
        JSONObject surface_parameters = components.getJSONObject("minecraft:surface_parameters");
        if (randomize_surface == true) {
          surface_parameters.setString("sea_floor_material",get_random_block());
          surface_parameters.setString("mid_material",get_random_block());
          String top = get_random_block();
          surface_parameters.setString("top_material",top);
          top_blocks.setString(top_blocks.size(), top);
        }
        if (randomize_base == true) {
          String foundation = get_random_block();
          surface_parameters.setString("foundation_material",foundation);
          foundation_blocks.setString(foundation_blocks.size(),foundation);
        }
      }
        if (randomize_tags == true)
          for (int count = (int)(Math.random()*10)+3; count > 0; count --) 
            components.setJSONObject(get_biome_tag(), new JSONObject());
      saveJSONObject(biome_obj[i],sketch_path+"generated_files/behavior_pack/biomes/"+biome_file_names[i]);
    }
    if (randomize_surface == true || randomize_base == true) {
      filter_block_list();
      ensure_spawns();
    }
    if (randomize_base == true || randomize_surface == true || randomize_features == true) {
      proof_features();
    }
      
  }
  
  //removes duplicates from top_blocks and foundation_blocks.
  private void filter_block_list() {
    JSONArray checked_tops = new JSONArray();
    for (int i = 0; i < top_blocks.size(); i ++) {
      if (in_string_JSONArray(checked_tops,top_blocks.getString(i)) == true) {
          top_blocks.remove(i);
          i--;
      } else checked_tops.setString(checked_tops.size(),top_blocks.getString(i));
    }
    JSONArray checked_founds = new JSONArray();
    for (int i = 0; i < foundation_blocks.size(); i ++) {
      if (in_string_JSONArray(checked_founds,foundation_blocks.getString(i)) == true) {
          foundation_blocks.remove(i);
          i--;
      } else checked_founds.setString(checked_founds.size(),foundation_blocks.getString(i));
    }
  }
  
  private boolean in_string_JSONArray(JSONArray arr, String test) {
    for (int i = 0; i < arr.size(); i ++) 
      if (test.equals(arr.getString(i)))
        return true;
    return false;
  }
  
  // makes the features able to generate on randomized blocks, randomizes them if desired.
  public void proof_features() {
    String[] feature_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/features");
    JSONObject[] feature_file = new JSONObject[feature_file_names.length];
    
    for (int i = 0; i < feature_file_names.length; i ++) {
      feature_file[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/features/"+feature_file_names[i]);
      if (feature_file[i].hasKey("minecraft:ore_feature") == true) {
        JSONObject ore_feature = feature_file[i].getJSONObject("minecraft:ore_feature");
        if (ore_feature.hasKey("may_replace") == true) {
          JSONArray may_replace = new JSONArray();
          for (int j = 0; j < min(foundation_blocks.size(),45); j ++)
            may_replace.setString(may_replace.size(),foundation_blocks.getString(j));
          if (Math.random() < 0.2) 
           may_replace.setString(may_replace.size(),"minecraft:air");
          ore_feature.setJSONArray("may_replace",may_replace);
        }
        if (randomize_features == true && ore_feature.hasKey("places_block") == true) {
          ore_feature.remove("places_block");
          ore_feature.setString("places_block",get_random_block());
        }
        if (randomize_features == true && ore_feature.hasKey("count") == true) {
          ore_feature.remove("count");
          ore_feature.setInt("count",(int)(Math.random()*45)+5);
        }
      } else if (feature_file[i].hasKey("minecraft:single_block_feature") == true) {
        JSONObject single_block_feature = feature_file[i].getJSONObject("minecraft:single_block_feature");
        if (single_block_feature.hasKey("may_replace") == true) 
          single_block_feature.remove("may_replace");
        if (randomize_features == true && single_block_feature.hasKey("places_block") == true ) {
          if (single_block_feature.get("places_block") instanceof JSONObject) {
            JSONObject places_block = single_block_feature.getJSONObject("places_block");
            places_block.setString("name",get_random_block());
            places_block.setJSONObject("states", new JSONObject());
          } else if (single_block_feature.get("places_block") instanceof String) {  
            single_block_feature.setString("places_block", get_random_block());
          }
        }
      } else if (feature_file[i].hasKey("minecraft:tree_feature") == true) {
        JSONObject tree_feature = feature_file[i].getJSONObject("minecraft:tree_feature");
        if (tree_feature.hasKey("may_grow_on") == true) {
          JSONArray may_grow_on = new JSONArray();
          for (int j = 0; j < min(top_blocks.size(),45); j ++) 
            may_grow_on.setString(may_grow_on.size(),top_blocks.getString(j));
          if (Math.random() < 0.2) 
            may_grow_on.setString(may_grow_on.size(),"minecraft:air");
          
          tree_feature.setJSONArray("may_grow_on",may_grow_on);
        }
        if (tree_feature.hasKey("may_grow_through") == true) {
          JSONArray may_grow_through = new JSONArray();
          for (int j = 0; j < min(top_blocks.size(),45); j ++) 
            may_grow_through.setString(may_grow_through.size(),top_blocks.getString(j));
          may_grow_through.setString(may_grow_through.size(),"minecraft:air");
          tree_feature.setJSONArray("may_grow_through",may_grow_through);
        }
        if (randomize_features == true) {
          // trunk randomization
          if (tree_feature.hasKey("trunk") == true) {
            JSONObject trunk = tree_feature.getJSONObject("trunk");
            JSONObject trunk_height = new JSONObject();
            int min = (int)(Math.random()*5.0);
            trunk_height.setInt("range_min",min);
            trunk_height.setInt("range_max",min + (int)(Math.random()*3.0)+1);
            if (trunk.hasKey("trunk_height") == true) 
              trunk.remove("trunk_height");
            trunk.setJSONObject("trunk_height",trunk_height);
            
            if (trunk.hasKey("trunk_block") == true) {
              if (trunk.get("trunk_block") instanceof JSONObject) {
                JSONObject trunk_block = trunk.getJSONObject("trunk_block");
                trunk_block.setString("name",get_random_block());
                trunk_block.setJSONObject("states", new JSONObject());
              } else if (trunk.get("trunk_block") instanceof String) {
                trunk.setString("trunk_block",get_random_block());
              }
            }
            // change what the vines generate to be...
            
            if (trunk.hasKey("trunk_decoration") == true) {
              JSONObject trunk_decoration = trunk.getJSONObject("trunk_decoration");
              trunk_decoration.remove("decoration_block");
              trunk_decoration.setString("decoration_block",get_random_block());
             // trunk_decoration.remove("decoration_chance");
              //trunk_decoration.setFloat("decoration_chance",(float)(Math.random()*100));
            }
            
          }
          
          // these crash the game. No idea why. 
          /*
          if (tree_feature.hasKey("fallen_trunk") == true) {
            JSONObject fallen_trunk = tree_feature.getJSONObject("fallen_trunk");
            JSONObject log_length = new JSONObject();
            int min = (int)(Math.random()*5.0);
            log_length.setInt("range_min",min);
            log_length.setInt("range_max",min + (int)(Math.random()*3.0)+1);
            if (fallen_trunk.hasKey("log_length") == true) 
              fallen_trunk.remove("log_length");
            fallen_trunk.setJSONObject("log_length",log_length);
            
            if (fallen_trunk.hasKey("trunk_block") == true) {
              if (fallen_trunk.get("trunk_block") instanceof JSONObject) {
                JSONObject trunk_block = fallen_trunk.getJSONObject("trunk_block");
                trunk_block.setString("name",get_random_block());
                trunk_block.setJSONObject("states", new JSONObject());
              } else if (fallen_trunk.get("trunk_block") instanceof String) {
                fallen_trunk.setString("trunk_block",get_random_block());
              }
            }
          }
          */
          /*
          if (tree_feature.hasKey("base_block") == true && tree_feature.get("base_block") instanceof JSONArray) {
            JSONArray base_block = tree_feature.getJSONArray("base_block");
            base_block.setString(0,get_random_block());
            tree_feature.setJSONArray("base_block",base_block);
          }
          */
          
          if (tree_feature.hasKey("canopy") == true) {
            JSONObject canopy = tree_feature.getJSONObject("canopy");
            JSONObject canopy_offset = new JSONObject();
            canopy_offset.setInt("min",(int)(Math.ceil(Math.random()*-5)));
            canopy_offset.setInt("max",(int)(Math.random()*5));
            if (canopy.hasKey("canopy_offset") == true)
              canopy.remove("canopy_offset");
            canopy.setJSONObject("canopy_offset",canopy_offset);
           
            if (canopy.hasKey("leaf_block") == true) {
              if (canopy.get("leaf_block") instanceof JSONObject) {
                JSONObject leaf_block = canopy.getJSONObject("leaf_block");
                leaf_block.setString("name",get_random_block());
                leaf_block.setJSONObject("states", new JSONObject());
              } else if (canopy.get("leaf_block") instanceof String) {
                canopy.setString("leaf_block",get_random_block());
              }
            }
            
            if (canopy.hasKey("canopy_decoration")) {
              JSONObject canopy_decoration = canopy.getJSONObject("canopy_decoration");
              canopy_decoration.remove("decoration_block");
              canopy_decoration.setString("decoration_block",get_random_block());
              //canopy_decoration.remove("decoration_chance");
              //canopy_decoration.setFloat("decoration_chance", (float)(Math.random()*100));
            }
          }
        }
      }
      saveJSONObject(feature_file[i], sketch_path+"generated_files/behavior_pack/features/"+feature_file_names[i]);
    }
  }
  
  // changes how feature rules are generated
  public void randomize_feature_rules() {
    
    // replace any distribution of plants (flowers/tallgrass) to this, with only small chance not to.
    JSONObject plant_y = new JSONObject();
    plant_y.setString("distribution","uniform");
    JSONArray plant_y_dist = new JSONArray();
    plant_y_dist.setString(0,"query.heightmap(variable.worldx, variable.worldz)");
    plant_y_dist.setString(1,"query.heightmap(variable.worldx, variable.worldz) + 1");
    plant_y.setJSONArray("extent",plant_y_dist);
    
    
    String[] feature_rule_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/feature_rules");
    JSONObject[] feature_rule_obj = new JSONObject[feature_rule_file_names.length];
    for (int i = 0; i < feature_rule_obj.length; i ++) {
      feature_rule_obj[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/feature_rules/"+feature_rule_file_names[i]);
      JSONObject feature_rule = feature_rule_obj[i].getJSONObject("minecraft:feature_rules");
      JSONObject description = feature_rule.getJSONObject("description");
      String identifier = description.getString("identifier");
      if (feature_rule_categories.getJSONObject("ground_plants").hasKey(identifier) && Math.random() < 0.95) {
        JSONObject distribution = feature_rule.getJSONObject("distribution");
        distribution.setJSONObject("y",plant_y);
      }
      else if (feature_rule_categories.getJSONObject("ores").hasKey(identifier)) {
        JSONObject distribution = feature_rule.getJSONObject("distribution");
        JSONObject ore_y = new JSONObject();
        ore_y.setString("distribution","uniform");
        JSONArray ore_y_dist = new JSONArray();
        ore_y_dist.setInt(0,0);
        ore_y_dist.setInt(1,(int)(Math.random()*240)+15);
        ore_y.setJSONArray("extent",ore_y_dist);
        distribution.setJSONObject("y",ore_y);
        distribution.setInt("iterations",(int)(Math.random()*18)+2);
      }
      saveJSONObject(feature_rule_obj[i],sketch_path+"generated_files/behavior_pack/feature_rules/"+feature_rule_file_names[i]);
    }
  }
  public void ensure_spawns() {
    String[] spawn_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/spawn_rules");
    JSONObject[] spawn_files = new JSONObject[spawn_file_names.length];
    for (int i = 0; i < spawn_file_names.length; i ++) {
      spawn_files[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/spawn_rules/"+spawn_file_names[i]);
      JSONObject spawn_rules = spawn_files[i].getJSONObject("minecraft:spawn_rules");
      if (spawn_rules.hasKey("conditions") == true) {
        JSONArray spawn_condition = spawn_rules.getJSONArray("conditions");
        for (int j = 0; j < spawn_condition.size(); j ++) {
          JSONObject s_cond = spawn_condition.getJSONObject(j);
          if (s_cond.hasKey("minecraft:spawns_on_block_filter")) {
            s_cond.remove("minecraft:spawns_on_block_filter");
          }
        }
      }
      saveJSONObject(spawn_files[i],sketch_path+"generated_files/behavior_pack/spawn_rules/"+spawn_file_names[i]);
    }
  }
  // iterates through the biomes and saves the tags to a json
  public void strip_biome_tags() {
    JSONArray biome_tags = new JSONArray();
    
    String[] biome_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/biomes");
    JSONObject[] biome_obj = new JSONObject[biome_file_names.length];
    for (int i = 0; i < biome_file_names.length; i ++) {
      biome_obj[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/biomes/"+biome_file_names[i]);
      JSONObject biome = biome_obj[i].getJSONObject("minecraft:biome");
      JSONObject components = biome.getJSONObject("components");
      String[] comp_keys = (String[])components.keys().toArray(new String[components.size()]);
      if (comp_keys.length > 0) for (int j = 0; j < comp_keys.length; j ++) {
        if (comp_keys[j].indexOf("minecraft:") == -1) {
          biome_tags.setString(biome_tags.size(),comp_keys[j]);
        }
      }
    }
    saveJSONArray(biome_tags,sketch_path+"generator_files/biome_tags.json");
  }
  
  // iterates through the feature rules and saves it to json
  public void strip_feature_rules() {
    JSONArray feature_ids = new JSONArray();
    
    String[] feature_rule_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/feature_rules");
    JSONObject[] feature_rule_obj = new JSONObject[feature_rule_file_names.length];
    for (int i = 0; i < feature_rule_obj.length; i ++) {
      feature_rule_obj[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/feature_rules/"+feature_rule_file_names[i]);
      JSONObject feature_rule = feature_rule_obj[i].getJSONObject("minecraft:feature_rules");
      JSONObject description = feature_rule.getJSONObject("description");
      feature_ids.setString(feature_ids.size(),description.getString("identifier"));
    }
    saveJSONArray(feature_ids,sketch_path+"generator_files/feature_ids.json");
  }
  
  private String[] listFileNames(String dir) {
    File file = new File(dir);
    if (file.isDirectory()) {
      String names[] = file.list();
      return names;
    } else {
    // If it's not a directory
      return null;
    }
  }
}
