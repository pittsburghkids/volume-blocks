// Based on:
// Daniel Shiffman
// Kinect Point Cloud example

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// Kinect Library object
Kinect kinect;

Grid grid= new Grid(30,30,30);

// Angles for rotation
float a = 0;
float b = 0;

float angle;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void setup() {
  // Rendering in P3D
  //size(800, 600, P3D);
  fullScreen(P3D);
  kinect = new Kinect(this);
  kinect.initDepth();

  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}

void draw() {

  background(10);
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
  translate(width/2, height/2, 300);
  rotateY(a);
  rotateX(b);
  
  grid.update();
  
  for (int x = 0; x < kinect.width; x += skip) {
    for (int y = 0; y < kinect.height; y += skip) {
      int offset = x + y*kinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);
      v.mult(230);
      v.x*= -1;
      v.z= 450-v.z;

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
  
  grid.display();

  // Rotate
  //a += 0.015f;
  a= sin(millis()/2000.0) * 0.35;
  b= cos(millis()/2000.0) * 0.05;
  
 
 popMatrix();
 
 noLights();
 fill(255);
 text(frameRate, 5, 15);
 text(grid.numCubes, 5, 30);
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, -30, 30);
    kinect.setTilt(angle);
  }
}