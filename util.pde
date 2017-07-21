


float cdist(color c, color d) {
  return (abs(red(d) - red(c)) + abs(green(d) - green(c)) + abs(blue(d) - blue(d))) / 3.0;
}

boolean cd(color c, color d) {
  return cdist(c, d) < 2;
}

int sid = 0;
int prevState = -1;
int curState = -1;
int samples = 0;
state cur;

ArrayList<state> states = new ArrayList<state>();

class state {
  int id;
  String annotation;
  //color and pos
  color[] colors;
  int[] pos;
  boolean OR = false;
  state(int... cnp) {
    states.add(this);
    id = sid;
    sid = sid + 1;
    colors = new color[cnp.length / 3];
    pos = new int[cnp.length / 3 * 2];

    for (int i = 0; i < cnp.length; i += 3) {
      colors[i / 3]        = (color)cnp[i];
      pos[i / 3 * 2]       = cnp[i + 1] / checkBufDiv;
      pos[i / 3 * 2 + 1]   = cnp[i + 2] / checkBufDiv;
    }
  }
  boolean check() {
    for (int i = 0; i < colors.length; i++) {
      color c = checkBuf.get(pos[i * 2], pos[i * 2 + 1]);
      if (OR) {
        if (cd(c, colors[i])) { 
          return true;
        }
      } else {
        if (!cd(c, colors[i])) { 
          return false;
        }
      }
    }
    if (OR) {
      return false;
    }
    return true;
  }
}

state state(int... cnp) {
  return new state(cnp);
}

state state(String annotation, boolean OR, int... cnp) {
  state s = new state(cnp);
  s.OR = OR;
  s.annotation = annotation;
  return s;
}

void setState(state s) {
  int id = s == null ? -1 : s.id;
  if (curState != id) {
    samples++;
    if (samples > 1) {
      prevState = curState;
      curState = id;
      cur = s;
      println("Current State", id);
    }
  } else {
    samples = 0;
  }
}

void updateStates() {
  for (int i = 0; i < states.size(); i++) {
    state s = states.get(i);
    if (s.check()) {
      setState(s);
      return ;
    }
  }
  setState(null);
  return;
}


void setupStates() {
state("App Menu", false, 
  -15725296, 340,912,
  -10790821, 208,916,
  -513, 238,906,
  -3816507,78,918
);

state("Conversation", true, 
  -3685176, 94, 844, //BTN_L
  -5061904, 378, 836 //BTN_R
);

state("Conversation - Recording", true, 
  -2105889, 150, 852, //BTN_L
  -2497793, 372, 840, //BTN_R
  -2563585, 378, 840 //BTN_R/BK
);

state("Camera - Snapped", true, 
  -12217089, 164, 876, //BTN_D
  -12217089, 356, 886,  //BTN_D_BK
  -4073739, 228,872,
  -6905163, 226,870
  );

state("Camera", true, 
  -12217089, 248, 852, //BTN_D
  -12151553, 280, 852, //BTN_D_BK
  -9653505, 250, 866
  );

state("Camera - No Data", false, 
  -1711387, 262,123, //BTN_D
  -257,58,864, //BTN_D_BK,
  -2237475,100,193
  );
}