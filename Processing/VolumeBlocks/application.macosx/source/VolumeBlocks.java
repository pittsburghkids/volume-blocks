import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.openkinect.freenect.*; 
import org.openkinect.freenect2.*; 
import org.openkinect.processing.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class VolumeBlocks extends PApplet {

// Based on:
// Daniel Shiffman
// Kinect Point Cloud example

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/





// Kinect Library object
Kinect2 kinect;

Grid grid= new Grid(30,30,30);
Dial dial= new Dial();
PFont font;

// Angles for rotation
float a = 0;
float b = 0;

float angle;

public void setup() {
  // Rendering in P3D
  //size(800, 600, P3D);
  //Exhibit resolution: 1920 x 1080
  
  kinect = new Kinect2(this);
  kinect.initDepth();
  kinect.initDevice();
  
  font= loadFont("TwCenMTPro-SemiBold-60.vlw");
  textFont(font);
  dial.init();

}

public void draw() {

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
  a= sin(millis()/2000.0f) * 0.35f;
  b= cos(millis()/2000.0f) * 0.05f;
  
 
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
public PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

public void keyPressed() {
}
//camera information based on the Kinect v2 hardware
static class CameraParams {
  static float cx = 254.878f;
  static float cy = 205.395f;
  static float fx = 365.456f;
  static float fy = 365.456f;
  static float k1 = 0.0905474f;
  static float k2 = -0.26819f;
  static float k3 = 0.0950862f;
  static float p1 = 0.0f;
  static float p2 = 0.0f;
}
class Cube{
  int size;
  PVector pos;
  boolean dead;
  boolean born;
  boolean touched;
  int goneFrames;
  int hereFrames;
  int age;
  int c;
  
  Cube(PVector _pos, int _size){
    size= _size;
    pos= _pos;
    dead= false;
    born= false;
    age= 0;
    hereFrames=0;
    goneFrames=0;
    touched= true;
    int h= PApplet.parseInt(random(60));
    c= color(160+h, 10+h*0.8f, 10+h*0.6f);
  }
  
  public void display(){
    if(!born) return;
    if(age<5) return;
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    fill(c);
    strokeWeight(2);
    box(size, size, size);
    popMatrix();
  }
  
  public void update(){
    age++;
    if(touched) hereFrames++;
    if(!touched){
      goneFrames++;
      hereFrames= 0;
      if (!born) dead= true;
    }
    if(hereFrames > 5) born= true;
    if(goneFrames > 5) dead= true;
    touched= false;
  }
  
  public boolean isSame(PVector otherPos){
    if(PApplet.parseInt(pos.x) != PApplet.parseInt(otherPos.x)) return false;
    if(PApplet.parseInt(pos.y) != PApplet.parseInt(otherPos.y)) return false;
    if(PApplet.parseInt(pos.z) != PApplet.parseInt(otherPos.z)) return false;
    return true;
  }
  
  public void touch(){
    goneFrames=0;
    touched= true;
  }
}
class Dial{
  int centerX;
  int centerY;
  int dia;
  int c;
  
  // movement
  float pos=0; //angular pos
  float vel=0;
  float vMax= 20.0f;
  float target=0;
  
  public void init(){
    centerX= width/2;
    centerY= height*3/2+50;
    dia= width*5/2;
    c= color(247,246,234);
  }
  
  public void setTarget(float t){
    target= t;
  }
  
  public void update(){
    // sine wave test
    //target= sin(millis()/2000.0) * 150;
    
    // square wave test
    //if(millis()/10000 % 2 == 0) target=1000;
    //else target= 0;
    
    float accel= 0.003f * ( target-pos );
    float maxAccel= vMax/50;
    if (accel > maxAccel) accel = maxAccel;
    if (accel < -maxAccel) accel = -maxAccel;
    vel+= accel;
    
    vel*= 0.95f; // damp
    
    if (vel > vMax) vel= vMax;
    if (vel < -vMax) vel= -vMax;
    
    pos+= vel;
  }
  
  public void display(){
    int gradWidth= 10;
    int gradHeight= 100;
    int margin= 50;
    
    // face
    pushMatrix();
    translate(centerX, centerY);
    noStroke();
    fill (c);
    ellipse(0, 0, dia, dia);
    
    // draw graduations
    fill(0);
    
    int numVisible= 10;
    float radPerGrad= PI/10; // radians per graduation
       
    int posIncPerGrad= 100;
    float posRemainder= -pos % posIncPerGrad;
    int nearestInc= -PApplet.parseInt(-pos/posIncPerGrad) * posIncPerGrad;
    rotate(posRemainder / posIncPerGrad * radPerGrad);
    
    // major grads
    pushMatrix();
    int firstNumber= nearestInc - (numVisible/2*posIncPerGrad); 
    rotate( -( numVisible/2 ) * radPerGrad );
    textAlign(CENTER);
    textSize(60);
    for (int i= 0; i < numVisible; i++){
      rect(0-gradWidth, -dia/2+margin, gradWidth, gradHeight);
      text(firstNumber + i * posIncPerGrad, -gradWidth/2, -dia/2+gradHeight+60+margin);
      rotate(radPerGrad);
    }
    textSize(10);
    
    popMatrix();
    rotate( -( numVisible/2 ) * radPerGrad );
    // minor grads
    for (int i= 0; i < numVisible * 5; i++){
      rect(0-gradWidth, -dia/2+margin, gradWidth, gradHeight*2/3);
      rotate(radPerGrad / 5);
    }
    
    textAlign(LEFT);
    popMatrix();
    
    // Pointer
    fill(164,158,142);
    fill(0);
    beginShape();
    vertex(width/2-30, centerY-dia/2);
    vertex(width/2+30, centerY-dia/2);
    vertex(width/2, centerY-dia/2+80);
    endShape(CLOSE);
       
  }
}
class Grid {
  int xSize;
  int ySize;
  int zSize;
  int xMin, xMax, yMin, yMax, zMin, zMax;
  
  int cellSize= 60;
  
  ArrayList<Cube> cubes= new ArrayList<Cube>();;
  
  Grid(int _x, int _y, int _z){
    xSize= _x;
    ySize= _y;
    zSize= _z;
    
    xMax= (xSize * cellSize)/2;
    xMin= -xMax;
    yMax= (ySize * cellSize)/2;
    yMin= -yMax;
    zMax= (zSize * cellSize)/2;
    zMin= -zMax;
  }
  
  public boolean isInside(PVector v){
    if ( v.x < xMin) return false;
    if ( v.x > xMax) return false;
    if ( v.y < yMin) return false;
    if ( v.y > yMax) return false;
    if ( v.z < zMin) return false;
    if ( v.z > zMax) return false;
    return true;
  }
  
  public void addCube(PVector pos){
    
    float cellX= pos.x/cellSize;
    float cellY= pos.y/cellSize;
    float cellZ= pos.z/cellSize;
    pos.x= round(cellX) * cellSize;
    pos.y= round(cellY) * cellSize;
    pos.z= round(cellZ) * cellSize;
    
    boolean newCube= true;
    for (int i= 0; i < cubes.size(); i++){
      Cube cube= cubes.get(i);
      if (cube.isSame(pos)){
        newCube= false;
        cube.touch();
      }
    }
    if (newCube) cubes.add(new Cube(pos, cellSize));
  }
  
  public void update(){
    // age cubes
    for(int i= 0; i < cubes.size(); i++){
      Cube cube= cubes.get(i);
      cube.update();
    }
    
    // remove dead cubes from array
    for(int i=0; i<cubes.size(); i++){
      Cube cube= cubes.get(i);
      if (cube.dead) cubes.remove(i);
    }
  }
  
  public void display(){
    stroke(0);
    drawFloorLines();
    drawBox();
    
    stroke(0);
    for (int i=0; i < cubes.size(); i++){
      Cube cube= cubes.get(i);
      cube.display();
    }
  }
  
  public void drawFloorLines(){
    pushMatrix();
    translate( -(xSize*cellSize)/2, (ySize*cellSize)/2, -(zSize*cellSize)/2 );
    translate( -cellSize/2, cellSize/2, -cellSize/2 );
    
    beginShape(LINES);
    for(int i = 0; i <= (xSize+1)*cellSize; i+= cellSize){
      vertex(i, 0, 0);
      vertex(i, 0, (zSize+1)*cellSize);
    }
  
    for(int i = 0; i <= (zSize+1)*cellSize; i+= cellSize){
      vertex(0, 0, i);
      vertex((xSize+1)*cellSize, 0, i);
    }
    endShape();
    
    popMatrix();
  }
  
  public void drawBox(){
    pushMatrix();
    translate( -(xSize*cellSize)/2, (ySize*cellSize)/2, -(zSize*cellSize)/2 );
    translate( -cellSize/2, cellSize/2, -cellSize/2 );
    
    int xDim= cellSize * (xSize+1);
    int yDim= cellSize * -ySize;
    int zDim= cellSize * (zSize+1);
    
    beginShape(LINES);
    
    // posts
    vertex(0,0,0);
    vertex(0,yDim,0);
    
    vertex(xDim,0,0);
    vertex(xDim,yDim,0);
    
    vertex(0,0,zDim);
    vertex(0,yDim,zDim);
    
    vertex(xDim,0,zDim);
    vertex(xDim,yDim,zDim);
    
    // upper box
    vertex(0,yDim,0);
    vertex(xDim, yDim, 0);
    
    vertex(xDim,yDim,0);
    vertex(xDim, yDim, zDim);
    
    vertex(xDim, yDim, zDim);
    vertex(0, yDim, zDim);
    
    vertex(0, yDim, zDim);
    vertex(0,yDim,0);
    
    endShape();    
    
    popMatrix();
  }
}
  public void settings() {  fullScreen(P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "VolumeBlocks" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
