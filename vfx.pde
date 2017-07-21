void drawBgFx() {
  int step = 100;
  pushMatrix();
  translate(1920 / 2, 1080 / 2, -150);
  for (int x = -1920 / 2; x <= 1920 / 2; x+=step) {
    for (int y = -1080 / 2; y <= 1080 / 2; y+=step) {
      float xp = (float(x) / 1920.0 - 0.5) * 2;
      float yp = (float(y) / 1080.0 - 0.5) * 2;
      pushMatrix();
      rectMode(CENTER);
      fill(#02afff); //,#518bba
      translate(x, y);
      noStroke();
      float ft = noise(
        (float)x / 300.0, 
        (float)y / 300.0, 
        (float)millis() / 1000.0 - (float)y / 3000.0
        );
      ft = pow(ft, 5) * 3;
      //ft = ft;
      scale(ft, ft);
      ellipse(0, 0, 30, 30);
      popMatrix();
    }
  }
  
  _sparks.update();
  popMatrix();
}

sparksys _sparks = new sparksys();

class sparksys extends psys<spark> {
  int maxDepth = 5;
  float maxGen = 4;
  String wordBuf = "*测试*adfasd*";
  sparksys() {
    this.autoClean = true;
  }
  void onautodelete(int id, spark p) {
    //init more
    spark(p.depth + 1, p.p);
  }

  void spark(int depth, PVector pos) {
    if (depth > maxDepth) {
      return; //stop here
    }
    float rand = round(random(0, maxGen));
    for (int i = 0; i < rand; i++ ) {
      spark s = new spark();
      s.p = pos.copy();
      s.s = random(1, 2);
      s.txt = wordBuf.charAt(floor(random(wordBuf.length()))) + "";
      s.init = pos.copy();
      s.depth = depth;
      s.v = new PVector(random(-1, 1) * 15, random(-1, 1) * 15,  random(1) > 0.5 ? 5 : -5);
      s.l = 1;
      s.vl = random(0.02, 0.2);
      this.add(s);
    }
  }
}

class spark extends p {
  int depth = 0;
  PVector ta;
  float s;
  PVector prev;
  PVector init;
  String txt;
  float THRESHOLD = 50;
  void onupdate() {
    ta = ta == null ? new PVector(0, 0, 0) : ta;
    if (prev == null|| PVector.dist(p, prev) > THRESHOLD) {
      prev = p.copy();
    }
    this.a = ta.copy();
  }
  void render() {
    pushMatrix();
    stroke(10);
    strokeWeight(1);
    noFill();
    beginShape(LINES);
    stroke(255,255,255, this.l * 255);
    vertex(p.x, p.y, p.z);
    stroke(10, 150, 255, this.l * 255);
    vertex(init.x, init.y, init.z);
    endShape();
    translate(init.x, init.y, init.z);
    noStroke();
    scale(this.s - this.l * this.l * this.s);
    textFont(mainFont);
    textAlign(CENTER, CENTER);
    textSize(20);
    fill(255, l * 255);
    text(this.txt, 0, -3);
    popMatrix();
  }
}