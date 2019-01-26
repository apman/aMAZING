class Maze {
  
  // measurements
  private final int boxWidth;
  private final int boxHeight;
  private final int outerFrameWidth;
  private final int innerFrameWidth;
  private final int trayWidth;
  private final int trayHeight;
  private final int ballSize;
  private final float pathWidthH;   // width between vertical walls 
  private final float pathWidthV;   // width between horizontal walls
  
  // precalculated values for faster drawing
  private final Point topLeft;   
  private final Point topLeftBoundry;   
  private final Point bottomRightBoundry;
     
  // colours
  private final IntDict boxColors = new IntDict();
  private final IntDict trayColors = new IntDict();
  private final IntDict ballColors = new IntDict();
  
  // ball 
  private Point ballPos = new Point(-430, -330);   // start in top left corner
  private float xSpeed = 0;
  private float ySpeed = 0;
  private float accelerationFactor = 4;
  private float accelerationFactorSteps = .5;
  private float bounceFactor = .5;
  private float bounceFactorSteps = .1;
  private float upHillGravityFactor = 3;
  private float upHillGravityFactorSteps = .3;

  
  // option to only show a blank tray with the ball rolling (good for calibration)
  boolean showMaze = true;
  
  
  // maze walls
  
  // NOTE: the zero & last row/column *could* be used to draw the tray edge 
  //        but to get the rounded corners the actual (bounce) walls are invisible
  //        and the visible wall is drawn separately
  // 
  // TODO: maybe make a grid that is wider than the current square tray and then 
  //       depending on how many channels fit onto the tray, use only part of the 
  //       grid ... (oops, I think I already did that (so it should work with a square now 
  //       TODO: ^ try and document properly
  
   
   Wall[][] wallsH = new Wall[0][0];    // array of rows of horizontal walls
   Wall[][] wallsV = new Wall[0][0];    // array of columns of vertical walls
   
   int[][] goalCoords = {{1,6},{4,2},{4,9},{5,5},{7,1},{10,8},{11,5}};
   Goal[] goals = new Goal[goalCoords.length]; 
   
   String layoutType; 
   
 
 
  Maze(int _boxWidth, int _boxHeight, GameLayout layout) {
    
    // -- set colours: --
    // outer box frame
    boxColors.set("mainColor",170);
    boxColors.set("shadow",50);
    boxColors.set("highlight",170);
    // tray
    trayColors.set("mainColor",170);
    trayColors.set("shade",50);
    trayColors.set("highlight",240);
    trayColors.set("shadow",100);
    // tray
    ballColors.set("mainColor",#F00F0F);
    ballColors.set("shade",#B43A3A);
    ballColors.set("highlight",#FFB9B9);
    ballColors.set("shadow",100);
    
    // set some measurements 
    boxWidth = _boxWidth;
    boxHeight = _boxHeight;
    innerFrameWidth = boxHeight / 60;
    outerFrameWidth = boxHeight / 30;
    trayWidth = boxWidth - 2 * outerFrameWidth - innerFrameWidth/2;
    trayHeight = boxHeight - 2 * outerFrameWidth - innerFrameWidth/2;
    ballSize = 2 * innerFrameWidth;
    
    // precalculated values for faster drawing
    topLeft = new Point(-trayWidth/2, -trayHeight/2);   
    topLeftBoundry = new Point(-trayWidth/2 + ballSize*.8, -trayHeight/2 + ballSize*.8);   
    bottomRightBoundry = new Point(trayWidth/2 - ballSize*.5, trayHeight/2 - ballSize*.5); 

    pathWidthH = optimalPathWidth(trayWidth);
    pathWidthV = optimalPathWidth(trayHeight); 
    
    layoutType = (layout instanceof DefaultMaze) ? "maze" : "soccer";   
    
    createGoals();
    
    createWalls(layout);
  }
  
  void createWalls(GameLayout layout) {

    // Convert the conceptual edges (as in edges of a graph) from simple coordinates to  
    //  Wall objects with pre-calculated pixel positions
      
    for (int row = 0; row < layout.wallEdgesH.length; row++) {
      int[][] wallRow = layout.wallEdgesH[row];
      Wall[] walls = new Wall[0];
      String type = "maze";
      if (row == 0) {
        type = "topFrame";
      } else if (row == layout.wallEdgesH.length - 1) {
        type = "bottomFrame";
      } 
         // ^^ outside walls are invisible so they don't interfere with the rounded edges of the frame,
         //    but they still act as barriers and have shadows, so they need to be treated a bit differently
      for (int lineNum = 0; lineNum < wallRow.length; lineNum++) {
        Wall wall = new Wall(new Point(topLeft.x + 5 + wallRow[lineNum][0] * pathWidthH, 
                                        topLeft.y + 5 + row * pathWidthV),
                              new Point(topLeft.x + 5 + wallRow[lineNum][1] * pathWidthH, 
                                        topLeft.y + 5 + row * pathWidthV), type);
        walls = (Wall[])append(walls, wall);                               
      }
      wallsH = (Wall[][])append(wallsH, walls);
    }
    
    /* NOTE: the ' + 5 ' above and below is to push the slightly shrunk maze (cp. the hack in optimalPathWidth() )
             down & right a bit, so that the rounded ends of the maze walls don't stick out beyond the frame */
    
   for (int col = 0; col < layout.wallEdgesV.length; col++) {
      int[][] wallCol = layout.wallEdgesV[col];
      Wall[] walls = new Wall[0];
      String type = "maze";
      if (col == 0) {
        type = "leftFrame";
      } else if (col == layout.wallEdgesV.length - 1) {
        type = "rightFrame";
      } 
         // ^^ outside walls are invisible so they don't interfere with the rounded edges of the frame,
         //    but they still act as barriers and have shadows, so they need to be treated a bit differently
      for (int lineNum = 0; lineNum < wallCol.length; lineNum++) {
        Wall wall = new Wall(new Point(topLeft.x + 5 + col * pathWidthH, 
                                        topLeft.y + 5 + wallCol[lineNum][0] * pathWidthV),
                              new Point(topLeft.x + 5 + col * pathWidthH, 
                                        topLeft.y + 5 + wallCol[lineNum][1] * pathWidthV), type);
        walls = (Wall[])append(walls, wall);                               
      }
      wallsV = (Wall[][])append(wallsV, walls);
    }  
  }
  
  void createGoals() {
    if (layoutType == "maze") {
      for (int i=0; i < goalCoords.length; i++) {
        goals[i] = new Goal(int(pathWidthH));
        goals[i].pos = new Point(topLeft.x + 5 + goalCoords[i][0] * pathWidthH + pathWidthH/2, 
                            topLeft.y + 5 + goalCoords[i][1] * pathWidthV + pathWidthV/2);
      }
      /* NOTE: the ' + 5 ' above is to adjust the goal marker positions to the moved maze 
                cp. the hack in createWalls() */
    }
  }
  
  public void resetGoals() {
    if (layoutType == "maze") {   
      for (int i=0; i < goals.length; i++) {
        goals[i].found = false; 
      }
    }
  }
  
  
  private float optimalPathWidth(float space) {
    // calculate best distance between walls based on ballSize and trayWidth or trayHeight (= space)
    
    // take a decent width to start with, see how many of them you can fit into 
    //  the tray width/height and then adjust the pathWidth to fit a round number of 
    //  paths exactly into the frame (i.e. no half paths)
    float pathWidth = 3 * ballSize;
    int pathNum = round(space / pathWidth);
    pathWidth = space / pathNum;
    
    return pathWidth - 1;    // The ' - 1 ' is a hack to make the maze a *little* bit smaller, so that the 
                             //  rounded ends of the maze walls don't stick out beyond frame
                             //  cp. createWalls(), where the slightly shrunk maze is then moved into the center
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
    translate(0, 0, 2); // starting one higher than the maze walls avoides wall bits sticking out into the frame 
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
    rect(0, 0, trayWidth, trayHeight);
    
    
    // draw the maze
    if(showMaze) drawMaze(xTilt, yTilt);
    
    setBallPos(xTilt, yTilt);
    checkIfGoalIsReached();
    drawBall(ballPos, xTilt, yTilt);
    
    // draw the frame
    drawFrame(0, 0, trayWidth + innerFrameWidth/2, trayHeight + innerFrameWidth/2, innerFrameWidth, trayColors);
  } 
  
  
  private void checkIfGoalIsReached() {
    if (layoutType == "maze") { 
      // check if the ball has reached one of the goals
      for (int i = 0; i < goals.length; i++) {
        goals[i].checkIfFound(ballPos); 
      }
    }
  }

  
  private void setBallPos(float xTilt, float yTilt) {
    
    
    // The uphillGravity factor kicks in whenever the tilt changes into the opposite direction to help the ball 
    //  to turn around  faster (not quite sure what the proper physics would be (seeing that acceleration is already
    //  a product of gravity, but the animation does seem a bit more natural with a little bit of extra pull to
    //  stop the ball from rolling uphill too far.
    float gravityFactor = ((xSpeed > 0 && yTilt < 0) || (xSpeed < 0 && yTilt > 0)) ? upHillGravityFactor : 1;
    xSpeed += yTilt * accelerationFactor * gravityFactor;  // negative tilt -> ball rolls left
    
    gravityFactor = ((ySpeed > 0 && xTilt < 0) || (ySpeed < 0 && xTilt > 0)) ? upHillGravityFactor : 1;
    ySpeed += xTilt * accelerationFactor * gravityFactor;  // negative tilt -> ball rolls down
    
    float xMovement = xSpeed;
    float yMovement = ySpeed;
     
    // separate speed (movement) and direction, so the movement can be applied incrementally
    //  while checking the walls (if the ball moves too much at once it skips the walls)
    int xDirection = 1;
    int yDirection = 1;    
    if (xMovement < 0) {
      xDirection = -1;
      xMovement = abs(xMovement);
    }
    if (yMovement < 0) {
      yDirection = -1;
      yMovement = abs(yMovement);
    }
    
    while (xMovement > 0) {
      // update ball position based on the tray's tilt in increments small enough not to miss a wall
      float moveBy = (xMovement > innerFrameWidth/3) ? innerFrameWidth/4 : xMovement;
      ballPos.x += moveBy * xDirection;  
      xMovement -= moveBy;
      // ensure it stays within the tray area (even when the maze is turned off)
      ballPos.x = constrain(ballPos.x, topLeftBoundry.x, bottomRightBoundry.x);
      if (showMaze) {
        // narrow down the area where the ball currently is
        float col = (ballPos.x - topLeft.x)/pathWidthH;
        // adjust ball position to avoid the maze walls to the left and the right
        if (avoidWallsV(wallsV[ceil(col)])) break;  
        if (avoidWallsV(wallsV[floor(col)])) break;   
      }
    }
    
    while (yMovement > 0) {
      // update ball position based on the tray's tilt in increments small enough not to miss a wall
      float moveBy = (yMovement > innerFrameWidth/3) ? innerFrameWidth/4 : yMovement;
      ballPos.y -= moveBy * yDirection;  
      yMovement -= moveBy;    
      // ensure it stays within the tray area (even when the maze is turned off)
      ballPos.y = constrain(ballPos.y, topLeftBoundry.y, bottomRightBoundry.y );
      if (showMaze) {
        // narrow down the area where the ball currently is
        float row = (ballPos.y - topLeft.y)/pathWidthV;
        // adjust ball position to avoid the maze walls above and below 
        if (avoidWallsH(wallsH[floor(row)])) break;   
        if (avoidWallsH(wallsH[ceil(row)])) break;   
      }
    }
  }
 

  private boolean avoidWallsV(Wall[] walls) {
    boolean touchingWall = false;
    for (int w = 0; w < walls.length; w++) {
      Wall wall = walls[w];
      if (ballPos.y > wall.start.y && ballPos.y < wall.end.y) {
        wall.highlight = true;
        // check left or right of wall, depending on tilt 
        //  and correct ballPos to keep the ball off the wall
        if (xSpeed >= 0 && ballPos.x >= wall.start.x - ballSize * .6     // ball rolling right & touching the left side of the wall
                          && ballPos.x <= wall.start.x) {
          ballPos.x = wall.start.x - ballSize *.6;
          xSpeed = -xSpeed * bounceFactor;
          touchingWall = true;
        } else if (xSpeed <= 0 && ballPos.x <= wall.start.x + ballSize * .8    // ball rolling left & touching right side of the wall
                               && ballPos.x >= wall.start.x) {
          ballPos.x = wall.start.x + ballSize * .8;
          xSpeed = -xSpeed * bounceFactor;
          touchingWall = true;
          
        }
      } 
    }
    return touchingWall;
  }
  
  private boolean avoidWallsH(Wall[] walls) {
    boolean touchingWall = false;
    for (int w = 0; w < walls.length; w++) {
      Wall wall = walls[w];
      if (ballPos.x > wall.start.x && ballPos.x < wall.end.x) {
        wall.highlight = true;
        // check top or bottom of wall, depending on tilt 
        //  and correct ballPos to keep the ball off the wall
        if (ySpeed <= 0 && ballPos.y >= wall.start.y - ballSize * .6
                          && ballPos.y <= wall.start.y) {
          ballPos.y = wall.start.y - ballSize *.6;
          ySpeed = -ySpeed * bounceFactor;
          touchingWall = true;
        } else if (ySpeed >= 0 && ballPos.y <= wall.start.y + ballSize * .8
                               && ballPos.y >= wall.start.y) {
          ballPos.y = wall.start.y + ballSize * .8;
          ySpeed = -ySpeed * bounceFactor;
          touchingWall = true;
        }
      } 
    }
    return touchingWall;
  }

 
  private void drawMaze(float xTilt, float yTilt) {
    
    // draw the horizontal walls
    for (int row = 0; row < wallsH.length; row++) {
      Wall[] wallRow = wallsH[row];
      for (int wall = 0; wall < wallRow.length; wall++) {
        wallRow[wall].display(innerFrameWidth, trayColors, xTilt, yTilt);
      }
    }
    
    // draw the vertical walls
    for (int col = 0; col < wallsV.length; col++) {
      Wall[] wallCol = wallsV[col];
      for (int wall = 0; wall < wallCol.length; wall++) {
        wallCol[wall].display(innerFrameWidth, trayColors, xTilt, yTilt);
      }
    }
    
    // draw the goals
    if (layoutType == "maze") { 
      for (int i = 0; i < goals.length; i++) {
        goals[i].display(); 
      }
    }
  }
  
  
  private void drawBall(Point pos, float xTilt, float yTilt) {
    pushMatrix();
    // draw the ball shadow slightly offset depending on tray tilt 
    translate(0, 0, 1);
    fill(ballColors.get("shadow"));
    noStroke();
    ellipseMode(CENTER);
    ellipse(pos.x + yTilt * 200, pos.y - xTilt * 200, ballSize, ballSize);  
    // draw the actual ball
    translate(0, 0, 5);
    fill(ballColors.get("mainColor"));
    stroke(ballColors.get("shade"));
    strokeWeight(ballSize * .1);
    ellipse(pos.x, pos.y, ballSize, ballSize);  
    fill(ballColors.get("highlight"));
    noStroke();
    ellipse(pos.x - ballSize * .1, pos.y - ballSize * .1, ballSize * .2, ballSize * .2);  
    popMatrix();
  }
  
  public void adjustAcceleration(String upDown) {
    accelerationFactor += (upDown == "up") ? accelerationFactorSteps : -accelerationFactorSteps; 
    accelerationFactor = constrain(accelerationFactor, 1, 10);
  }
  
  public void adjustUpHillGravity(String upDown) {
    upHillGravityFactor += (upDown == "up") ? upHillGravityFactorSteps : -upHillGravityFactorSteps; 
    upHillGravityFactor = constrain(upHillGravityFactor, 1, 6);
  }
  
  public void adjustBounce(String upDown) {
    bounceFactor += (upDown == "up") ? bounceFactorSteps : -bounceFactorSteps; 
    bounceFactor = constrain(bounceFactor, .1, .9);
  }
  
  public float getAccelerationFactor() {
    // println("Acc: " + accelerationFactor);
    return (float)(round(accelerationFactor*10))/10;
  }
  
  public float getUpHillGravityFactor() {
    // println("Grav: " + upHillGravityFactor);
    return (float)(round(upHillGravityFactor*10))/10;
  }
  
  public float getBounceFactor() {
    // println("Bounce: " + bounceFactor);
    return (float)(round(bounceFactor*100))/100;
  }
}
