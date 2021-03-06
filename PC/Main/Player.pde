// Player Class
public class Player extends GameObject {

  // Attributes
  private String name; // User name
  private int score;  // Current score
  private int save;
  private int highestScore;
  private int playerNumber;

  // Player avatar
  private PImage avatar[];
  private int avatarFrame; // For change the frame every "x" time

  // Health Points
  private int lifes;
  private int shield;

  //shots
  Laser lasers[];
  Missile missiles[];
  int shotDelay;

  // Builder
  public Player(String name, int save, int score, int highestScore, int playerNumber) {
    super(100);

    this.save = save;
    this.highestScore = highestScore;
    this.score = score;

    lifes = 3;
    shield = 0;
    shotDelay = 0;

    avatar = new PImage[2];
    lasers = new Laser[MAX_AMMO];
    missiles = new Missile[MAX_MISSILE];
    for (int i = 0; i < MAX_AMMO; i++) lasers[i] = new Laser();
    for (int i = 0; i < MAX_MISSILE; i++) missiles[i] = new Missile(this);

    if (playerNumber == 1) // PLayer 1 sprite
    {
      avatar[0] = loadImage("Resources/Images/spaceShips/goldenHeart/frame1.gif");
      avatar[1] = loadImage("Resources/Images/spaceShips/goldenHeart/frame2.gif");
      setX(width/3);
    } else // PLayer 2 sprite
    {
      avatar[0] = loadImage("Resources/Images/spaceShips/eagleRed/frame1.gif");
      avatar[1] = loadImage("Resources/Images/spaceShips/eagleRed/frame2.gif");
      setX(2*width/3);
    }

    avatarFrame = 0;
    this.name = name;
    this.highestScore = score;
    this.playerNumber = playerNumber;
    score = 0;
    setY(height - 100);
  }

  // Set methods
  void setScore(int score) {
    this.score = score;
  }

  void setPlayerNumber(int playerNumber) {
    this.playerNumber = playerNumber;
  }

  void setLifes(int lifes) {
    this.lifes = lifes;
  }

  public void setShield(int shield) {
    this.shield = shield;
  }
  
  public void setSave(int save){
    this.save = save;
  }

  // Get methods
  public String getName() {
    return name;
  }

  public int getLifes() {
    return lifes;
  }

  public int getShield() {
    return shield;
  }

  public int getScore() {
    return score;
  }

  public int getSave() {
    return save;
  }

  public int getPlayerNumber() {
    return playerNumber;
  }

  public int geHighestScore() {
    return highestScore;
  }

  @Override
    public int getSize() {
    return 54; // Spaceship size
  }

  @Override
    public int getDamage() {
    return 5;
  }

  // Intersting methods
  void drawPlayer(float movX, float movY) {
    if (getHealth() > 0) {  // alive
      if (getHealth() > 100) setHealth(100);
      if (getShield() > 100) setShield(100);
      move(movX, movY);
      avatarFrame++;
      if (avatarFrame >= 2) avatarFrame = 0;
      if (laser && shotDelay > 10) {
        shootLaser();
      } else if (missile && shotDelay > 10) {
        shootMissile();
      } else {
        if (shotDelay <= 10) shotDelay++;
      }
      for (int i = 0; i < MAX_AMMO; i++) {
        if (lasers[i].getHealth() > 0) {
          lasers[i].draw(this); // draw lasers
        }
      }
      for (int i = 0; i < MAX_MISSILE; i++) if (missiles[i].getHealth() > 0) missiles[i].draw(); // draw missiles
      if (this.getImmuneTime() > 0) {
        if (frameCount%3==0) tint(RED, 150);
        else tint(WHITE, 150);
        image(avatar[avatarFrame], x, y);
      }
      image(avatar[avatarFrame], x, y);
      noTint();
      fill(LIGHT_BLUE, 50);
      if (shield > 0) {
        ellipse(x, y, 64, 64);
      }
      if (this.getImmuneTime() >= 1) this.setImmuneTime(getImmuneTime()-1);
    } else { // dead
      image(explotionGIF[avatarFrame], x, y);
      avatarFrame++;
      if (lifes > 0 && avatarFrame == 8) {
        revive();
        lifes--;
      } else {
        if (lifes <= 0) gameOver = true;
      }
    }
  }
  
  void drawOtherPlayer(){
    this.x += outerX;
    this.y += outerY;
    if(outerLaser) shootLaser();
    if(outerMissile) shootMissile();
    pause = outerPause;
  }

  // Shoot laser
  void shootLaser() {
    shotDelay = 0;
    for (int i = 0; i < MAX_AMMO; i++) {
      if (lasers[i].getHealth() <= 0) {
        lasers[i].restart(x, y);
        laserSound.play();
        break;
      }
    }
  }

