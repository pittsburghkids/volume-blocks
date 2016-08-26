class Cube{
  int size;
  PVector pos;
  boolean dead;
  boolean born;
  int hereFrames;
  int goneFrames;
  color c;
  
  Cube(PVector _pos, int _size){
    size= _size;
    pos= _pos;
    dead= false;
    born= false;
    hereFrames= 1;
    goneFrames= 0;
    int h= int(random(80));
    c= color(255, h, h/2);
  }
  
  void display(){
    //if (!born) return;
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    fill(c);
    box(size, size, size);
    popMatrix();
  }
  
  void update(){
    goneFrames++;
    if(goneFrames == 8) dead= true;
    if(hereFrames > 10) born= true;
    if( !born && goneFrames > 1 ) dead= true;
  }
  
  boolean isSame(PVector otherPos){
    if(pos.x != otherPos.x) return false;
    if(pos.y != otherPos.y) return false;
    if(pos.z != otherPos.z) return false;
    
    return true;
  }
  
  void touch(){
    hereFrames++;
    goneFrames= 0;
  }
}