class intros extends psys<intro> {
  String[] introLst;
  intros(String[] intros) {
    this.introLst = intros;
    for (int i = 0; i < intros.length; i++) {
      intro p = new intro();
      p.txt = intros[i];
      float deg = float(i) / float(intros.length) * PI * 2;
      float r = 500;
      p.id = deg;
      p.p = new PVector(sin(deg) * r, cos(deg) * r, random(-100, 10));
      this.add(p);
    }
  }
}

class intro extends p {
  float id;
  String txt = "";
  float w = -1;
  void setText(String txt) {
    this.txt = txt;
    textFont(mainFont);
    this.w = textWidth(txt);
  }

  void render() {
    if (this.w == -1) {
      setText(this.txt);
    }
    float qp = cPerspective / 10;
    float cp = qp + 1;
    pushMatrix();
    float vec = sin(float(millis()) / 800 + id);
    fill(255);
    translate(p.x * cp, p.y * cp, p.z + vec * 10);
    textFont(mainFont);
    textAlign(CENTER, CENTER);
    text(this.txt, 0, 0);
    strokeWeight(2);
    float nz = noise(vec, float(millis()) / 100, p.x) * 255 * (qp * 3);
    fill(255, 10);
    fill(255, nz);
    rect(0, 5, w + 40, 60);
    for (float z = 0; z < 1; z+=0.1) {
      stroke(255, 10 + (vec - z) * 100);
      fill(255, nz * (vec - z));
      rect(0, 5, w + 40, 60);
      translate(0, 0, -50 - z * 10 * (2 * cp));
    }
    popMatrix();
  }
}