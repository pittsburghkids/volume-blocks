class Dial {


  int centerX;
  int centerY;
  int dia;
  color c;
  color colRed;


  // movement
  float pos=0; //angular pos
  float vel=0;
  float vMax= 20.0;
  float target=0;

  void init() {
    //centerX= width/2;
    centerX = 1080/2;

    //centerY= height*3/2+50;
    centerY = 1920*3/2 + 50;

    //dia= width*5/2;
    dia= 2566;
    c= color(247, 246, 234);


    colRed = color( 229, 95, 52);
  }

  void setTarget(float t) {
    target= t;
  }

  void update() {
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

  void display() {

    int gradWidth= 10;
    int gradHeight= -50;
    int margin= 50;

    // face
    pushMatrix();
    translate(centerX, centerY);

    noFill();
    stroke(233, 207, 110,50);
    //stroke(234,217,164);
    strokeWeight(19);
    ellipse(0, 0, 2585, 2585);


    fill(c,200);
    ellipse(0, 0, 2578, 2578);

    //stroke(233, 207, 110);
    stroke(0, 100);
    strokeWeight(3);
    noFill();
    //ellipse(0, 0, dia, dia);
    ellipse(0, 0, 2562, 2562); 



    stroke(colRed);
    strokeWeight(5);
    ellipse(0, 0, 2340, 2340);

    strokeWeight(14);
    ellipse(0, 0, 2220, 2220);


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
    stroke(colRed);
    strokeWeight(14);
    strokeCap(PROJECT);
    for (int i= 0; i < numVisible; i++) {
      line(0, 0-2220/2, 0, 0-2424/2);
      //rect(0-gradWidth, -dia/2+margin, gradWidth, gradHeight);
      int number= firstNumber + i * posIncPerGrad;
      if (number>=0) text(number, -gradWidth/2 + 3, -dia/2+gradHeight + 60 + margin);
      //if(number>0) text(number, -gradWidth/2, -dia/2+gradHeight+60+margin);
      rotate(radPerGrad);
    }
    textSize(10);

    popMatrix();
    rotate( -( numVisible/2 ) * radPerGrad );
    // minor grads
    strokeWeight(3);
    for (int i= 0; i < numVisible * 5; i++) {
      line(0, 0-2220/2, 0, 0-2340/2);
      //rect(0-gradWidth, -dia/2+margin, gradWidth, gradHeight*2/3);
      rotate(radPerGrad / 5);
    }

    textAlign(LEFT);
    popMatrix();


    // Pointer
    noStroke();

    fill(colRed, 200);
    beginShape();
    vertex(width/2-33, height - 30);
    vertex(width/2+33, height - 30);
    vertex(width/2, height - 95);
    endShape(CLOSE);

    fill(0);
    beginShape();
    vertex(width/2-30, height - 30);
    vertex(width/2+30, height - 30);
    vertex(width/2, height - 90);
    endShape(CLOSE);




    textAlign(CENTER);
    textSize(95);
    fill(colRed);
    noStroke();
    text("How many cubes are you?", width /2, height - 423);
    text("¿Cuántos cubos estás?", width /2, height - 325);

    
  }
}