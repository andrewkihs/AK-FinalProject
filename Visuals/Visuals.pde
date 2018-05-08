import oscP5.*;  
import netP5.*;
import deadpixel.keystone.*; 
 
// library variables
OscP5 oscP5;
NetAddress local;
OpenSimplexNoise noise;
Keystone ks;

//projection surfaces
CornerPinSurface surface; 
CornerPinSurface surface1; 
CornerPinSurface surface2; 
CornerPinSurface surface3; 
CornerPinSurface surface4; 
 

 
//bangs  
int[] allBangsReceived;
int allBangs = 0;
int kickBang = 0;
int kickDelayBang = 0; 
int lowTomBang = 0;
int highTomBang = 0;
int[] allPrevBangsReceived;
boolean[] bangsDidUpdate;
int[] BangNumbers = new int[700];
int pass = 0;
int maxPasses = 20;


int timesPassed = 0;

//for pass 3;
float[] prevLineMidpoint = new float[2];
int numberOfRectangles = 10;
int[][] rectangles = new int[numberOfRectangles][7];

//perlin noise example
int numFrames = 100;
int margin = 50; 
int m;



//PGraphics buffer
PGraphics offscreen;
PGraphics offscreen1;
PGraphics offscreen2;
PGraphics offscreen3;
PGraphics offscreen4;
PGraphics offscreen5;




void setup() {
  
 
  //
  allBangsReceived = new int[20];
  allPrevBangsReceived = new int[20];
  bangsDidUpdate = new boolean[20];
  
  //initializing for pass15 viz
  prevLineMidpoint[0] = (random(width));
  prevLineMidpoint[1] = (random(height));
  size(1920,1080,P3D); //size of projector being used

  //for each screen create surface + PGraphics to draw into
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(800, 800, 20);
  surface1 = ks.createCornerPinSurface(800, 800, 20);
  surface1.moveTo(40,40);
  surface2 = ks.createCornerPinSurface(800, 800, 20);
  surface2.moveTo(80,80);
  surface3 = ks.createCornerPinSurface(800, 800, 20);
  surface3.moveTo(90,50);
  surface4 = ks.createCornerPinSurface(800, 800, 20);
  surface4.moveTo(300,10);
  
  //PGraphics...
  offscreen = createGraphics(800, 800, P3D);
  offscreen1 = createGraphics(offscreen.width, offscreen.height, P3D); 
  offscreen2 = createGraphics(offscreen.width, offscreen.height, P3D); 
  offscreen3 = createGraphics(offscreen.width, offscreen.height, P3D);
  offscreen4 = createGraphics(offscreen.width, offscreen.height, P3D);
 
 
  //
  oscP5 = new OscP5(this, 8080); // port number
  local = new NetAddress("127.0.0.1",8080);
  
  noise = new OpenSimplexNoise();
  float sumh = 0;
  while(true){
    float lr = 0.5*pow(random(0.5,2.0),2);
    float scl = 0.1*pow(random(0.4,2),2);
    float h = 100.0*pow(random(0.2,1),4.0);
    sumh += h;
    if(sumh>=offscreen.height-2*margin){
      h -= sumh - (offscreen.height-2*margin);
      lines.add(new Line(lr,scl,h));
      m++;
      break;
    }
    lines.add(new Line(lr,scl,h));
    m++;
  }
}

