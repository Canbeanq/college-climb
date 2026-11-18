// ============================================================
// THE COLLEGE CLIMB  -  combined sketch
// Plan your 168 hours each week, then climb to the next camp
// in a platforming level (2 levels, stored in arrays).
//
// Put these files in a folder named "data" next to this sketch:
//   mountain.png, player.png, platform_.png, coin_.png
// (Assets: https://drive.google.com/drive/folders/1zcIXtAC27vk4cGV0bXtSXd6EhIhnXZ3G)
// If an image is missing the game draws simple shapes instead.
//
// Save this file in a folder called College_Climb.
// ============================================================
// hello world

final int TOTAL_HOURS = 168;
final int MAX_WEEKS = 15;

// ---------- game state ----------
String screen = "start";   // start, planner, platformer, summary, end
int intWeeks, intGrades, intHappiness, intHealth, intMoney, brokeWeeks;
int[] hours = new int[5];  // sleep, classes, study, work, friends/free time
String[] labels = {"Sleep / self-care", "Classes", "Study", "Work", "Friends / free time"};
int intplayerX, intplayerY;      // position on the mountain map

boolean gameOver = false;
boolean won = false;
String endMessage = "";
String[] summaryLines = new String[6];

// ---------- images ----------
PImage mountainImg, playerImg, platformImg, coinImg;

// ---------- platformer: movement ----------
float charX, charY;
int charLength = 40;
int charHeight = 40;
int ground = 550;
float jumpSpeed = 0;
float walkSpeed = 4;
float gravity = 0.6;
float jumpStrength = -13.0;
boolean onGround = false;
boolean walkL = false;
boolean walkR = false;

// ---------- platformer: level data (ARRAYS) ----------
// levelPlats[level][platform] = {x, y, width, height}
int[][][] levelPlats = {
  { // LEVEL 1
    {150, 470, 120, 20},
    {320, 400, 120, 20},
    {500, 330, 120, 20},
    {650, 260, 120, 20}
  },
  { // LEVEL 2 (more platforms, higher climb)
    {100, 480, 100, 20},
    {260, 420,  90, 20},
    { 80, 340,  90, 20},
    {250, 270,  90, 20},
    {430, 330,  90, 20},
    {590, 260,  90, 20},
    {680, 170, 100, 20}
  }
};

// levelCoins[level][coin] = {x, y}
int[][][] levelCoins = {
  { {190, 430}, {360, 360}, {540, 290}, {670, 220}, {420, 510} },
  { {130, 440}, {290, 380}, {110, 300}, {280, 230}, {460, 290}, {620, 220} }
};

// levelGoal[level] = {x, y} of the camp flag (30 wide, 60 tall)
int[][] levelGoal  = { {730, 200}, {740, 110} };
// levelStart[level] = {x, y} where the player starts
int[][] levelStart = { {50, 510}, {50, 510} };

int currentLevel = 0;
boolean[] got;         // which coins were collected this level
int coinsThisWeek = 0;
boolean debugHitboxes = false;

// ============================================================
void setup() {
  size(800, 600);
  mountainImg = loadImage("mountain.png");
  playerImg   = loadImage("player.png");
  platformImg = loadImage("platform_.png");
  coinImg     = loadImage("coin_.png");
  resetGame();
}

// sets week back to 1, stats to starting values, goes to start screen
void resetGame() {
  intWeeks = 1;
  intGrades = 75;
  intHappiness = 70;
  intHealth = 80;
  intMoney = 500;
  brokeWeeks = 0;
  hours[0] = 56; hours[1] = 15; hours[2] = 10; hours[3] = 10; hours[4] = 20;
  intplayerX = 50;
  intplayerY = height - 100;
  gameOver = false;
  won = false;
  screen = "start";
}

int totalHours() {
  int t = 0;
  for (int h : hours) t += h;
  return t;
}

void draw() {
  if (screen.equals("start"))          drawStartScreen();
  else if (screen.equals("planner"))   drawWeekPlanner();
  else if (screen.equals("platformer")) drawPlatformer();
  else if (screen.equals("summary"))   drawSummary();
  else if (screen.equals("end"))       drawEndScreen();
  time(intHealth);
 
}

// ============================================================
// SCREENS
// ============================================================
void drawStartScreen() {
  background(70, 60, 120);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(56);
  text("THE COLLEGE CLIMB", width / 2, 120);
  textSize(20);
  text("Reach the top of the mountain by surviving 15 weeks of college.", width / 2, 210);
  text("Each week, split your 168 hours between sleep, class, study, work, and fun.", width / 2, 245);
  text("Then climb to the next camp. Keep your grades, health, and money alive!", width / 2, 280);
  text("Left/Right arrows to move, UP or SPACE to jump. Clear 2 levels each week.", width / 2, 330);
  drawButton("START", 300, 380, 200, 60, 28);
}

