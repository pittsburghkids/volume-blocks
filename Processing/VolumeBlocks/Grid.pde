class Grid {
  int xSize;
  int ySize;
  int zSize;
  int xMin, xMax, yMin, yMax, zMin, zMax;
  
  int cellSize= 12;
  
  int maxCubes= 10000;
  Cube[] cubes= new Cube[maxCubes];
  int numCubes= 0;
  
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
  
  boolean isInside(PVector v){
    if ( v.x < xMin) return false;
    if ( v.x > xMax) return false;
    if ( v.y < yMin) return false;
    if ( v.y > yMax) return false;
    if ( v.z < zMin) return false;
    if ( v.z > zMax) return false;
    return true;
  }
  
  void addCube(PVector pos){
    if (numCubes == maxCubes-1) return;
    
    float cellX= pos.x/cellSize;
    float cellY= pos.y/cellSize;
    float cellZ= pos.z/cellSize;
    pos.x= round(cellX) * cellSize;
    pos.y= round(cellY) * cellSize;
    pos.z= round(cellZ) * cellSize;
    
    boolean newCube= true;
    for (int i=0; i<numCubes; i++){
      if (cubes[i].isSame(pos)){
        newCube= false;
        cubes[i].touch();
      }
    }
    if (newCube){
      cubes[numCubes]= new Cube(pos, cellSize);
      numCubes++;
    }
  }
  
  void update(){
    // age cubes
    for(int i=0; i<numCubes; i++){
      cubes[i].update();
    }
    
    // remove dead cubes from array
    int numDead= 0;
    for(int i=0; i<numCubes; i++){
      if (cubes[i].dead) numDead++;
      if(i+numDead < numCubes) cubes[i]= cubes[i+numDead];
    }
    numCubes= numCubes-numDead;
  }
  
  void display(){
    stroke(120);
    drawFloorLines();
    drawBox();
    
    stroke(0);
    for (int i=0; i < numCubes; i++){
      cubes[i].display();
    }
  }
  
  void drawFloorLines(){
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
  
  void drawBox(){
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