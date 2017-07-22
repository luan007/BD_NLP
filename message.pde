intros messageIntro = new intros(new String[]{
  "词法分析",
  "依存句法分析",
  "词向量表示",
  "DNN语言模型",
  "词义相似度",
  "短文本相似度",
  "评论观点抽取",
  "情感倾向分析"
});

String dancer = ">>";

String breakStr(String s, int max) {
  String j = "";
  int l = 0;
  for (int i = 0; i < s.length(); i++) {
    j += s.charAt(i);
    if (s.charAt(i) == '\n') {
      l = 0;
      continue;
    } 
    l++;
    if (l > max) {
      l = 0;
      j += "\n";
    }
  } 
  return j;
}

PFont mainFont;

msgBoard real = new msgBoard();
msgBoard translation = new msgBoard();
msgSplash dynamic = new msgSplash();

void setupMessages() {
  mainFont = createFont("PingFang SC", 25, true);
}

String conv_lastPiece = "";
void addConversationMessage(String text) {
  if (random(1) > 0.5) {
    dynamic.addMessage(0, 1, (text));
  } else {
    dynamic.addMessage(1, 1, (text));
  }
  if (random(1) > 0.9) {
    dynamic.addMessage(0, 2, "{ ... }");
  }
  _sparks.wordBuf = text;
  _sparks.spark(0, new PVector(random(-2, 2), random(-2, 2), -10));
  conv_lastPiece = text;
}

void addTranslationMessage(String text, int en) {
  if (en > 1) {
    en = 1;
  }
  _sparks.wordBuf = text;
  for(int i = 0; i <10; i++ ){
  _sparks.spark(0, new PVector(random(-2, 2), random(-2, 2), -10));
  }
  real.addMessage(1 - en, 1, conv_lastPiece);
  translation.addMessage(1 - en, 0, text);
}

void updateMessages() {
  
  
  pushMatrix();
  scale(min(1, cPerspective * 10));
  
  real.update();
  translate(0, 0, 200);
  translation.update();
  translate(-500, 0, -800);
  dynamic.update();
  popMatrix();
}

public class msgSplash extends psys<msg> {
  void addMessage(int en, int mode, String l) {
    msg m = new msg();
    m.lines = breakStr(l, 30);
    m.calculateSize();
    m.mode = mode;
    m.r = 10;
    m.state = en;
    float randH = m.h * (3.5 + random(1));
    m.visibility.set(0, 1);
    m.p = new PVector(random(-300, 300), randH, -200);
    m.target.pos = new PVector(m.p.x, 0, random(-400, 0));
    for (int i = 0; i < this.ps.size(); i++) {
      this.ps.get(i).target.pos.add(new PVector(0, -randH));
      if (this.ps.get(i).target.pos.y < -1000) {
        this.ps.get(i).visibility.target = 0;
      }
      this.ps.get(i).dead = this.ps.get(i).visibility.val == 0 &&
        this.ps.get(i).visibility.target == 0;
    }
    this.add(m);
  }
}

public class msgBoard extends psys<msg> {
  void addMessage(int en, int mode, String l) {
    msg m = new msg();
    m.lines = breakStr(l, 30);
    m.calculateSize();
    m.mode = mode;
    m.r = 10;
    m.state = en;
    m.visibility.set(0, 1);
    m.p = new PVector(en == 0 ? 150 : -150, m.h * 2.5, -200);
    m.target.pos = new PVector(m.p.x, 0, 0);
    for (int i = 0; i < this.ps.size(); i++) {
      this.ps.get(i).target.pos.add(new PVector(0, -m.h * 2.5));
      if (this.ps.get(i).target.pos.y < -1000) {
        this.ps.get(i).visibility.target = 0;
      }
      this.ps.get(i).dead = this.ps.get(i).visibility.val == 0 &&
        this.ps.get(i).visibility.target == 0;
    }
    this.add(m);
  }
}

public class msg extends p {

  ptarget target = new ptarget(this);
  pvalue visibility = new pvalue(this);

  int mode = 0;
  String lines;
  float h = 100;
  float w = 200;
  float r =  20;
  float prec = 0.2;
  int state = 0;
  
  float born = millis();

  void calculateSize() {
    textFont(mainFont);
    int l = lines.split("\n").length;
    float h = l * (25 + 3);
    float w = (textWidth(this.lines));

    this.w = w / 2 + 30;
    this.h = h + 10;
  }

  void baseShape() {
    beginShape();
    for (float deg = 0; deg < 1; deg += prec) {
      vertex(w - r * cos(PI + deg * PI / 2) - r, 
        -h + r * sin(PI + deg * PI / 2) + r);
    }
    for (float deg = 0; deg < 1; deg += prec) {
      vertex(-w + r * cos(deg * PI / 2 + PI / 2) + r, 
        -h - r * sin(deg * PI / 2 + PI / 2) + r);
    }

    if (state == 1) {
      vertex(-w, h - r - 10);
      vertex(-w - r - 10, h);
    } else {
      for (float deg = 0; deg < 1; deg += prec) {
        vertex(-w + r * cos(deg * PI / 2 + PI) + r, 
          h - r * sin(deg * PI / 2 + PI) - r);
      }
    }
    if (state == 0) {
      vertex(w + r + 10, h);
      vertex(w, h - r - 10);
    } else {
      for (float deg = 0; deg < 1; deg += prec) {
        vertex(w - r * cos(-deg * PI / 2 - PI / 2) - r, 
          h - r * sin(-deg * PI / 2 - PI / 2) - r);
      }
    }
    endShape(CLOSE);
  }

  void render() {
    pushMatrix();
    noStroke();
    float opa = (1 / (1 + abs(this.p.y) / 500));
    
    translate(p.x, p.y, p.z);

    if (mode != 2) {
      pushMatrix();
      if (state == 0) {
        translate(w + r + 10, h, -5);
      } else {
        translate(-w - r - 10, h, -5);
      }
      float sz = pow(((float)millis() / 1500 - born / 1500) % 1, 3);
      scale(sz * 3);
      stroke(255, 120 * (1 - sz));
      noFill();
      strokeWeight(1);
      ellipse(0, 0, 30, 30);
      noStroke();
      popMatrix();
    }


    if (mode == 0) {
      if (state == 0) {
        fill(50, 130, 255, opa * 255);
      } else {
        fill(255, opa * 255);
      }
    } else {
      noFill();
      if (state == 0) {
        fill(0, 50);
        stroke(50, 130, 255, opa * 255);
      } else {
        fill(0, 50);
        stroke(200, opa * 255);
      }
    }
    scale(visibility.val);
    if (mode != 2) {
      baseShape();
      translate(0, 0, -20);
      fill(255, mode == 0 ? 100 : 0);
      baseShape();
      blendMode(ADD);
      translate(0, 0, 40);
      noFill();
      strokeWeight(1);
      stroke(255, mode == 0 ? 100 : 0);
      baseShape();
      blendMode(BLEND);
    }

    textFont(mainFont);
    translate(0, 0, 10);
    if (state == 1 && mode == 0) {
      fill(50 * 0.3, 130 * 0.3, 255 * 0.3);
    } else {
      fill(255);
    }
    textAlign(LEFT, CENTER);
    text(this.lines, -w + r + r, 0);
    popMatrix();
  }
}