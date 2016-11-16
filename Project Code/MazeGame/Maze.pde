class Maze {
  
  // measurements
  private final int boxWidth;
  private final int boxHeight;
  private final int outerFrameWidth;
  private final int innerFrameWidth;
  private final int trayWidth;
  private final int trayHeight;
  private final int ballSize;
  
  // colours
  private final IntDict boxColors = new IntDict();
  private final IntDict trayColors = new IntDict();
  private final IntDict ballColors = new IntDict();
  
  // ball 
  private Point ballPos = new Point(0, 0);
  private float speedFactor = 360;  // the higher the factor the faster the ball
 
  Maze(int _boxWidth, int _boxHeight) {
    
    // -- set colours: --
    // outer box frame
    boxColors.set("mainColor",170);
    boxColors.set("shadow",50);
    boxColors.set("highlight",170);
    // tray
    trayColors.set("mainColor",170);
    trayColors.set("shadow",50);
    trayColors.set("highlight",240);
    // tray
    ballColors.set("mainColor",#F00F0F);
    ballColors.set("shadow",#B43A3A);
    ballColors.set("highlight",#FFB9B9);
    
    // set some measurements 
    boxWidth = _boxWidth;
    boxHeight = _boxHeight;
    innerFrameWidth = boxWidth / 60;
    outerFrameWidth = boxWidth / 30;
    trayWidth = boxWidth - 2 * outerFrameWidth;
    trayHeight = boxHeight - 2 * outerFrameWidth;
    ballSize = outerFrameWidth;
  }
  
  public void display(float xTilt, float yTilt) {
    
    // draw box inside
    pushMatrix();
    for (int i = 15; i >= 0; i--) {
       translate(0, 0, -5);
       
       noFill();
       stroke(5 * i);
       strokeWeight(1);
       rectMode(CENTER);
       rect(boxWidth/2, boxHeight/2, boxWidth - outerFrameWidth, boxHeight - outerFrameWidth);
    }
    popMatrix();
    
    // draw static board frame
    drawFrame(boxWidth/2, boxHeight/2, boxWidth, boxHeight, outerFrameWidth, boxColors);
    
    // draw moving tray
    drawTray(xTilt, yTilt);
  }
  
  private void drawFrame(float posX, float posY, float outerWidth, float outerHeight, int frameWidth, IntDict colors) {
    
    // TODO: update to use Point for posX & Y
    
    // actual rect width/height is slightly less because of fat strokes
    int x = int(posX);
    int y = int(posY);
    int rectWidth = int(outerWidth) - frameWidth;
    int rectHeight = int(outerHeight) - frameWidth;
    
    // draw 3 rects with increasingly thinner & lighter lines to simulate 3-D effect 
    /*  (drawing them on separate z layers seems to reduce the number of weird 
         rendering artifacts) */
    pushMatrix();
    translate(0, 0, 1);
    rectMode(CENTER);
    noFill();
    float corner = frameWidth * .5;
    stroke(colors.get("shadow"));
    strokeWeight(frameWidth);
    rect(x, y, rectWidth, rectHeight, corner);
    translate(0, 0, 1);
    stroke(colors.get("mainColor"));
    strokeWeight(frameWidth * .8);
    rect(x, y, rectWidth, rectHeight, corner);
    translate(0, 0, 1);
    stroke(colors.get("highlight"));
    strokeWeight(frameWidth * .2);
    rect(x, y, rectWidth, rectHeight, corner);
    popMatrix();
  }
  
  private void drawTray(float xTilt, float yTilt) {
    // move the tray and everything on it according to the tilt
    translate(boxWidth/2, boxHeight/2);
    rotateX(xTilt);
    rotateY(yTilt);
    
    // draw the tray
    fill(trayColors.get("mainColor"));
    noStroke();
    rectMode(CENTER);
    rect(0, 0, trayWidth - innerFrameWidth/2, trayHeight - innerFrameWidth/2);
    
    // update ball position and draw the ball
    ballPos.x += yTilt * speedFactor;
    ballPos.y -= xTilt * speedFactor;
    ballPos.x = constrain(ballPos.x, -trayWidth/2 + ballSize, trayWidth/2 - ballSize);
    ballPos.y = constrain(ballPos.y, -trayHeight/2 + ballSize, trayHeight/2 - ballSize);
    // TODO: implement bounce
    drawBall(ballPos);
    
    // draw the frame
    drawFrame(0, 0, trayWidth, trayHeight, innerFrameWidth, trayColors);
  }  
  
  private void drawBall(Point pos) {
    pushMatrix();
    translate(0, 0, 5);
    fill(ballColors.get("mainColor"));
    stroke(ballColors.get("shadow"));
    strokeWeight(ballSize * .1);
    ellipse(pos.x, pos.y, ballSize, ballSize);  
    fill(ballColors.get("highlight"));
    noStroke();
    ellipse(pos.x - ballSize * .1, pos.y - ballSize * .1, ballSize * .2, ballSize * .2);  
    popMatrix();
  }
  
}