int pCordToIndex(int xVal, int yVal){
  return xVal + (yVal * offscreen.width);
}
void draw() {
  background(0);
  offscreen.beginDraw();
  offscreen.noStroke();
  if(timesPassed==1){
    offscreen.stroke(255,0,0);
  }
  offscreen.stroke(0,255,0);
  int offset = int(random(-4, 4));
  float rectHeight = random(offscreen.height);
  int mappedAllBangs = (int) map(allBangs,0,125,0,offscreen.width);
 
  if(pass <= 3){
     //draw verticle lines
    offscreen.rect(mappedAllBangs,(offscreen.height-rectHeight)/2 , 2, rectHeight);
  }
  if(pass > 3){
    //draw horizontal lines
    offscreen.rect((offscreen.width-rectHeight)/2, mappedAllBangs, rectHeight, 2);
  }
  
  // horizontal smear
  int lineHeight = 7;
  int glitch = 50;
  if(bangsDidUpdate[4]){
    if(pass >= 4){
      offscreen.loadPixels();
      for(int i = 0; i< offscreen.width; i++){
         int temp = int(random(offscreen.height-lineHeight));
         for(int j = 0; j<lineHeight; j++){

         }
       }
     offscreen.updatePixels();
  }
  }
  if(bangsDidUpdate[6]){
  if(pass >= 6){
     offscreen.loadPixels();
     int lineWidth = lineHeight;
       for(int i = 0; i< offscreen.height; i++){
         int temp = int(random(offscreen.width-lineWidth));
         for(int j = 0; j<lineWidth; j++){
           offscreen.pixels[pCordToIndex(temp+j,i)] = offscreen.pixels[abs(pCordToIndex(temp+j,i-glitch))%(offscreen.width*offscreen.height)];   
         }
       } 
     offscreen.updatePixels();
  }
  }
  if(pass >= 8){
    if(bangsDidUpdate[8]){
            offscreen.noStroke();
            offscreen.fill(allBangs*1000%255,0,(allBangs*kickDelayBang*1000)%255);
            offscreen.rect((random(offscreen.width)),(random(offscreen.height)) , 30,30 );
            offscreen.fill(255);
            offscreen.stroke(allBangs,allBangs,allBangs);


      }
  }
  if(pass >= 10 ){
    if(bangsDidUpdate[10]){
            offscreen.noStroke();
            offscreen.fill(random(255),random(255),random(255));
            
            offscreen.rect((random(width)),(random(height)) , 30,30 );
            offscreen.fill(255);
            offscreen.stroke(allBangs,allBangs,allBangs);


    }
  }
  if(pass > 12 ){
    //this part is via https://gist.github.com/Bleuje/75347b04a29bb8442fe88f2f5aed2ee1
    blendMode(BLEND);
    offscreen.background(15);       
    float t = 1.0*(frameCount-1)%numFrames/numFrames;       
    float sumh = 0;
    for(int j = 0;j<m;j++){
      for(int x = margin;x<offscreen.width-margin;x++){
        float loop_radius = lines.get(j).lr;
        double ns = noise.eval(100*j+lines.get(j).scl*x,loop_radius*cos(TWO_PI*t),loop_radius*sin(TWO_PI*t));
        float col = constrain(map((float)ns,-0.05,0.05,0,255),0,255);
        offscreen.stroke(col);
        offscreen.line(x,margin+sumh,x,margin+lines.get(j).h+sumh);
      }
      sumh+=lines.get(j).h;
    }
    offscreen.stroke(255);
     blendMode(EXCLUSION);
     offscreen.noStroke();
     offscreen.fill(255,0,0);
     offscreen.ellipse(offscreen.width/2,offscreen.height/2, offscreen.width-2*margin, offscreen.height-2*margin);
     
     //mapping bang values to width of screen
     int newHighTomMap = (int) map(highTomBang,0,125,0, offscreen.width);
     int newKickMap = (int) map(kickBang,0,125,0, offscreen.width);
     int newKickDelayMap =  (int) map(kickDelayBang,0,125,0, offscreen.width);
     int newLowTomMap = (int) map(lowTomBang,0,125,0, offscreen.width);
     int newAllBangsMap = (int) map(allBangs,0,125,0, offscreen.width);
     //now drawing them as they move 
     offscreen.rect(newHighTomMap,0,80,offscreen.height/5);
     offscreen.rect(newKickMap,offscreen.height/5,80,offscreen.height/5);
     offscreen.rect(newKickDelayMap,offscreen.height/5*2,80,offscreen.height/5);
     offscreen.rect(newLowTomMap,offscreen.height/5*3,80,offscreen.height/5);
     offscreen.rect(newAllBangsMap,offscreen.height/5*4,80,offscreen.height/5);
  }
  if(pass > 15){
    offscreen.background(0,0,255);
    offscreen.line(random(offscreen.height),random(offscreen.width),random(offscreen.height),random(offscreen.width));
    offscreen.noStroke();
    offscreen.fill(255,0,0);
    float size = random(allBangs%2)*random(400);
    offscreen.rect((offscreen.width/2)-size/2,(offscreen.height/2)-size/2,size,size);
    offscreen.fill(255);
    offscreen.stroke(0,255,0);
  }

  if(pass >= 15){
    //
    offscreen.stroke(255,0,0);
    float[] newLine = {prevLineMidpoint[0],prevLineMidpoint[1],random(height),random(width)};
    prevLineMidpoint[0] = random(newLine[0],newLine[2]);
    prevLineMidpoint[1] = ((newLine[2]-newLine[1])/(newLine[1]-newLine[3])*(prevLineMidpoint[0]-newLine[0]))+newLine[1];
    offscreen.line(newLine[0],newLine[1],newLine[2],newLine[3]);
  }
  if (pass ==20){
    pass =0;
  }
  
  println(allBangsReceived[2]);

  //after the draw cycle, we see which bangs updated 
  allPrevBangsReceived = allBangsReceived.clone();
  offscreen.endDraw();
  surface.render(offscreen);
  
  //load everything into our PGraphics
  offscreen.loadPixels(); 
  offscreen1.loadPixels();
  offscreen2.loadPixels();
  offscreen3.loadPixels();
  offscreen4.loadPixels();
  arrayCopy(offscreen.pixels, offscreen1.pixels);
  arrayCopy(offscreen.pixels, offscreen2.pixels); 
  arrayCopy(offscreen.pixels, offscreen3.pixels); 
  arrayCopy(offscreen.pixels, offscreen4.pixels);
  offscreen1.updatePixels();
  offscreen2.updatePixels();
  offscreen3.updatePixels();
  offscreen4.updatePixels();
  //surface1.render(offscreen1);
  //surface2.render(offscreen2);
  //surface3.render(offscreen3);
  //surface4.render(offscreen4);
}

class Line{
  float lr;
  float scl;
  float h;
  
  Line(float lr_,float scl_, float h_){
    lr = lr_;
    scl = scl_;
    h = h_;
  }
}
ArrayList<Line> lines = new ArrayList<Line>();


void didBangsUpdate(){
   //not great practice shows which bangs were updated
  for(int i = 0; i<allBangsReceived.length; i++){
    bangsDidUpdate[i] = allBangsReceived[i] != allPrevBangsReceived[i];
  } 
}

void oscEvent(OscMessage theOscMessage) {
  
    //gets messages from Pure Data
    this.kickBang = theOscMessage.get(0).intValue();
    this.kickDelayBang = theOscMessage.get(1).intValue();
    this.lowTomBang = theOscMessage.get(2).intValue();
    this.allBangs = theOscMessage.get(3).intValue();
    this.allBangs = theOscMessage.get(4).intValue();  
    
    //adds it to all bangs received array
    allBangsReceived[4] = allBangs;
    allBangsReceived[1] = kickBang;
    allBangsReceived[2] = kickDelayBang;
    allBangsReceived[3] = lowTomBang;
    allBangsReceived[4] = highTomBang; 
    didBangsUpdate();
    if(this.allBangs <= 5){    //checks rollover with leniency
      
      this.pass++;
      println("rollOver");
    }
   
   
    return;
  }
  
void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}  