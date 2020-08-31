

// biome arguments
boolean randomize_tags = true;
boolean randomize_surface = true;
boolean randomize_base = true;
boolean randomize_features = true;

// entity arguments
boolean randomize_player = true;
boolean ensure_random_loot = true;

// recipe arguments
boolean change_results = true;
boolean change_ingredients = false;
boolean change_smelt_input = false;
boolean change_smelt_output = true;
boolean shuffle_smelt_station = true;

void setup() {
  size(300,600);
  PImage icon = loadImage("icon.png");
  surface.setIcon(icon);
};

boolean pressed = false;
boolean held = false;

String hovering_text = "";
int hover_id = -1;

boolean generated = false;

boolean checkbox(int x, int y, boolean value, String hovering_text_instance,int id) {
  pushStyle();
    stroke(0);
    fill(255);
    if (abs(mouseX-x) < 10 && abs(mouseY-y) < 10) {
      stroke(50,0,255);
      fill(200,220,255);
      hover_id = id;
      if (generated == false) hovering_text = hovering_text_instance;
    } else if (hover_id == id) {
      stroke(150,0,255);
      fill(230,240,255);
    }
    rect(x-10,y-10,20,20);
    if (value == true) {
      line(x-7,y,x-2,y+6);
      line(x-2,y+6,x+7,y-7);
    }
  popStyle();
  if (pressed == true && held == false) {
    if (abs(mouseX-x) < 10 && abs(mouseY-y) < 10) {
      return !value;
    }
  }
  return value;
}
void menu() {
  background(200,220,230);
  
  pushStyle();
    noStroke();
    fill(170,200,220);
    rect(0,0,300,30);
    fill(230);
    rect(0,436,300,114);
  popStyle();
  
  
  pushStyle();
    fill(255);
    stroke(0);
    if (abs(mouseX-(width/2)) < 60 && abs(mouseY-575) < 20) {
      stroke(50,0,255);
      fill(200,220,255);
      if (generated == false && pressed == true && held == false) {
        randomize();
        generated = true;
        hovering_text = "Success! It\'s recommended to clear the \'generated_files\' folder after the .mcpack is installed into minecraft, so that leftover data doesn\'t spill into your next iterations!";
      } else if (pressed == true && held == false) {
        exit();
      }
      if (hover_id != 11)
        if (generated == false) hovering_text = "Generates a randomized behavior pack with the above settings taken into consideration. Make sure the \'generated_files\' folder is cleared before generating.";
        else hovering_text = "Success! It\'s recommended to clear the \'generated_files\' folder after the .mcpack is installed into minecraft, so that leftover data doesn\'t spill into your next iterations!";
        hover_id = 11;
    } else if (hover_id == 11) {
      stroke(150,0,255);
      fill(230,240,255);
    }
    rect(width/2 - 60, 555 ,120,40);
  popStyle();
  
  pushStyle();
    fill(220,230,240);
    noStroke();
    rect(-1,31,305,24);
    rect(-1,176,305,24);
    rect(-1,261,305,24);
  popStyle();
  
  pushStyle();
    textSize(20);
    fill(0);
    text("Minecraft Randomizer",5,25);
    pushStyle();
      textAlign(CENTER,CENTER);
      
      if (abs(mouseX-(width/2)) < 60 && abs(mouseY-575) < 20) {
        fill(50,0,255);
      } else if (hover_id == 11) {
        fill(150,0,255);
      }
      text((generated == false)? "GENERATE" : "CLOSE",width/2,572);
    popStyle();
    textSize(15);
    text("World Generation Options",5,50);
    text("Entity Behavior Options",5,195);
    text("Crafting Recipe Options",5,280);
    textSize(12);
    text("Randomize biome tags",35,75);
    text("Randomize biome surfaces",35,105);
    text("Randomize biome foundations",35,135);
    text("Randomize features",35,165);
    text("Randomize player attributes",35,220);
    text("Randomize mob drops",35,250);
    text("Randomize crafting ingredients",35,305);
    text("Randomize crafting results",35,335);
    text("Randomize smeltable items",35,365);
    text("Randomize smelting results",35,395);
    text("Shuffle smelting stations",35,425);
    
    text(hovering_text,5,450,290,600);
    stroke(25);
    //line(5,30,295,30);
    line(5,55,230,55);
    
    //line(5,175,230,175);
    line(5,200,230,200);
    
    //line(5,260,230,260);
    line(5,285,230,285);
    
    line(5,435,295,435);
    line(5,550,295,550);
    
    
  popStyle();
  
  
  randomize_tags = checkbox(20,70,randomize_tags,"Randomizes \'biome tags\', which determine what mobs, ores, plants, and structures spawn in the biome. Enable \'Experimental Gameplay\' when using randomizing World Generation.",0);
  randomize_surface = checkbox(20,100,randomize_surface,"Randomizes the blocks which compose the \'grass\', \'dirt\', and sea floor. The end is currently unaffected by this. Enable \'Experimental Gameplay\' when using randomizing World Generation.",1);
  randomize_base = checkbox(20,130,randomize_base, "Randomizes what replaces the stone and netherrack. The end is currently unaffected by this. Enable \'Experimental Gameplay\' when using randomizing World Generation.",2);
  randomize_features = checkbox(20,160,randomize_features, "Randomizes the compositions of ores, trees, flowers, and tallgrass. Structures are not affected by this. Enable \'Experimental Gameplay\' when using randomizing World Generation.",3);
  
  randomize_player = checkbox(20,215,randomize_player,"Includes the player as an alterable entity. Note that while this could change your health, starting equipment, and/or speed, it could also make you burn in daylight or suffocate in air.",4);
  ensure_random_loot = checkbox(20,245,ensure_random_loot,"Guaruntees that loot is randomized for every alterable entity. Due to the way the randomization of mobs works, some loot may get randomized regardless of this setting.",5);
  
  change_ingredients = checkbox(20,300,change_ingredients,"Changes the ingredients used in the various crafting recipes. Shapes and shapelessness are retained.",6);
  change_results = checkbox(20,330,change_results,"Changes which items result from crafting. Recipes which craft multiple items at once have their quantities randomized as well.",7);
  change_smelt_input = checkbox(20,360,change_smelt_input,"Changes what items can be smelted. As smelting recipes cannot be seen by the Player, this isn't recommended.",8);
  change_smelt_output = checkbox(20,390,change_smelt_output,"Changes what items are given by smelting.",9);
  shuffle_smelt_station = checkbox(20,420,shuffle_smelt_station,"Changes what recipes are smelted in what station. Includes furnaces, blast furnaces, smokers, campfires, and soul campfires. No specific station is guarunteed to work for any recipe.",10);
  
};

void randomize() {
  manifest_authoror manifest = new manifest_authoror();
  entity_behavior_randomizer random = new entity_behavior_randomizer(randomize_player,ensure_random_loot);
  biome_randomizer biomes = new biome_randomizer(randomize_tags,randomize_surface,randomize_base,randomize_features);
  recipe_randomizer recipe = new recipe_randomizer(change_ingredients,change_results,change_smelt_input,change_smelt_output,shuffle_smelt_station);
  
  if (randomize_tags || randomize_surface || randomize_base || randomize_features) biomes.randomize_biomes();
  if (change_ingredients || change_results || change_smelt_input || change_smelt_output || shuffle_smelt_station) recipe.randomize_recipes();
  random.shuffle_entity_components();
  manifest.generate_pack_icon();
  manifest.set_manifest();
  manifest.save_manifest();
};

void draw() {
  pressed = mousePressed;
  menu();
  held = pressed;
};
