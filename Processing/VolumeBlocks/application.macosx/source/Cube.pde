class Cube{
  int size;
  PVector pos;
  boolean dead;
  boolean born;
  boolean touched;
  int goneFrames;
  int hereFrames;
  int age;
  color c;
  
  Cube(PVector _pos, int _size){
    size= _size;
    pos= _pos;
    dead= false;
    born= false;
    age= 0;
    hereFrames=0;
    goneFrames=0;
    touched= true;
    int h= int(random(60));
    c= color(160+h, 10+h*0.8, 10+h*0.6);
  }
  
  void display(){
    if(!born) return;
    if(age<5) return;
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    fill(c);
    strokeWeight(2);
    box(size, size, size);
    popMatrix();
  }
  
  void update(){
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
  
  boolean isSame(PVector otherPos){
    if(int(pos.x) != int(otherPos.x)) return false;
    if(int(pos.y) != int(otherPos.y)) return false;
    if(int(pos.z) != int(otherPos.z)) return false;
    return true;
  }
  
  void touch(){
    goneFrames=0;
    touched= true;
  }
}