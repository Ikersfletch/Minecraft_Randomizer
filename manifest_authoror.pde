public class manifest_authoror {
  public String b_name;
  public String b_desc;
  public String sketch_path = "";
  public String[] uuids = new String[4];
  
  JSONObject b_manifest;
  public PGraphics pack_icon;
  
  public manifest_authoror(String b_name, String b_desc) {
    this.b_name = b_name;
    this.b_desc = b_desc;
    String[] path_apart = split(sketchPath(),"\\");
    for (int i = 0; i < path_apart.length; i++) {
      sketch_path += path_apart[i]+"/";
    }
    b_manifest = loadJSONObject(sketch_path+"generator_files/behavior_pack/manifest.json");
    pack_icon = createGraphics(128,128);
    uuids = loadStrings("http://www.uuidgenerator.net/api/version4/2");
  }
  public manifest_authoror() {
    this("Randomized Behavior Pack @ "+hour()+":"+minute(),"Randomized pack");
  }
  
  public void set_manifest() {
    JSONObject b_header = b_manifest.getJSONObject("header");
    b_header.setString("name",b_name);
    b_header.setString("description",b_desc);
    b_header.setString("uuid",uuids[0]);
    JSONArray b_modules = b_manifest.getJSONArray("modules");
    JSONObject b_module_0 = b_modules.getJSONObject(0);
    b_module_0.setString("uuid",uuids[1]);
    b_modules.setJSONObject(0, b_module_0);
    b_manifest.setJSONObject("header", b_header);
    b_manifest.setJSONArray("modules", b_modules);
  }
  
  public void save_manifest() {
    saveJSONObject(b_manifest,sketch_path+"generated_files/behavior_pack/manifest.json");
    pack_icon.save(sketch_path+"generated_files/behavior_pack/pack_icon.png");
  }
  
  public void generate_pack_icon() {
    colorMode(HSB, 360, 100, 100);
    color one = color((int)(Math.random()*360),70,50);
    color two = color((int)(Math.random()*360),100,100); 
    int rotation = (int)(Math.random()*360);
    pack_icon.beginDraw();
    pack_icon.strokeWeight(2);
    pack_icon.pushMatrix();
    pack_icon.translate(pack_icon.width/2,pack_icon.height/2);
    pack_icon.rotate(radians(rotation));
    for (int i = -pack_icon.height/2 -50; i < pack_icon.height/2+50; i ++) {
      float point = map(i,(-pack_icon.height/2.0),(pack_icon.height/2.0),0.0,1.0);
      pack_icon.stroke(lerpColor(one,two,point));
      pack_icon.line(-pack_icon.width/2 - 50,i,pack_icon.width/2 + 50,i);
    }
    pack_icon.popMatrix();
    pack_icon.endDraw();
    colorMode(RGB,255,255,255);
  }
}
