// Main

/*
  Project: Space Odissey
 
 Requires to run it:
 > Sound library.
 > oscP5 library.
 > P5ireBase library
 
 */
import javax.swing.JOptionPane;
import P5ireBase.library.*;
import processing.sound.*;
import processing.serial.*;
import oscP5.*;
import netP5.*;

// Arduino
Serial puerto;
SerialConnection serialConnection;

// Fonts
PFont fontMenu, fontButton, fontInfo, fontDefault, fontSpecial, fontInterface;

// Windows' Constants
public static final int LOGIN_MENU = 0;
public static final int MAIN_MENU = 1;
public static final int SETTINGS_MENU = 2;
public static final int SELECT_ROL_MENU = 3;
public static final int LEVEL_MENU = 4;
public static final int STAGE = 5;
public static final int WAITING_ROOM = 6;
public static final int JOIN_ROOM = 7;
public static final int JOIN_PHONE = 8;
public static final int GAME_OVER_SCREEN = 9;
public static final int NEXT_LEVEL = 10;
public static final int END = 11;

// A few constants
final color GREEN = color(0, 255, 0);
final color RED = color(255, 0, 0);
final color BLUE = color(0, 0, 255);
final color LIGHT_BLUE = color(81, 209, 246);
final color YELLOW = color(255, 255, 0);
final color WHITE = color(255);
final color BLACK = color(0);
final color SILVER = color(192,192,192);

//Firebase
P5ireBase fireBase;
int playerNumber;

int window;
boolean gameOver;

// Level variable
int stageLevel;
boolean pause;
int levelCounter;

// Debug Information
boolean debugInfo;
boolean cheats;

// Main Menu Buttons
Button playButton, exitButton, settingsButton;
// Select Rol Menu Buttons
Button serverButton, joinButton, singleButton;

// Back Button
Button backButton;

// Change Profile Button
Button changeButton;

// Sound Button
Button soundButton;

// Levels' Buttons
Button levelButton[];

// Background stars
StarsBackground starsBackground;
Background stageBackground;

// Local Player
static Player localPlayer;
static String playerName;
static float localX;
static float localY;
static boolean laser;
static boolean missile;
// Another player
static Player otherPlayer;
static boolean outerMissile;
static boolean outerPause;
static boolean outerLaser;
static float outerX;
static float outerY;

// Meteorites
Meteorite meteorites[];

//Enemyies
Enemy enemies[];
Enemy bigBoss;


// Are we in cooperative mode game?
boolean isCooperativeMode;

//Images menu
PImage menuImg;

//Images game
PImage meteoriteGIF[];
PImage meduGIF[];
PImage bigBrainGIF[];

PImage explotionGIF[];
PImage mineImage; // Missile image

PImage moonImage;
PImage bigSkullGIF[];
PImage smallSkullGIF[];
PImage ufoGIF[];

PImage hearthImage;
PImage shieldImage;

ufoWait ufoWaiting;

Health health;
Shield shield;

// Sounds
SoundFile clickSound;
SoundFile hitSound1;
SoundFile explotionSound;
SoundFile laserSound;
SoundFile menuSound;
SoundFile stageSound;
SoundFile laughSound;

boolean soundEnable;

// Conection PC and Android
OscP5 oscP5;
String myIPAddress; // Your address
String remoteAddress; // Your mate's address
String phoneAddress; // phone address (control)
NetAddress remoteLocation;

boolean isPhoneConected;
boolean isCoopConected;

public static int currentLevel;

