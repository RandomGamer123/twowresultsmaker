import java.util.Map;
HashMap<String,PImage> imagedict = new HashMap<String,PImage>();
JSONArray data;
JSONArray currentcomparison;
int currentcompared = 0;
int currentresponsenumber = 0;
int totalresponsecount = 0;
JSONObject[] currentcompetitorsobjects = new JSONObject[2];
int[] currentvotenumbers = {0,0};
int[] responsesetvotecount = {0,0};
float[] currentvotepositions = {0,0};
String[] currentcolours = new String[2];
int frame = 0;
int perresponseframe = 0;
int delaywait = 120; //24fps so 5 seconds
int intervotedelay = 12; //0.5s
int votedisplayduration = 12; //0.5s
int totalvotedisplaytime;
void setup() {
  data = loadJSONArray("results.json");
  String[] imagestoload = loadStrings("loadimages.txt"); //put a list of images that need to be loaded in here since i am too lazy to make something that can directly read the .json
  for (int i = 0; i < imagestoload.length; i++) {
    String filename = imagestoload[i];
    imagedict.put(filename,loadImage(filename));
  }
  size(1920,1080);
}
void draw() {
  if (frame == 0) {
    background(0);
    currentvotepositions[0] = 0;
    currentvotepositions[1] = 0;
    currentvotenumbers[0] = 0;
    currentvotenumbers[1] = 0;
    currentresponsenumber = 0;
    totalvotedisplaytime = 0;
    responsesetvotecount[0] = 0;
    responsesetvotecount[1] = 0;
    perresponseframe = 0;
    currentcomparison = data.getJSONArray(currentcompared);
    currentcompetitorsobjects[0] = currentcomparison.getJSONArray(0).getJSONObject(0);
    currentcompetitorsobjects[1] = currentcomparison.getJSONArray(1).getJSONObject(0);
    int pixeldiff = -70;
    for (int i = 0; i < currentcompetitorsobjects.length; i++) {
      JSONObject currentcompetitorobj = currentcompetitorsobjects[i];
      PImage competitorimage = imagedict.get(currentcompetitorobj.getString("imagename"));
      image(competitorimage,100,50+730*i,250,250);
      JSONArray responses = currentcompetitorobj.getJSONArray("responses");
      totalresponsecount = responses.size();
      fill(200);
      rect(0,480+70*i,1920,50);
      if (i == (currentcompetitorsobjects.length-1)) {
        redrawnumbers();
      }
      String colour = currentcompetitorobj.getString("colourcode"); //colour must be in string form of 8 digit hexadecimal, the first two digits represent the alpha value with FF being fully opaque and the last 6 are the RGB hex code (eg. FFFF0000 for fully opaque red)
      fill(unhex(colour));
      currentcolours[i] = colour;
      for (int j = 0; j < responses.size(); j++) {
        if (pixeldiff < 0) {
          textAlign(LEFT,TOP);
        } else {
          textAlign(LEFT,BOTTOM);
        }
        if (j == (responses.size()-1)) {
          textSize(36);
          pixeldiff += Integer.signum(pixeldiff)*(36+5); //an additional 5 pixel gap
        } else {
          textSize(24);
          pixeldiff += Integer.signum(pixeldiff)*(24+5); //an additional 5 pixel gap
        }
        text(responses.getJSONObject(j).getString("response"),100,540+pixeldiff);
      }
      pixeldiff += Integer.signum(pixeldiff)*(60+10); //an additional 10 pixel gap
      textSize(60);
      text(currentcompetitorobj.getString("username"),100,540+pixeldiff);
      pixeldiff = Integer.signum(pixeldiff)*-70;
    }
  }
  if (perresponseframe == delaywait) {
    for (int i = 0; i < currentcompetitorsobjects.length; i++) {
      JSONObject currentcompetitorobj = currentcompetitorsobjects[i];
      JSONObject currentresponsedata = currentcompetitorobj.getJSONArray("responses").getJSONObject(currentresponsenumber);
      responsesetvotecount[i] = currentresponsedata.getJSONArray("votes").size();
    }
    totalvotedisplaytime = max(responsesetvotecount)*(intervotedelay+votedisplayduration)-intervotedelay;
  } else if ((perresponseframe-delaywait)%(intervotedelay+votedisplayduration)==12) {
    currentvotenumbers[0]++;
    currentvotenumbers[1]++;
    if (max(currentvotenumbers) >= max(responsesetvotecount)) { //if all votes have been counted
      //for (int i = 0; i < currentcompetitorsobjects.length; i++) { unneeded code
        //fill(unhex(currentcolours[i])-(-2147483648));
        //rect(0,480+70*i,currentvotepositions[i],50);
      //}
      if (perresponseframe-delaywait*2-totalvotedisplaytime == 0) { //if the delay time has been passed after vote revealing is done
        for (int i = 0; i < currentcompetitorsobjects.length; i++) {
          fill(200);
          rect(0,480+70*i,1920,50);
          fill(unhex(currentcolours[i])-(-2147483648)); //-2147483648 is 80000000 in hex
          rect(0,480+70*i,currentvotepositions[i],50);
          redrawnumbers();
          //stroke(unhex(currentcolours[i])); old code
          //strokeWeight(1);
          //line(currentvotepositions[i],480+70*i,currentvotepositions[i],530+70*i);
          //noStroke();
        }
        currentresponsenumber++;
        currentvotepositions[0] = 0;
        currentvotepositions[1] = 0;
        currentvotenumbers[0] = 0;
        currentvotenumbers[1] = 0;
        if (currentresponsenumber < totalresponsecount) {
          perresponseframe = -1;
        }
      }
      if (currentresponsenumber==totalresponsecount) { //if all responses have been displayed
        if (perresponseframe-delaywait*2-totalvotedisplaytime == 0) { //if the delay time has been passed after vote revealing is done
          currentcompared++;
          frame = -1;
          perresponseframe = -1;
          currentvotepositions[0] = 0;
          currentvotepositions[1] = 0;
          currentvotenumbers[0] = 0;
          currentvotenumbers[1] = 0;
          currentresponsenumber = 0;
          if (currentcompared == data.size()) {
            noLoop();
          }
        }
      }
    }
  }
  if (((perresponseframe-delaywait)>=0 && (perresponseframe-delaywait) < totalvotedisplaytime) &&((perresponseframe-delaywait)%(intervotedelay+votedisplayduration) >= 0 && (perresponseframe-delaywait)%(intervotedelay+votedisplayduration) < votedisplayduration)) {
    for (int i = 0; i < currentcompetitorsobjects.length; i++) {
      JSONObject currentcompetitorobj = currentcompetitorsobjects[i];
      JSONObject currentresponsedata = currentcompetitorobj.getJSONArray("responses").getJSONObject(currentresponsenumber);
      JSONArray votearray = currentresponsedata.getJSONArray("votes");
      noStroke();
      fill(unhex(currentcolours[i]));
      float votelength = 1920*votearray.getFloat(currentvotenumbers[i])/votedisplayduration/responsesetvotecount[i];
      rect(0,480+70*i,currentvotepositions[i]+votelength,50);
      currentvotepositions[i] += votelength;
    }
  }
  frame++;
  perresponseframe++;
  saveFrame("s7_s7c_jointfinale-######.png");
}
void redrawnumbers() {
  fill(255);
  textSize(30);
  textAlign(CENTER,CENTER);
  for (int i = 10; i < 100; i+=10) {
    text(i,i*1920/100,536);
  }
}