void drawWeekPlanner() {
  background(40, 40, 80);
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(32);
  text("Week " + intWeeks + " of " + MAX_WEEKS, 30, 40);

  int hoursLeft = TOTAL_HOURS - totalHours();
  textSize(22);
  if (hoursLeft < 0) fill(255, 80, 80); else fill(255);
  text("Hours left: " + hoursLeft, 30, 90);

  textSize(20);
  for (int i = 0; i < labels.length; i++) {
    int rowY = 150 + i * 60;
    fill(255);
    textAlign(LEFT, CENTER);
    text(labels[i], 30, rowY + 20);

    // minus button
    fill(235, 90, 80);
    stroke(0);
    strokeWeight(2);
    rect(300, rowY, 40, 40);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(28);
    text("-", 320, rowY + 18);

    // hours
    fill(255);
    textSize(20);
    text(hours[i], 360, rowY + 20);

    // plus button
    fill(130, 220, 90);
    stroke(0);
    strokeWeight(2);
    rect(380, rowY, 40, 40);
    fill(0);
    textSize(28);
    text("+", 400, rowY + 19);
  }

  drawButton("Next Week", 250, 500, 180, 50, 22);

  drawStats();
  drawMountain();
}

// stat bars on the right side of the planner
void drawStats() {
  String[] names = {"Grades", "Happiness", "Health", "Money ($" + intMoney + ")"};
  float[] vals = {intGrades, intHappiness, intHealth, constrain(intMoney / 10.0, 0, 100)};
  for (int i = 0; i < names.length; i++) {
    float x = 470;
    float y = 100 + i * 55;
    fill(255);
    noStroke();
    textAlign(LEFT, CENTER);
    textSize(16);
    text(names[i], x, y - 15);
    stroke(0);
    strokeWeight(2);
    fill(245);
    rect(x, y, 280, 14);
    noStroke();
    if (i == 0) fill(90, 160, 255);
    else if (i == 1) fill(255, 210, 80);
    else if (i == 2) fill(120, 220, 120);
    else fill(120, 200, 120);
    rect(x, y, map(constrain(vals[i], 0, 100), 0, 100, 0, 280), 14);
  }
}

// mountain map with a marker that climbs a little each week
void drawMountain() {
  float mx = 450, my = 340, mw = 330, mh = 240;
  if (mountainImg != null) {
    image(mountainImg, mx, my, mw, mh);
  } else {
    stroke(0);
    strokeWeight(2);
    fill(110, 120, 140);
    triangle(mx, my + mh, mx + mw * 0.6, my, mx + mw, my + mh);
    fill(255);
    triangle(mx + mw * 0.6 - 35, my + 50, mx + mw * 0.6, my, mx + mw * 0.6 + 35, my + 50);
  }
  float t = (intWeeks - 1) / (float) MAX_WEEKS;
  intplayerX = int(mx + 30 + t * (mw * 0.6 - 30));
  intplayerY = int(my + mh - 20 - t * (mh - 20));
  if (playerImg != null) {
    imageMode(CENTER);
    image(playerImg, intplayerX, intplayerY, 28, 28);
    imageMode(CORNER);
  } else {
    fill(255, 140, 90);
    stroke(0);
    ellipse(intplayerX, intplayerY, 18, 18);
  }
}

void drawSummary() {
  background(40, 40, 80);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("Week " + intWeeks + " complete!", width / 2, 90);
  textSize(22);
  for (int i = 0; i < summaryLines.length; i++) {
    if (summaryLines[i] != null) text(summaryLines[i], width / 2, 160 + i * 40);
  }
  drawButton(gameOver ? "See result" : "Continue", 300, 480, 200, 60, 24);
}

void drawEndScreen() {
  background(won ? color(60, 120, 80) : color(120, 50, 60));
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  text(won ? "YOU REACHED THE SUMMIT!" : "GAME OVER", width / 2, 150);
  textSize(22);
  text(endMessage, width / 2, 230);
  text("Final: Grades " + intGrades + "  Happiness " + intHappiness + "  Health " + intHealth + "  Money $" + intMoney, width / 2, 290);
  drawButton("Play Again", 300, 380, 200, 60, 24);
}

// ============================================================
// PLATFORMER
// ============================================================
// starts the gameplay for a week: level 1 first, then level 2
void startWeekGameplay() {
  coinsThisWeek = 0;
  loadLevel(0);
}

// loads one level from the arrays and puts the player at its start
void loadLevel(int lvl) {
  currentLevel = lvl;
  got = new boolean[levelCoins[currentLevel].length];
  charX = levelStart[currentLevel][0];
  charY = levelStart[currentLevel][1];
  jumpSpeed = 0;
  onGround = false;
  walkL = false;
  walkR = false;
  screen = "platformer";
  
  // loads the timer that calculates the time the player has in the level
 
}

