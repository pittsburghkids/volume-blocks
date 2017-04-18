// Based on:
// Daniel Shiffman
// Kinect Point Cloud example

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

// Kinect Library object
Kinect2 kinect;

Grid grid= new Grid(30,30,30);
Dial dial= new Dial();
PFont font;

boolean settingUp= false;

// Angles for rotation
float a = 0;
float b = 0;

float angle;
// skew floor
float skewAmt;
float floorLevel;
float skewAmtSaved;
float floorLevelSaved;

void setup() {
  // Rendering in P3D
  //size(800, 600, P3D);
  //Exhibit resolution: 1920 x 1080
  
  //size(540, 960, P3D);
  fullScreen(P3D);
  kinect = new Kinect2(this);
  kinect.initDepth();
  kinect.initDevice();

  font= loadFont("TwCenMTPro-SemiBold-60.vlw");
  textFont(font);
  dial.init();
  
  readSettings();
}

void draw() {
  background(234,217,164); //lightest
  //background(233,207,110); //darkest
  fill(255,100);
   rect(0, height - 514, width, height);
  
  fill(0);
  smooth();
  // Set up some different colored lights
  pointLight(255, 255, 255, -65, -60, -100); 
  pointLight(200, 200, 200, width+65, -60, 150);

  // Raise overall light in scene 
  ambientLight(100, 100, 100); 
  
  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 4;
  
  pushMatrix();
  // Translate and rotate
  translate(width/2, height/3, -1500);
  //rotateY(a);
  //rotateX(b);
  
  float xMin=1000, xMax=0, yMin=1000, yMax=0, zMin=1000, zMax=0;
  
  for (int x = 0; x < kinect.depthWidth  ; x += skip) {
    for (int y = 0; y < kinect.depthHeight; y += skip) {
      int offset = x + y*kinect.depthWidth;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      //PVector v = depthToWorld(x, y, rawDepth);
      PVector v = depthToPointCloudPos(x, y, rawDepth);
      v.z-= 2500;
      v.z*= -1;
      v.y-= floorLevel;
      
      // skew floor
      v.y-= v.z/skewAmt;
            
      if (v.x < xMin) xMin= v.x;
      if (v.x > xMax) xMax= v.x;
      if (v.y < yMin) yMin= v.y;
      if (v.y > yMax) yMax= v.y;
      if (v.z < zMin) zMin= v.z;
      if (v.z > zMax) zMax= v.z;

      stroke(255);
      
      if(grid.isInside(v)){
        grid.addCube(v);
        
        //pushMatrix();
        //translate(v.x, v.y, v.z);
        // Draw a point
        // point(0, 0);
        //popMatrix();
      }
    }
  }
  
  grid.update();
  grid.display();

  // Rotate
  //a += 0.015f;
  a= sin(millis()/2000.0) * 0.35;
  b= cos(millis()/2000.0) * 0.05;
  
 
 popMatrix();
 
 noLights();
 fill(255);
 /*
 text(frameRate, 5, 15);
 text(grid.cubes.size(), 5, 30);
 text(xMin, 5,40);
 text(xMax, 5,50);
 text(yMin, 5,60);
 text(yMax, 5,70);
 text(zMin, 5,80);
 text(zMax, 5,90);
 */
 
 if (settingUp){
   noStroke();
   fill(255,255,255,200);
   rect(0,0, 400, 200);
   
   textSize(20);
   fill(0);
   
   textAlign(RIGHT);
   text("Tilt (LEFT/RIGHT):", 250, 100);
   text("Floor Level (UP/DOWN):", 250, 125);
   text("Save ('S'):", 250, 150);
   text("Reset to Default ('R')", 250, 175);
   
   textAlign(LEFT);  
   text(skewAmt, 260, 100);
   text(floorLevel, 260, 125);
   if(skewAmtSaved == skewAmt) if(floorLevelSaved == floorLevel) text("SAVED", 260, 150);
 }
 
 dial.setTarget(grid.cubes.size());
 dial.update();
 dial.display();

}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

void readSettings(){
  BufferedReader readSettings;
  String line;
  
  readSettings= createReader("settings.txt");
  
  try {
    line = readSettings.readLine();
  } catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
    
  if (line == null) {
    // Stop reading because of an error or file is empty
    try { readSettings.close(); }
    catch (IOException e) { e.printStackTrace(); }
  } else {
    String[] pieces = split(line, TAB);
    skewAmt = float(pieces[0]);
    floorLevel = float(pieces[1]);
    skewAmtSaved = skewAmt;
    floorLevelSaved = floorLevel;
  }
}

void saveSettings(){
  PrintWriter writeSettings;
  writeSettings= createWriter("data/settings.txt");
  writeSettings.println(skewAmt + "\t" + floorLevel);
  writeSettings.flush();
  writeSettings.close();
  skewAmtSaved= skewAmt;
  floorLevelSaved= floorLevel;
}

void keyPressed() {
  if(key==' ') settingUp= !settingUp;
  
  if(settingUp){
    if (key==CODED){
      if(keyCode==RIGHT) skewAmt*=0.9;
      if(keyCode==LEFT) skewAmt*=1.1;
      if(keyCode==UP) floorLevel+= 10;
      if(keyCode==DOWN) floorLevel-= 10;
    }
    if (key=='s' || key=='S') saveSettings();  
    if (key=='r' || key=='R'){ skewAmt=3.0; floorLevel=200; }
  }
}