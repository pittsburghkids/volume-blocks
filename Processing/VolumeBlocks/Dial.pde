class Dial{
  int centerX;
  int centerY;
  int dia;
  color c;
  
  // movement
  float pos=0; //angular pos
  float vel=0;
  float vMax= 20.0;
  float target=0;
  
  void init(){
    centerX= width/2;
    centerY= height*3/2+50;
    dia= width*5/2;
    c= color(247,246,234);
  }
  
  void setTarget(float t){
    target= t;
  }
  
  void update(){
    // sine wave test
    //target= sin(millis()/2000.0) * 150;
    
    // square wave test
    //if(millis()/10000 % 2 == 0) target=1000;
    //else target= 0;
    
    float accel= 0.003 * ( target-pos );
    float maxAccel= vMax/50;
    if (accel > maxAccel) accel = maxAccel;
    if (accel < -maxAccel) accel = -maxAccel;
    vel+= accel;
    
    vel*= 0.95; // damp
    
    if (vel > vMax) vel= vMax;
    if (vel < -vMax) vel= -vMax;
    
    pos+= vel;
  }
  
  void display(){
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
    int nearestInc= -int(-pos/posIncPerGrad) * posIncPerGrad;
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