void drawPlatformer() {
  background(135, 190, 235);

  // ground
  noStroke();
  fill(120, 85, 50);
  rect(0, ground, width, height - ground);

  updatePlayer();

  // platforms
  for (int i = 0; i < levelPlats[currentLevel].length; i++) {
    int[] p = levelPlats[currentLevel][i];
    cPlat(p[0], p[1], p[2], p[3]);
  }

  // coins
  for (int i = 0; i < levelCoins[currentLevel].length; i++) {
    if (!got[i]) {
      int[] c = levelCoins[currentLevel][i];
      int[] pos = collectible(coinImg, c[0], c[1]);
      // collision: player rectangle vs coin box (30 x 30)
      if (charX < pos[0] + 30 && charX + charLength > pos[0] &&
          charY < pos[1] + 30 && charY + charHeight > pos[1]) {
        got[i] = true;
        coinsThisWeek++;
      }
    }
  }

  // goal flag (the next camp)
  int gx = levelGoal[currentLevel][0];
  int gy = levelGoal[currentLevel][1];
  stroke(0);
  strokeWeight(3);
  line(gx, gy, gx, gy + 60);
  noStroke();
  fill(255, 80, 80);
  triangle(gx, gy, gx + 30, gy + 12, gx, gy + 24);

  // player
  if (playerImg != null) {
    image(playerImg, charX, charY, charLength, charHeight);
  } else {
    stroke(0);
    strokeWeight(2);
    fill(255, 140, 90);
    rect(charX, charY, charLength, charHeight);
  }

  // reached the flag?
  if (charX < gx + 30 && charX + charLength > gx && charY < gy + 60 && charY + charHeight > gy) {
    if (currentLevel < levelPlats.length - 1) {
      loadLevel(currentLevel + 1);   // level 1 done -> level 2
    } else {
      finishWeek();                  // level 2 done -> week is over
    }
    return;
  }

  // HUD
  fill(0);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Week " + intWeeks + "  -  Level " + (currentLevel + 1) + " of " + levelPlats.length + "   Coins this week: " + coinsThisWeek, 15, 12);
  textSize(14);
  text("Move: LEFT / RIGHT arrows    Jump: UP arrow or SPACE    Reach the flag!", 15, 38);
}

// applies gravity, walking, ground + platform collision
void updatePlayer() {
  float prevBottom = charY + charHeight;

  if (walkL) charX -= walkSpeed;
  if (walkR) charX += walkSpeed;
  charX = constrain(charX, 0, width - charLength);

  jumpSpeed += gravity;
  charY += jumpSpeed;
  onGround = false;

  // ground collision
  if (charY + charHeight >= ground) {
    charY = ground - charHeight;
    jumpSpeed = 0;
    onGround = true;
  }

  // platform collision (only land on top while falling)
  for (int i = 0; i < levelPlats[currentLevel].length; i++) {
    int[] p = levelPlats[currentLevel][i];
    boolean overlapX = charX + charLength > p[0] && charX < p[0] + p[2];
    if (jumpSpeed >= 0 && overlapX && prevBottom <= p[1] && charY + charHeight >= p[1]) {
      charY = p[1] - charHeight;
      jumpSpeed = 0;
      onGround = true;
    }
  }
  //calculates the time the player has in each level
  time(intHealth);
}

// draws a platform and returns {x, y, w, h} for collision
int[] cPlat(int xpos, int ypos, int xsize, int ysize) {
  int[] platPos = {xpos, ypos, xsize, ysize};
  if (platformImg != null) {
    image(platformImg, xpos, ypos, xsize, ysize);
  } else {
    stroke(0);
    strokeWeight(2);
    fill(110, 75, 40);
    rect(xpos, ypos, xsize, ysize);
  }
  if (debugHitboxes) {
    noFill();
    stroke(255, 0, 0);
    rect(xpos, ypos, xsize, ysize);
  }
  return platPos;
}

// draws a coin at (colX, colY) and returns {x, y} for collision
int[] collectible(PImage sprite, int colX, int colY) {
  if (sprite != null) {
    image(sprite, colX, colY, 30, 30);
  } else {
    stroke(0);
    strokeWeight(2);
    fill(255, 215, 0);
    ellipseMode(CORNER);
    ellipse(colX, colY, 30, 30);
  }
  if (debugHitboxes) {
    noFill();
    stroke(255, 0, 0);
    ellipseMode(CORNER);
    ellipse(colX, colY, 30, 30);
  }
  int[] collectPos = {colX, colY};
  return collectPos;
}

