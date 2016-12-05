Maze maze;

// tray tilt - set to angles between ~ -3 and 3 degrees (in rad)
float xTilt = 0;  
float yTilt = 0;

// possible controllers
Controller mouseController = new MouseController();
Controller keyController = new KeyController();
Controller currentController = mouseController;


void setup() {
  size(1000, 800, P3D);
  frameRate(20);
  maze = new Maze(width-200, height);
  
  background(50);
}

void draw() {
  // Controller selection UI
  drawButtons();
  
  // Maze
  currentController.update();
  maze.display(currentController.xTilt, currentController.yTilt);
}


// Passing on key events to keyController

void keyPressed() {
  if (currentController == keyController) keyController.keyAction();
}

void keyReleased() {
  if (currentController == keyController) keyController.keyReset();
}


// == Controller Selection UI =======================================

void drawButtons() {
  pushMatrix();
  translate(-20, 20, 40);
  drawButton("Use Mouse", width-180, 20, currentController != mouseController);
  drawButton("Use Keys", width-180, 100, currentController != keyController);
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
  if (mouseX >= width-180 && mouseY < 90) {
    currentController = mouseController;
  } else if (mouseX >= width-180 && mouseY > 90  && mouseY < 190) {
    currentController = keyController;
  }
}

// ===================================================================