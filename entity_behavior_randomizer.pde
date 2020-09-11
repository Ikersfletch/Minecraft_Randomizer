public class entity_behavior_randomizer {
  
  public JSONObject components;
  public String sketch_path;
  public boolean randomize_player;
  public boolean ensure_random_loot;
  
  public boolean logic;
  public boolean blaze_rods_obtainable;
  public boolean ender_eyes_obtainable;
  
  public entity_behavior_randomizer(boolean randomize_player, boolean ensure_random_loot) {
    sketch_path = ""; 
    String[] path_apart = split(sketchPath(),"\\");
    for (int i = 0; i < path_apart.length; i++) {
      sketch_path += path_apart[i]+"/";
    }
    components = loadJSONObject(sketch_path+"generator_files/components.json");
    this.randomize_player = randomize_player;
    this.ensure_random_loot = ensure_random_loot;
  }
  public entity_behavior_randomizer() {
    this(false,true);
  }
  
  public void strip_components() {
    // reads all the components from the component & component groups in the entity files of the provided pack, and saves it to file.
    String[] entity_names = listFileNames(sketch_path+"generator_files/behavior_pack/entities");
    JSONObject[] entity_files = new JSONObject[entity_names.length];
    JSONObject new_components = new JSONObject();
    
    for (int i = 0; i < entity_files.length; i ++) {
      entity_files[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/entities/"+entity_names[i]);
      JSONObject entity = entity_files[i].getJSONObject("minecraft:entity");
      //strip components
      if (entity.hasKey("components")) {
        JSONObject e_components = entity.getJSONObject("components");
        String[] e_component_keys = (String[])e_components.keys().toArray(new String[e_components.size()]);
        for (int j = 0; j < e_component_keys.length; j ++) {
          // make sure it's an object...
          if (e_components.get(e_component_keys[j]) instanceof JSONObject) {
            // for every component
            if (new_components.hasKey(e_component_keys[j])) {
              // add to pre-existing array
              JSONArray comp = new_components.getJSONArray(e_component_keys[j]);
              comp.setJSONObject(comp.size(),e_components.getJSONObject(e_component_keys[j]));
            } else {
              // or just create a new place to put it
              JSONArray comp = new JSONArray();
              comp.setJSONObject(comp.size(),e_components.getJSONObject(e_component_keys[j]));
              new_components.setJSONArray(e_component_keys[j],comp);
            }
          }
        }
      }
      //strip comopnents in component groups
      if (entity.hasKey("component_groups")) {
        JSONObject e_component_groups = entity.getJSONObject("component_groups");
        String[] e_component_group_keys = (String[])e_component_groups.keys().toArray(new String[e_component_groups.size()]);
        for (int j = 0; j < e_component_group_keys.length; j ++) {
          // for every component group
          JSONObject group = e_component_groups.getJSONObject(e_component_group_keys[j]);
          String[] group_keys = (String[])group.keys().toArray(new String[group.size()]);
          // make sure it's an object...
          for (int k = 0; k < group_keys.length; k ++) {
            if (group.get(group_keys[k]) instanceof JSONObject) {
              // for every component in a group
              if (new_components.hasKey(group_keys[k])) {
               // add to pre-existing array
                JSONArray comp = new_components.getJSONArray(group_keys[k]);
                comp.setJSONObject(comp.size(),group.getJSONObject(group_keys[k]));
              } else {
               // or just create a new place to put it
                JSONArray comp = new JSONArray();
                comp.setJSONObject(comp.size(),group.getJSONObject(group_keys[k]));
                new_components.setJSONArray(group_keys[k],comp);
              }
            }
          }
        }
      }
    }
    // yes, this does overwrite it. it's good to pick out some key 'offenders' when it comes to functionality, such as the projectile component.
    saveJSONObject(new_components,sketch_path+"generator_files/components.json");
    this.components = loadJSONObject(sketch_path+"generator_files/components.json");
  }
  
  public void shuffle_entity_components() {
    String[] entity_names = listFileNames(sketch_path+"generator_files/behavior_pack/entities");
    JSONObject[] entity_files = new JSONObject[entity_names.length];
    String[] component_keys = (String[])components.keys().toArray(new String[components.size()]);
    for (int i = 0; i < entity_files.length; i ++) {
      entity_files[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/entities/"+entity_names[i]);
      JSONObject entity = entity_files[i].getJSONObject("minecraft:entity");
      JSONObject description = entity.getJSONObject("description");
      String identifier = description.getString("identifier");
      if ((identifier.equals("minecraft:player") == false) || (identifier.equals("minecraft:player") == true && randomize_player == true)) {
        JSONObject e_components = entity.getJSONObject("components");
        for (int count = (int)(Math.random()*20) + 5; count > 0; count --) {
           int chosen_comp = (int)(Math.random()*component_keys.length);
           JSONArray comp = components.getJSONArray(component_keys[chosen_comp]);
           int chosen_variant = (int)(Math.random()*comp.size());
           e_components.setJSONObject(component_keys[chosen_comp],comp.getJSONObject(chosen_variant));
        }
        // specifically randomize loot tables.
        if (ensure_random_loot == true) {
          JSONArray loot = components.getJSONArray("minecraft:loot");
          int chosen_loot = (int)(Math.random()*loot.size());
          e_components.setJSONObject("minecraft:loot",loot.getJSONObject(chosen_loot));
        }
        if (entity.hasKey("component_groups")) {
          JSONObject groups = entity.getJSONObject("component_groups");
          String[] group_keys = (String[])groups.keys().toArray(new String[groups.size()]);
          for (int j = 0; j < group_keys.length; j ++) {
            if (groups.get(group_keys[j]) instanceof JSONObject) {
              JSONObject group = groups.getJSONObject(group_keys[j]);
              for (int count = (int)(Math.random()*5) + 3; count > 0; count --) {
                 int chosen_comp = (int)(Math.random()*components.size());
                 if(!(component_keys[chosen_comp].equals("minecraft:behavior.skeleton_horse_trap") && (identifier.equals("minecraft:skeleton") || identifier.equals("minecraft:skeleton_horse")))) {
                   JSONArray comp = components.getJSONArray(component_keys[chosen_comp]);
                   int chosen_variant = (int)(Math.random()*comp.size());
                   group.setJSONObject(component_keys[chosen_comp],comp.getJSONObject(chosen_variant));
                 }
              }
            }
          }
        }
      }
      saveJSONObject(entity_files[i],sketch_path+"generated_files/behavior_pack/entities/"+entity_names[i]);
    }
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