// ============================================================
// END OF WEEK: hours chosen + coins collected change the stats
// ============================================================
void finishWeek() {
  walkL = false;
  walkR = false;

  int sleep = hours[0], classes = hours[1], study = hours[2], work = hours[3], fun = hours[4];

  int dGrades = round((classes + study - 25) * 0.4);
  int dHealth = round((sleep - 50) * 0.5 - max(0, work + study - 30) * 0.3);
  int dHappy  = round((fun - 15) * 0.5 + (sleep - 50) * 0.1 - max(0, study - 20) * 0.3) + 2;
  int dMoney  = work * 15 - 120 - fun * 2 + coinsThisWeek * 25;

  intGrades    = constrain(intGrades + dGrades, 0, 100);
  intHealth    = constrain(intHealth + dHealth, 0, 100);
  intHappiness = constrain(intHappiness + dHappy, 0, 100);
  intMoney    += dMoney;
  if (intMoney <= 0) {
    intMoney = 0;
    brokeWeeks++;
  } else {
    brokeWeeks = 0;
  }

  summaryLines = new String[6];
  int totalCoins = 0;
  for (int i = 0; i < levelCoins.length; i++) totalCoins += levelCoins[i].length;
  summaryLines[0] = "Coins collected: " + coinsThisWeek + " of " + totalCoins + "  (+$" + (coinsThisWeek * 25) + ")";
  summaryLines[1] = "Grades: " + signed(dGrades) + "  (now " + intGrades + ")";
  summaryLines[2] = "Happiness: " + signed(dHappy) + "  (now " + intHappiness + ")";
  summaryLines[3] = "Health: " + signed(dHealth) + "  (now " + intHealth + ")";
  summaryLines[4] = "Money: " + signed(dMoney) + "  (now $" + intMoney + ")";
  if (brokeWeeks > 0) summaryLines[5] = "You're broke! (" + brokeWeeks + "/3 weeks)";

  // win / lose checks
  if (intHealth <= 0) {
    gameOver = true; won = false; endMessage = "Your health collapsed. Time to rest!";
  } else if (intHappiness <= 0) {
    gameOver = true; won = false; endMessage = "You burned out completely.";
  } else if (intGrades < 30) {
    gameOver = true; won = false; endMessage = "Your grades dropped too low - you failed out.";
  } else if (brokeWeeks >= 3) {
    gameOver = true; won = false; endMessage = "You were out of money for 3 weeks straight.";
  } else if (intWeeks >= MAX_WEEKS) {
    gameOver = true; won = true; endMessage = "You survived all 15 weeks of college!";
  }

  screen = "summary";
  
  
}

String signed(int v) {
  return (v >= 0 ? "+" : "") + v;
}

// ============================================================
// INPUT
// ============================================================
void mousePressed() {
  if (screen.equals("start")) {
    if (isMouseOver(300, 380, 200, 60)) screen = "planner";

  } else if (screen.equals("planner")) {
    int hoursLeft = TOTAL_HOURS - totalHours();
    for (int i = 0; i < hours.length; i++) {
      int rowY = 150 + i * 60;
      if (isMouseOver(300, rowY, 40, 40) && hours[i] > 0) hours[i]--;
      if (isMouseOver(380, rowY, 40, 40) && hoursLeft > 0) {
        hours[i]++;
        hoursLeft--;
      }
    }
    if (isMouseOver(250, 500, 180, 50) && TOTAL_HOURS - totalHours() >= 0) startWeekGameplay();

  } else if (screen.equals("summary")) {
    if (isMouseOver(300, 480, 200, 60)) {
      if (gameOver) {
        screen = "end";
      } else {
        intWeeks++;
        screen = "planner";
      }
    }

  } else if (screen.equals("end")) {
    if (isMouseOver(300, 380, 200, 60)) resetGame();
  }
}

void keyPressed() {
  if (!screen.equals("platformer")) return;

  if ((key == ' ' || keyCode == UP) && onGround) {
    jumpSpeed = jumpStrength;
    onGround = false;
  }
  if (keyCode == RIGHT) walkR = true;
  if (keyCode == LEFT)  walkL = true;
}

void keyReleased() {
  if (keyCode == RIGHT) walkR = false;
  if (keyCode == LEFT)  walkL = false;
}

// ============================================================
// HELPERS
// ============================================================
boolean isMouseOver(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}

void drawButton(String label, float x, float y, float w, float h, int ts) {
  if (isMouseOver(x, y, w, h)) fill(255, 160, 110); else fill(255, 140, 90);
  stroke(0);
  strokeWeight(3);
  rect(x, y, w, h);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(ts);
  text(label, x + w / 2, y + h / 2 - 2);
}

// function that calculates the time the player has in the level
void time(int health){
  int levelTime =  (health/2)- 20;
  for (int i=0; i<levelTime; i++){
    levelTime = levelTime - 1;
  }
   if (levelTime == 0){
      resetGame();
    }
  
  println(levelTime);
  
}
