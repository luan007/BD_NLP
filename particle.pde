static class pstage {
  static int init   = 0b0001;
  static int v      = 0b0010;
  static int a      = 0b0100;
  static int p      = 0b1000;
}

public class psys<tp extends p> {
  ArrayList<tp> ps = new ArrayList<tp>();
  boolean autoClean = false;
  void add(tp p) {
    this.ps.add(p);
  }
  void remove(tp p) {
    this.ps.remove(p);
  }
  void onupdate() {
  }
  void onautodelete(int id, tp p) {
    
  }
  void update() {
    this.onupdate();
    for (int i = 0; i < ps.size(); i++) {
      ps.get(i).update();
      if (autoClean && ps.get(i).dead) {
        onautodelete(i, ps.get(i));
        ps.remove(i); //bad, bad code
        i--;
      }
    }
  }
}

public class p {
  PVector p = new PVector();
  PVector a = new PVector();
  PVector v = new PVector();
  float l;
  float vl;
  boolean dead;

  private ArrayList<behavior> b = new ArrayList<behavior>();

  void onupdate() {
  }
  void update() {
    if (dead) {
      return;
    }
    float t = 0.5; //10.0 / (float)frameRate;
    this.a.mult(0);

    for (behavior b : b) {
      if (!b.enabled || (b.stage & pstage.init) == 0) continue;
      b.update(pstage.init);
    }

    this.onupdate();

    for (behavior b : b) {
      if (!b.enabled || (b.stage & pstage.a) == 0) continue;
      b.update(pstage.a);
    }

    PVector da = PVector.mult(a, t);
    v.add(da);

    for (behavior b : b) {
      if (!b.enabled || (b.stage & pstage.v) == 0) continue;
      b.update(pstage.v);
    }

    p.add(PVector.mult(v, t));

    for (behavior b : b) {
      if (!b.enabled || (b.stage & pstage.p) == 0) continue;
      b.update(pstage.p);
    }
    if (vl > 0) {
      l -= vl * t;
      if (l < 0) {
        this.dead = true;
      }
    }
    this.render();
  }

  void render() {
    pushMatrix();
    fill(255, 0, 0);
    translate(p.x, p.y, p.z);
    rect(0, 0, 30, 30);
    popMatrix();
  }
}

public class behavior {
  p p;
  boolean enabled = true;
  int stage = 0;
  behavior(p p) {
    this.p = p; 
    p.b.add(this);
  }
  void update(int stage) {
  }
}

public class pvalue extends behavior {
  float PRECISION = 1;
  float val = 0;
  float target = 0;
  float E = 0.1;
  boolean complete = false;
  pvalue(p p) {
    super(p);
    this.stage = pstage.init;
  }
  void update(int stage) {
    float cur = ease(val, target, E);
    if (cur == val) {
      this.complete = true;
    } else {
      this.complete = false;
    }
    this.val = cur;
  }
  void set(float val, float target) {
    this.val = val;
    this.target = target;
  }
}

public class ptarget extends behavior {
  float PRECISION = 1;
  PVector pos = null;
  float rate = 0.1;
  float damper = 0.8;
  boolean complete = false;
  ptarget(p p) { 
    super(p);
    this.stage = pstage.init | pstage.v;
  }
  void update(int stage) {
    if (this.pos == null) {
      this.complete = false;
      return;
    }
    if (stage == pstage.init) {
      PVector d = PVector.sub(this.pos, p.p);
      this.complete = (abs(d.x) + abs(d.y) + abs(d.z)) < PRECISION;
      if (!this.complete) {
        p.a = PVector.mult(PVector.sub(this.pos, p.p), rate);
      }
    } else if (stage == pstage.v) {
      if (!this.complete) {
        p.v.mult(this.damper);
      }
    }
  }
}