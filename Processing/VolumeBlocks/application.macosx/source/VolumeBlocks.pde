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

// Angles for rotation
float a = 0;
float b = 0;

float angle;

void setup() {
  // Rendering in P3D
  //size(800, 600, P3D);
  //Exhibit resolution: 1920 x 1080
  fullScreen(P3D);
  kinect = new Kinect2(this);
  kinect.initDepth();
  kinect.initDevice();
  
  font= loadFont("TwCenMTPro-SemiBold-60.vlw");
  textFont(font);
  dial.init();

}

void draw() {

  background(107,95,77);
  fill(255);
  
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
      v.z-=2000;
      v.z*=-1;
      v.y-=300;
      
      if (v.x < xMin) xMin= v.x;
      if (v.x > xMax) xMax= v.x;
      if (v.y < yMin) yMin= v.y;
      if (v.y > yMax) yMax= v.y;
      if (v.z < zMin) zMin= v.z;
      if (v.z > zMax) zMax= v.z;
      //v.mult(230);
      //v.x*= -1;
      //v.z= 450-v.z;
     

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
 text(frameRate, 5, 15);
 text(grid.cubes.size(), 5, 30);
 text(xMin, 5,40);
 text(xMax, 5,50);
 text(yMin, 5,60);
 text(yMax, 5,70);
 text(zMin, 5,80);
 text(zMax, 5,90);
 
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

void keyPressed() {
}