void setup() {
  // Window
  surface.setTitle("Space Odissey - Powered by Godzilla");
  size(800, 600);
  window = LOGIN_MENU;
  smooth(4);
  starsBackground = new StarsBackground();
  pause = false;
  playerNumber = 1;
  
  randomSeed(767);
  
  serialConnection = new SerialConnection(this,9600);

  fireBase = new P5ireBase(this, "https://vue-todo-2021-febec-default-rtdb.firebaseio.com/"); // Firebase
  fireBase.getValue("Game/Profiles");

  levelCounter = 0;
  gameOver = false;

  // Conection
  oscP5 = new OscP5(this, 12000, OscP5.UDP);
  myIPAddress = NetInfo.lan();
  remoteAddress = "";
  phoneAddress = "";

  isPhoneConected = false;
  isCoopConected = false;

  // Others
  debugInfo = false;
  cheats = false;
  isCooperativeMode = false;
  laser = false;

  // Sounds
  clickSound = new SoundFile(this, "Resources/Sounds/click.wav", false);
  hitSound1 = new SoundFile(this, "Resources/Sounds/hit.wav", false);
  explotionSound = new SoundFile(this, "Resources/Sounds/explotion.wav", false);
  laserSound = new SoundFile(this, "Resources/Sounds/shoot.wav", false);
  menuSound = new SoundFile(this, "Resources/Sounds/menu.wav", false);
  laughSound = new SoundFile(this, "Resources/Sounds/laugh.wav");
  stageSound = new SoundFile(this, "Resources/Sounds/wow.wav", false);
  soundEnable = true;

  menuSound.amp(0.2);
  stageSound.amp(0.3);
  menuSound.loop();

  //Text fonts
  fontMenu = createFont("Resources/Fonts/Roose Sally.otf", 90);
  fontButton = createFont("Resources/Fonts/Fipps-Regular.otf", 32);
  fontInfo = createFont("Resources/Fonts/PixelatedPusab.ttf", 12);
  fontDefault = createFont("Resources/Fonts/1942.ttf", 48);
  fontSpecial = createFont("Resources/Fonts/BadlyStamped.ttf", 48);
  fontInterface = createFont("Resources/Fonts/bauserif.ttf", 48);

  //Buttons' Menu
  playButton = new Button("Play", 120, height-70, 200, 100, GREEN);
  exitButton = new Button("Exit", width-120, height-70, 200, 100, GREEN);
  settingsButton = new Button("Settings", width/2, height-70, 280, 100, GREEN);

  singleButton = new Button("Single player", width/2, height/2-30, 410, 100, LIGHT_BLUE);
  serverButton = new Button("Host", width/2+105, height/2+90, 200, 100, LIGHT_BLUE);
  joinButton = new Button("Join", width/2-105, height/2+90, 200, 100, LIGHT_BLUE);

  backButton = new Button("Back to menu", width-200, height-60, 380, 100);
  changeButton = new Button("Change user", 200, height-60, 380, 100);
  soundButton = new Button("Disable audio", 200, height/5+148, 340, 90, WHITE);

  // Levels' Buttons
  levelButton = new Button[10];
  float x=175, y=250;
  for (int i = 0; i < 10; i++) {
    levelButton[i] = new Button(""+(i+1), x, y, 100, 100, YELLOW);
    x += 110;
    if (i==4) {
      x = 175; // Row
      y += 110; // Colum
    }
  }

  //Player
  playerName = "";

  // Frame rate
  frameRate(30);

  //Image menu
  float rando = random(0, 1);
  if (rando >= 0.5) menuImg = loadImage("Resources/Images/rusiaMenu.png");
  else menuImg = loadImage("Resources/Images/ovniMenu.png");
  menuImg.resize(320, 240);

  // Meteorite Images
  meteoriteGIF = new PImage[20];
  for (int i = 0; i < 20; i++) meteoriteGIF[i] = loadImage("Resources/Images/meteorite/frame-"+(i+1)+".gif");

  explotionGIF = new PImage[8];
  bigSkullGIF = new PImage[8];
  for (int i = 0; i < 8; i++) {
    explotionGIF[i] = loadImage("Resources/Images/effects/explotion/frame-0"+(i+1)+".gif");
    bigSkullGIF[i] = loadImage("Resources/Images/Enemies/bigSkull/frame-"+(i+1)+".gif");
  }

  ufoWaiting = new ufoWait(100, height-150);

  smallSkullGIF = new PImage[11];
  for (int i = 0; i < 11; i++) smallSkullGIF[i] = loadImage("Resources/Images/Enemies/smallSkull/frame-"+(i+1)+".gif");

  meduGIF = new PImage[7];
  for (int i = 0; i < 7; i++) meduGIF[i] = loadImage("Resources/Images/Enemies/medu/frame-"+(i+1)+".gif");

  ufoGIF = new PImage[19];
  for (int i = 0; i < 19; i++) ufoGIF[i] = loadImage("Resources/Images/Enemies/ufo/frame-"+(i+1)+".gif");

  bigBrainGIF = new PImage[2];
  bigBrainGIF[0] = loadImage("Resources/Images/Enemies/bigBrain/frame-1.gif");
  bigBrainGIF[1] = loadImage("Resources/Images/Enemies/bigBrain/frame-2.gif");

  //moonImage = new PImage();
  moonImage = loadImage("Resources/Images/Enemies/bigMoon/moon.png");
  mineImage = loadImage("Resources/Images/spaceShips/mine.png");

  hearthImage = loadImage("Resources/Images/items/hearth.png");
  shieldImage = loadImage("Resources/Images/items/shield.png");

  // Support items
  health = new Health();
  shield = new Shield();

  // Enemies
  meteorites = new Meteorite[MAX_METEORITES];
  for (int i = 0; i < MAX_METEORITES; i++) meteorites[i] = new Meteorite((int)random(32, 256), random(1, 10));

  enemies = new Enemy[MAX_ENEMIES];
}

