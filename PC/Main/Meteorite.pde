// Meteorite Class

public class Meteorite extends GameObject {

  // There's a only meteorite sprite so, we can change the size and speed to show variety

  //private float x,y; // Meteorite position
  private int frame;
  private float speed;
  private float rotationSpeed;
  private int size;
  private boolean alive;

  //Meteorite Builder
  public Meteorite() {
    super(10); // Father builder
    rotationSpeed = random(1, 8);
    alive = false;
    frame = 0;
    size = 200;
    speed = 2.5;
    x = random((size/2), (width-(size/2)));
    y = -(size/2);
  }

  public Meteorite(int size, float speed) {
    super(10); // Father builder
    rotationSpeed = random(1, 8);
    alive = false;
    frame = 0;
    this.size = size;
    this.speed = speed;
    x = random((size/2), (width-(size/2)));
    y = -(size/2);
  }

  public void drawEnemy() {
    image(meteoriteGIF[frame], x, y, size, size);
    textFont(fontDefault);
    if (debugInfo) text(String.valueOf(this.getHealth()), x, y-12);
    y += speed;
    if (frameCount%round(rotationSpeed) == 0) frame++;
    if (frame >= 20) frame = 0;
    if (y > height+(size/2)) {
      alive = false;
      y = -(size/2);
    }
    if (getHealth() <= 0) {
      alive = false;
      float ran = random(0, 1);
      if (ran < 0.16) {
        if (ran < 0.08) health.respawn(x, y);
        else shield.respawn(x, y);
      }
      y = -(size/2);
    }
  }

  void revive() {
    setHealth(5);
    size = (int) random(32, 256);
    rotationSpeed = random(1, 8);
    alive = true;
    speed = random(1, 10);
    x = random((size/2), (width-(size/2)));
    y = -(size/2);
  }

  // Get methods
  public boolean isAlive() {
    return alive;
  }

  @Override
    public int getSize() {
    return size;
  }

  @Override
    public int getDamage() {
    return 10;
  }

  // Sets methods
  public void setAlive(boolean alive) {
    this.alive = alive;
  }

  public void setY(float y) {
    this.y = y;
  }
}
