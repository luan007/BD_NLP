
import codeanticode.syphon.*;
float div = 1.5;
int checkBufDiv = 8;
PImage img;
PGraphics checkBuf;

SyphonClient client;
void settings() {
  size((int)(1920 / div), (int)(1080 / div), P3D);
  smooth(8);
  PJOGL.profile = 1;
}

void setup() {
  initPhone();
  checkBuf = createGraphics(525 / checkBufDiv, 933 / checkBufDiv, OPENGL);
  client = new SyphonClient(this);
  //surface.setAlwaysOnTop(true);
  c = color(0, 0, 0);
  setupStates();
  setupMessages();
  setupOsc();
  smooth(4);
}

int dmX;
int dmY;
color c;
void draw() {
  background(c);
  background(30);
  
  dmX = (int)(mouseX * div);
  dmY = (int)(mouseY * div);
  scale((float) 1 / div);
  
  drawBgFx();
  drawPhone();
  if (client.newFrame()) {
    img = client.getImage(img, false); // does not load the pixels array (faster) 
    if (frameCount % 10 == 0) {
      checkBuf.beginDraw();
      checkBuf.image(img, 0, 0, 525 / checkBufDiv, 933 / checkBufDiv);
      checkBuf.endDraw();
      updateStates();
    }
  }
  if (img == null) {
    return;
  }
  //renderDebug();
  pushMatrix();
  imageMode(CENTER);
  translate(1920 / 2, 1080 / 2);
  //image(img, 0, 0, 525, 933);
  //imageMode(CORNER);
  
  
  popMatrix();
}

void renderDebug() {
  image(checkBuf, 0, 0, 525 / checkBufDiv, 933 / checkBufDiv);
  fill(255, 0, 0);
  textSize(30);
  text("State=" + ((cur == null) ? "Nothing" : cur.annotation), 30, 50);
  c = checkBuf.get(dmX / checkBufDiv, dmY / checkBufDiv);
  if (mousePressed) {
    println(dmX + "," + dmY + "," + c);
  }
}