  void shootMissile() {
    shotDelay = 0;
    for (int i = 0; i < MAX_MISSILE; i++) {
      if (missiles[i].getHealth() <= 0) {
        missiles[i].restart(x, y);
        break;
      }
    }
  }

  // Respawn our player with 100 HP
  void revive() {
    avatarFrame = 0;
    setHealth(100);
  }

  // Move spaceShip
  void move(float x, float y) {
    if (x > 0 && this.x < width) this.x += x;
    if (x < 0 && this.x > 0) this.x += x;
    if (y > 0 && this.y < height) this.y += y;
    if (y < 0 && this.y > 0) this.y += y;
    for (int i = 0; i < MAX_METEORITES; i++) { // Check player-meteorites collitions
      if (this.getImmuneTime() <= 0) {
        if (shield > 0) {
          int damage = checkCollision(this, meteorites[i]);
          this.setHealth(this.getHealth()+damage);
          shield -= damage;
          if (shield < 0)shield = 0;
        } else checkCollision(this, meteorites[i]);
      }
    }
    for (int i = 0; i < MAX_ENEMIES; i++) { // Check player-enemies collition
      if (this.getImmuneTime() <= 0) {
        if (shield > 0) {
          int damage = checkCollision(this, enemies[i]);
          this.setHealth(this.getHealth()+damage*2);
          shield -= damage;
          if (shield < 0)shield = 0;
        } else checkCollision(this, enemies[i]);
      }
    }
    if (this.getImmuneTime() <= 0) { // Check player-bigBoss collision
      if (shield > 0) {
        int damage = checkCollision(this, bigBoss);
        this.setHealth(this.getHealth()+damage*2);
        shield -= damage;
        if (shield < 0)shield = 0;
      } else checkCollision(this, bigBoss);
    }
    if (getHealth() <= 0) {
      explotionSound.play();
    }
  }
}

////////////////////////// Player interface ///////////////////////////////////////
void playerInerface() {
  textFont(fontInterface);
  textAlign(0);
  fill(GREEN, 200);
  textSize(14);
  text("Player"+localPlayer.getPlayerNumber()+": "+localPlayer.getName()+
    "    Lifes:"+localPlayer.getLifes()+
    "    Health:"+localPlayer.getHealth()+
    "    Shield:"+localPlayer.getShield()+
    "    Score:"+localPlayer.getScore(), 0, 12);
  if (isCooperativeMode && otherPlayer != null) {
    fill(RED, 200);
    text("Player"+otherPlayer.getPlayerNumber()+": "+otherPlayer.getName()+
      "    Lifes:"+otherPlayer.getLifes()+
      "    Health:"+otherPlayer.getHealth()+
      "    Shield:"+otherPlayer.getShield()+
      "    Score:"+otherPlayer.getScore(), 0, 12);
  }
  textAlign(RIGHT);
  if (levelCounter >= 0) text("Time remaining to arrvie:"+levelCounter, width, 12);
}

//////////////////////////////// Laser shots //////////////////////////////////////////
public class Laser extends GameObject {

  // Builder
  public Laser() {
    super(0);
  }

  // Revive lasers
  public void restart(float x, float y) {
    this.x = x;
    this.y = y;
    setHealth(1);
  }

  //Draw the laser
  public void draw(Player player) {
    if (this.getHealth() > 0) {
      fill(RED);
      rect(x, y, 6, 40);
      //ellipse(x,y,15,15);
      y -= 16;
      if (y < -5) {
        setHealth(0);
      }
      for (int i = 0; i < MAX_METEORITES; i++) {
        checkCollision(this, meteorites[i], player);
      }
      for (int i = 0; i < MAX_ENEMIES; i++) {
        checkCollision(this, enemies[i], player);
      }
      if (bigBoss != null) {
        checkCollision(this, bigBoss, player);
      }
    }
  }

  // Gets methods
  public int getSize() {
    return 16;
  }

  public int getDamage() {
    return 5;
  }
}

//////////////////////////////// Missile shoots //////////////////////////////////////////
public class Missile extends GameObject {

  Player player;

  //Builder
  public Missile(Player player) {
    super(0);
    this.player = player;
  }

  // Revive missiles
  public void restart(float x, float y) {
    this.x = x;
    this.y = y;
    setHealth(1);
  }

  public void draw() {
    if (this.getHealth() > 0 || y < -24) {
      fill(RED);
      image(mineImage, x, y, 36, 36);
      x += 24*sin(y);
      y -= 6;
      if (y < -5) {
        setHealth(0);
      }
      // Check for missile collisions
      for (int i = 0; i < MAX_METEORITES; i++) checkCollision(this, meteorites[i], player);
      for (int i = 0; i < MAX_ENEMIES; i++) checkCollision(this, enemies[i], player);
      if (bigBoss != null) checkCollision(this, bigBoss, player);
    }
  }

  // Gets methods
  public int getSize() {
    return 24;
  }

  public int getDamage() {
    return 25;
  }
}