//Draw
void draw() {
  serialConnection.startSerialCommunication();
  if(serialConnection.isReady){ // Cheack for ardunio conection
    String portName = Serial.list()[0];
    puerto = new Serial(this, portName, 9600);
  }
  
  switch(window) {
  case MAIN_MENU:
    drawMainMenu();
    break;
  case LOGIN_MENU:
    drawLoginMenu();
    break;
  case SELECT_ROL_MENU:
    drawSelectRolMenu();
    break;
  case SETTINGS_MENU:
    drawSettingsMenu();
    break;
  case LEVEL_MENU:
    drawLevelMenu();
    break;
  case STAGE:
    drawStage();
    break;
  case WAITING_ROOM:
    drawWaitingRoom();
    break;
  case JOIN_ROOM:
    drawJoinRoom();
    break;
  case JOIN_PHONE:
    drawJoinPhone();
    break;
  case GAME_OVER_SCREEN:
    drawGameOverScreen();
    break;
  case NEXT_LEVEL:
    nextLevel();
    break;
  case END:
    drawEnd();
    break;
  default:
    text("Error: window not found!", width/2, height/2);
    break;
  }
}

// OscP5 conection for Androind and Cooperative mode
void oscEvent(OscMessage theOscMessage) {
  //println(esivido");
  if (theOscMessage.checkAddrPattern("sensores")) // Confirm phone conection
  {
    //println("Resivido");
    if (theOscMessage.get(0).stringValue().equals("true")) isPhoneConected = true;
    if (theOscMessage.get(1).stringValue().equals("true")) { // missile button (Android)
      missile = true;
    } else {
      missile = false;
    }
    if (theOscMessage.get(2).stringValue().equals("true")) { // ready button (Android)
      pause = true;
    } else {
      pause = false;
    }
    if (theOscMessage.get(3).stringValue().equals("true")) { // laser button (Android)
      laser = true;
    } else {
      laser = false;
    }
    localX = theOscMessage.get(5).floatValue()*2; // Y sensor (Android)
    localY = theOscMessage.get(4).floatValue()*2; // X sensor (Android)
  } else if (theOscMessage.checkAddrPattern("otherPlayer")) // PC host resive PC invited data ////////////////////////
  {
    //println("Resivido");
    remoteAddress = theOscMessage.get(0).stringValue();

    if (theOscMessage.get(1).stringValue().equals("true")) { // missile button (Android)
      outerMissile = true;
    } else {
      outerMissile = false;
    }
    if (theOscMessage.get(2).stringValue().equals("true")) { // ready button (Android)
      outerPause = true;
    } else {
      outerPause = false;
    }
    if (theOscMessage.get(3).stringValue().equals("true")) { // laser button (Android)
      outerLaser = true;
    } else {
      outerLaser = false;
    }

    outerX = theOscMessage.get(4).floatValue()*2; // Y sensor (Android)
    outerY = theOscMessage.get(5).floatValue()*2; // X sensor (Android)

    initStage();
  } else if (theOscMessage.checkAddrPattern("gameState")) { // fetch the stage data from the 1st player (the host) /////////////////
    
    initStage();

    if (theOscMessage.get(1).stringValue().equals("true")) { // missile button (Android)
      outerMissile = true;
    } else {
      outerMissile = false;
    }
    if (theOscMessage.get(2).stringValue().equals("true")) { // ready button (Android)
      outerPause = true;
    } else {
      outerPause = false;
    }
    if (theOscMessage.get(3).stringValue().equals("true")) { // laser button (Android)
      outerLaser = true;
    } else {
      outerLaser = false;
    }

    outerX = theOscMessage.get(4).floatValue()*2; // Y sensor (Android)
    outerY = theOscMessage.get(5).floatValue()*2; // X sensor (Android)
  }
}

// Function for join a game
void joinGame() {
  OscMessage myMessage = new OscMessage("otherPlayer"); // Confirm the conection

  myMessage.add(myIPAddress); // Address

  if (missile) myMessage.add("true"); // Misslie button
  else myMessage.add("false");
  if (pause) myMessage.add("true"); // Ready button
  else myMessage.add("false");
  if (laser) myMessage.add("true"); // Laser button
  else myMessage.add("false");

  myMessage.add(localX);
  myMessage.add(localY);

  /*
    Sent values:
   > 0 : myIPAddress
   > 1 : redy
   > 2 : laser
   > 3 : Y sensor
   > 4 : X sensor
   */

  //println("Sending data to PC: "+remoteAddress);
}
