public class recipe_randomizer {
  
  public String[] items;
  public String sketch_path = "";
  public String[] smelt_types = {"furnace", "smoker", "campfire", "soul_campfire", "blast_furnace"};
  
  public boolean change_results;
  public boolean change_ingredients;
  public boolean change_smelt_input;
  public boolean change_smelt_output;
  public boolean shuffle_smelt_station;
  
  public recipe_randomizer(boolean change_ingredients, boolean change_results, boolean change_smelt_input, boolean change_smelt_output, boolean shuffle_smelt_station) {
    String[] path_apart = split(sketchPath(),"\\");
    for (int i = 0; i < path_apart.length; i++) {
      sketch_path += path_apart[i]+"/";
    }
    items = loadStrings(sketch_path+"generator_files/items.txt");
    this.change_results = change_results;
    this.change_ingredients = change_ingredients;
    this.change_smelt_input = change_smelt_input;
    this.change_smelt_output = change_smelt_output;
    this.shuffle_smelt_station = shuffle_smelt_station;
  }
  public recipe_randomizer(){
    this(false,true,false,true,true);
  };
  
  private String random_item() {
    return items[(int)(Math.random()*items.length)];
  }
  
  
  public void randomize_recipes() {
    String[] recipe_file_names = listFileNames(sketch_path+"generator_files/behavior_pack/recipes");
    JSONObject[] recipe_obj = new JSONObject[recipe_file_names.length];
    
    for (int i = 0; i < recipe_obj.length; i ++) {
      recipe_obj[i] = loadJSONObject(sketch_path+"generator_files/behavior_pack/recipes/"+recipe_file_names[i]);
      if (recipe_obj[i].hasKey("minecraft:recipe_furnace") == true) {
        JSONObject furnace = recipe_obj[i].getJSONObject("minecraft:recipe_furnace");
        if (shuffle_smelt_station == true) {
          JSONArray tags = new JSONArray();
          for (int j = 0; j < smelt_types.length; j ++) {
            if (Math.random() < 0.6) {
              tags.setString(tags.size(),smelt_types[j]);
            }
          }
          furnace.setJSONArray("tags",tags);
        }
        if (change_smelt_input == true) furnace.setString("input",random_item());
        if (change_smelt_output == true) furnace.setString("output",random_item());
      }
      else if (recipe_obj[i].hasKey("minecraft:recipe_shaped") == true) {
        JSONObject shaped = recipe_obj[i].getJSONObject("minecraft:recipe_shaped");
        if (change_ingredients == true) {
          JSONObject map = shaped.getJSONObject("key");
          String[] map_keys = (String[])map.keys().toArray(new String[map.size()]);
          for (int j = 0; j < map_keys.length; j ++) {
            JSONObject ingredient = new JSONObject();
            ingredient.setString("item",random_item());
            map.setJSONObject(map_keys[j],ingredient);
          }
        }
        
        if (change_results == true) {
          if (shaped.get("result") instanceof JSONObject) {
            JSONObject result = new JSONObject();
            result.setString("item",random_item());
            result.setInt("count",(int)(Math.random()*2)+1);
            shaped.setJSONObject("result",result);
          } else {
            shaped.setString("result",random_item());
          }
        }
        
      }
      else if (recipe_obj[i].hasKey("minecraft:recipe_shapeless") == true) {
        JSONObject shapeless = recipe_obj[i].getJSONObject("minecraft:recipe_shapeless");
        
        if (change_ingredients == true) {
        JSONArray ingredients = shapeless.getJSONArray("ingredients");
          for (int j = 0; j < ingredients.size(); j ++) {
            JSONObject ingredient = new JSONObject();
            ingredient.setString("item",random_item());
            ingredients.setJSONObject(j,ingredient);
          }
        }
        
        if (change_results == true) {
          if (shapeless.get("result") instanceof JSONObject) {
            JSONObject result = new JSONObject();
            result.setString("item",random_item());
            result.setInt("count",(int)(Math.random()*2)+1);
            shapeless.setJSONObject("result",result);
          } else {
            shapeless.setString("result",random_item());
          }
        }
      }
      saveJSONObject(recipe_obj[i],sketch_path+"generated_files/behavior_pack/recipes/"+recipe_file_names[i]);
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
