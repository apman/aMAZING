import org.openkinect.freenect.*;
import org.openkinect.processing.*;



Maze maze;

// tray tilt - set to angles between ~ -3 and 3 degrees (in rad)
float xTilt = 0;  
float yTilt = 0;

// possible controllers
final Controller mouseController = new MouseController();
final Controller keyController = new KeyController();
Controller kinectController;
final String MOUSE = "Mouse";
final String KEY = "Key";
final String KINECT = "Kinect";
Controller currentController = mouseController;

boolean showMenu = false;
int menuTurnedOnAt = 0;
boolean showInfo = false;
int infoTurnedOnAt = 0;
int displayTimeout = 10000;


// maze Layouts
final GameLayout defaultMaze = new DefaultMaze();
final GameLayout soccerLayout = new SoccerLayout();
GameLayout currentLayout = defaultMaze;                



void setup() {
  size(1000, 800, P3D);
  frameRate(30);
  setMaze();
  
  background(50);
  turnOnMenu();
}

void draw() {
  // Controller selection UI
  if (showMenu) {
    drawMenu();
    // timeout for the menu
    if (millis() - menuTurnedOnAt > displayTimeout) showMenu = false;
  }
  
  // Info panel
  if (showInfo) {
    drawInfoBar();
    // timeout for the menu
    if (millis() - infoTurnedOnAt > displayTimeout) showInfo = false;
  }
  
  // Maze
  currentController.update();
  maze.display(currentController.xTilt, currentController.yTilt);
}


void setMaze() {
  maze = new Maze(width, height, currentLayout);
}

void setCurrentControler(String controlerType) {
  switch (controlerType) {
    case MOUSE:
      currentController = mouseController;
      break;
    case KEY:
      currentController = keyController;
      break;
    case KINECT:
      if (kinectController == null) {
         Kinect kinect = new Kinect(this);  // the Kinect object has to be created here, because it needs the 
                                            // main sketch as arg (i.e. new Kinect(this) placed in the constructor
                                            // of a class give an error), but I don't know how to pass the sketch
                                            // to the constructor. I tried KinectController(PApplet main) or (Object
                                            // main) ... not sure what the type is or how to find out. So I'm 
                                            // creating the Kinect here and then passing it into the controller 
         kinectController = new KinectController(kinect);
      }
      currentController = kinectController;
      break;
  }
}

// Passing on key events to keyController

void keyPressed() {
  
  hideMenu();    // (should really just happen if UP/DOWN are clicked, but since there is no reason to click
                          // any other keys, might as well turn the menu off on any key ...

  if (currentController == keyController) keyController.keyAction();
  else if (currentController == kinectController) kinectController.keyAction();  
  else {
    // adjust ball speed
    switch (key) {
      case 'v': 
        maze.adjustAcceleration("down");
        turnOnInfo();
        break;
      case 'b':
        maze.adjustAcceleration("up");
        turnOnInfo();
        break;
      case 'n':
        maze.adjustBounce("down");
        turnOnInfo();
        break;
      case 'm':
        maze.adjustBounce("up");
        turnOnInfo();
        break;
      case ',':
        maze.adjustUpHillGravity("down");
        turnOnInfo();
        break;
      case '.':
        maze.adjustUpHillGravity("up");
        turnOnInfo();
        break;
    }
  }
}

void keyReleased() {
  if (currentController == keyController) keyController.keyReset();
}


// == Controller Selection UI =======================================

void turnOnMenu() {
  showMenu = true;
  menuTurnedOnAt = millis(); 
}

void turnOnInfo() {
  showInfo = true;
  infoTurnedOnAt = millis(); 
}

void hideMenu() {
  showMenu = false;
}

void drawMenu() {
  pushMatrix();
  translate(-60, 60, 50);
  
  drawButton("Use Mouse", width-180, 20, currentController != mouseController);
  drawButton("Use Keys", width-180, 100, currentController != keyController);
  drawButton("Use Kinect", width-180, 180, currentController != kinectController);
  String gameChoice = (currentLayout == defaultMaze) ? "Foozball" : "Maze";
  drawButton(gameChoice, width-180, 260, maze.showMaze == true);
  drawButton("New Game", width-180, 340, true);
  
  // Kinect specific stuff
  String cameraInstructions = "";
  if (currentController == kinectController) {
    drawButton("Calibrate", width-180, 420, !kinectController.getCalibrationInProgress()); 
    // Draw camera tilt instructions
    cameraInstructions = "Press UP / DOWN\nto adjust the\ncamera angle,\n'i' for info,\n'd' for debug lines,\n any key to exit camera screen\n";
  }
  
  // show instructions
  String generalInstructions = "Click anywhere to show the menu.\n\nAdjustment keys:\nacceleration: v/b\nbounce: n/m\n'uphillGravity': ,/.";
  String instructions = (currentController == kinectController) ? cameraInstructions : generalInstructions;
  
  rectMode(CORNER);
  fill(120);
  stroke(90);
  rect(width-180, 500, 160, 180);
  fill(255);
  textSize(14);
  text(instructions, width-170, 520, 140, 160);
  popMatrix();
}

void drawInfoBar() {
  pushMatrix();
  translate(-60, 60, 50);
  // info
  String info = "Acceleration factor: " + maze.getAccelerationFactor() +       
                "      Bounce factor: " + maze.getBounceFactor() + 
                "      Uphill-Gravity factor: " + maze.getUpHillGravityFactor();
  
  rectMode(CENTER);
  fill(120);
  stroke(90);
  rect(width/2, height-150, width-380, 30);
  fill(255);
  textSize(14);
  text(info, width/2, height-150, width-400, 20);
  popMatrix();
}


void drawButton(String label, int x, int y, boolean active) {
  color fillColor = (active) ? 210 : 80;
  color textColor = (active) ? 00 : 110;
  fill(fillColor);
  stroke(0);
  strokeWeight(2);
  rectMode(CORNER);
  rect(x, y, 160, 60);
  fill(textColor);
  textSize(24);
  textAlign(CENTER);
  text(label, x + 80, y + 40);
}

void mouseClicked() {
  if (showMenu) {
    if (mouseX >= width-240 && mouseY < 130) {
      setCurrentControler(MOUSE);
    } else if (mouseX >= width-240 && mouseY > 130  && mouseY < 210) {
      setCurrentControler(KEY);
    } else if (mouseX >= width-240 && mouseY > 220  && mouseY < 300) {
      setCurrentControler(KINECT);
    } else if (mouseX >= width-240 && mouseY > 310  && mouseY < 390) {
      //maze.showMaze = !maze.showMaze;
      currentLayout = (currentLayout == defaultMaze) ? soccerLayout : defaultMaze;
      setMaze();
    } else if (mouseX >= width-240 && mouseY > 400  && mouseY < 480) {
      maze.resetGoals();
    } else if (mouseX >= width-240 && mouseY > 490  && mouseY < 570 && currentController == kinectController) {
      kinectController.calibrate();
      hideMenu();
    } else {
      hideMenu();
    }
  } else {
    if (currentController == kinectController && kinectController.getCameraAdjustmentInProgress()) {
      kinectController.setCameraAdjustmentInProgress(false);
    } else {
      turnOnMenu();
      turnOnInfo();
    }
  }
}
 
// ===================================================================