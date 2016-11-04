Maze maze;

// tray tilt - set to angles between ~ -3 and 3 degrees (in rad)
float xTilt = 0;  
float yTilt = 0;

// -- ONLY USED WITH keyControler ---
float xTiltChange = 0;   
float yTiltChange = 0;   
float TiltChangeRate = 0.001;
// -------------------------------

boolean useKeyControler = false;
boolean useMouseControler = true;

void setup() {
  size(1000, 800, P3D);
  frameRate(20);
  maze = new Maze(width-200, height);
  
  background(50);

}

void draw() {
  drawButtons();
  
  // call controller
  if (useMouseControler) {
    mouseControler();
  } else if (useKeyControler) {
    keyControler();
  }
   
  maze.display(xTilt, yTilt);
}

void drawButtons() {
  drawButton("Use Mouse", width-180, 20, !useMouseControler);
  drawButton("Use Keys", width-180, 100, !useKeyControler);
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

void mouseControler() {
  // translate mouse movement to tray tilt angles between ~ -3 and 3 degrees (in rad)
  xTilt = map(mouseY, height, 0, -0.05, 0.05);  
  yTilt = map(mouseX, 0, width, -0.05, 0.05);
} 

void keyControler() {
  // translate cursor key strokes into tray tilt increase/decrease  (max ~ -3 and 3 degrees (in rad))
  xTilt += xTiltChange;  
  yTilt += yTiltChange;
  constrain(xTilt, -0.05, 0.05);
  constrain(yTilt, -0.05, 0.05);
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
      case UP: 
        xTiltChange = TiltChangeRate;
        break;
      case DOWN:
         xTiltChange = -TiltChangeRate;
        break;
      case LEFT: 
        yTiltChange = -TiltChangeRate;
        break;
      case RIGHT:
         yTiltChange = TiltChangeRate;
        break;
      default:
        break;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    switch(keyCode) {
      case UP: 
        xTiltChange = 0;
        break;
      case DOWN:
        xTiltChange = 0;
        break;
      case LEFT: 
        yTiltChange = 0;
        break;
      case RIGHT:
        yTiltChange = 0;
        break;
    }
  }
}

void mouseClicked() {
  if (mouseX >= width-180 && mouseY < 90) {
    useMouseControler = true;
    useKeyControler = false;
  } else if (mouseX >= width-180 && mouseY > 90  && mouseY < 190) {
    useMouseControler = false;
    useKeyControler = true;
  }
}