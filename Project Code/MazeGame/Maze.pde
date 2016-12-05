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
  private Point ballPos = new Point(0, 0);
  private float speedFactor = 360;  // the higher the factor the faster the ball
  
  
  // maze walls
  
  // NOTE: the zero & last row/column *could* be used to draw the tray edge 
  //        but probably not worth changing (could be complicated to get the 
  //        rounded corners
  // 
  // TODO: maybe make a grid that is wider than the current square tray and then 
  //       depending on how many channels fit onto the tray, use only part of the 
  //       grid ...
  int[][][] wallEdgesH = {{},            
                          {{3,5},{6,7},{9,11}}, 
                          {{0,2},{5,6},{7,8}},
                          {{4,5},{7,9},{10,12}},
                          {{1,3},{4,5},{6,8},{9,10}},
                          {{2,4},{8,9}},
                          {{1,2},{4,6},{7,8},{10,11}},
                          {{0,1},{6,7},{10, 12}},
                          {{1,2},{7,8},{10, 11}},
                          {{2,3},{4,5},{7,9},{10,11}},
                          {}};
  int[][][] wallEdgesV = {{},            
                          {{0,1},{3,6},{8,9}}, 
                          {{1,3},{6,8}},
                          {{1,3},{5,9}},
                          {{2,3},{6,8},{9,10}},
                          {{1,2},{4,6},{7,9}},
                          {{0,1},{2,3},{4,9}},
                          {{1,2},{5,6},{9,10}},
                          {{1,2},{4,5},{6,8}},
                          {{1,3},{6,8}},
                          {{3,5}},
                          {{1,2},{4,6},{8,9}},
                          {}};
   Wall[][] wallsH = new Wall[0][0];
   Wall[][] wallsV = new Wall[0][0];
 
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
    innerFrameWidth = boxHeight / 60;
    outerFrameWidth = boxHeight / 30;
    trayWidth = boxWidth - 2 * outerFrameWidth - innerFrameWidth/2;
    trayHeight = boxHeight - 2 * outerFrameWidth - innerFrameWidth/2;
    ballSize = 2 * innerFrameWidth;
    
    // precalculated values for faster drawing
    topLeft = new Point(-trayWidth/2, -trayHeight/2);   
    topLeftBoundry = new Point(-trayWidth/2 + ballSize*.8, -trayHeight/2 + ballSize*.8);   
    bottomRightBoundry = new Point(trayWidth/2 - ballSize*.8, trayHeight/2 - ballSize*.8); 

    pathWidthH = optimalPathWidth(trayWidth);
    pathWidthV = optimalPathWidth(trayHeight);
    //pathWidthH = optimalPathWidth(bottomRightBoundry.x - topLeftBoundry.x);
    //pathWidthV = optimalPathWidth(bottomRightBoundry.y - topLeftBoundry.y);


    // Convert the conceptual edges (as in edges of a graph) from simple coordinates to  
    //  Wall objects with pre-calculated pixel positions
    float cap = innerFrameWidth * .1;
    for (int row = 0; row < wallEdgesH.length; row++) {
      int[][] wallRow = wallEdgesH[row];
      Wall[] walls = new Wall[0];
      for (int lineNum = 0; lineNum < wallRow.length; lineNum++) {
        Wall wall = new Wall(new Point(topLeft.x + wallRow[lineNum][0] * pathWidthH - cap, 
                                        topLeft.y + row * pathWidthV),
                              new Point(topLeft.x + wallRow[lineNum][1] * pathWidthH + cap, 
                                        topLeft.y + row * pathWidthV));
        walls = (Wall[])append(walls, wall);                               
      }
      wallsH = (Wall[][])append(wallsH, walls);
    }
    
   for (int col = 0; col < wallEdgesV.length; col++) {
      int[][] wallCol = wallEdgesV[col];
      Wall[] walls = new Wall[0];
      for (int lineNum = 0; lineNum < wallCol.length; lineNum++) {
        Wall wall = new Wall(new Point(topLeft.x + col * pathWidthH, 
                                        topLeft.y + wallCol[lineNum][0] * pathWidthV - cap),
                              new Point(topLeft.x + col * pathWidthH, 
                                        topLeft.y + wallCol[lineNum][1] * pathWidthV + cap));
        walls = (Wall[])append(walls, wall);                               
      }
      wallsV = (Wall[][])append(wallsV, walls);
    }
   
}
  
  private float optimalPathWidth(float space) {
    // calculate best distance between walls based on ballSize, trayWidth/trayHeight (= space)
    
    // take a decent width to start with, see how many of them you can fit into 
    //  the tray width/height and then adjust the pathWidth to fit an even number of 
    //  paths exactly into the frame (i.e. no half paths)
    float pathWidth = 3 * ballSize;
    int pathNum = round(space / pathWidth);
    pathWidth = space / pathNum;
    
    return pathWidth;
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
    drawMaze();
    
    setBallPos(xTilt, yTilt);
    drawBall(ballPos);
    
    // draw the frame
    drawFrame(0, 0, trayWidth + innerFrameWidth/2, trayHeight + innerFrameWidth/2, innerFrameWidth, trayColors);
  }  
  
  
  private void setBallPos(float xTilt, float yTilt) {
    
    float xMovement = yTilt * speedFactor;  // negative tilt -> ball rolls left
    float yMovement = xTilt * speedFactor;  // negative tilt -> ball rolls down
    
    float xBounceFactor = xMovement;
    float yBounceFactor = yMovement;
    
    // separate speed (movement) and direction, so the movement can be applied incrementally
    //  while checking the walls (if the ball moves to much at once it skips the walls)
    int xDirection = 1;
    int yDirection = 1;    
    if (xMovement < 0) {
      xDirection = -1;
      xMovement = abs(xMovement);
    }
    if (yMovement < 0) {
      yDirection = -1;
      yMovement = abs(xMovement);
    }
    
    while (xMovement > 0) {
      // update ball position based on the tray's tilt in increments small enough not to miss a wall
      float moveBy = (xMovement > innerFrameWidth/2) ? innerFrameWidth/2 : xMovement;
      ballPos.x += moveBy * xDirection;  
      xMovement -= moveBy;
      // ensure it stays within the tray area
      ballPos.x = constrain(ballPos.x, topLeftBoundry.x, bottomRightBoundry.x);
      // narrow down in area the ball currently is
      float col = (ballPos.x - topLeft.x)/pathWidthH;
      // adjust ball position to avoid the maze walls to the left and the right
      if (avoidWallsV(wallsV[ceil(col)], yTilt, xBounceFactor)) break;  
      if (avoidWallsV(wallsV[floor(col)], yTilt, xBounceFactor)) break;   
    }
    
    while (yMovement > 0) {
      // update ball position based on the tray's tilt in increments small enough not to miss a wall
      float moveBy = (yMovement > innerFrameWidth/2) ? innerFrameWidth/2 : yMovement;
      ballPos.y -= moveBy * yDirection;  
      yMovement -= moveBy;;    
      // ensure it stays within the tray area
      ballPos.y = constrain(ballPos.y, topLeftBoundry.y, bottomRightBoundry.y );
      // narrow down in area the ball currently is
      float row = (ballPos.y - topLeft.y)/pathWidthV;
      // adjust ball position to avoid the maze walls above and below 
      if (avoidWallsH(wallsH[floor(row)], xTilt, yBounceFactor)) break;   
      if (avoidWallsH(wallsH[ceil(row)], xTilt, yBounceFactor)) break;   
    }
  }

  
  /* TODO: to implement bounce there are a few things that would need to be done: 
           * implement a more realistic acceleration (because the ball's speed only hinges on the tilt, 
              it will come back to the wall after a bounce just as fast as it did initially)
           * remove the 'constrain' that keeps the ball within the tray (in setBallPos()) and implement 
              the outer walls as walls (would need some condition to stop them actually being drawn)
  */
  

  private boolean avoidWallsV(Wall[] walls, float yTilt, float bounceFactor) {
    boolean touchingWall = false;
    for (int w = 0; w < walls.length; w++) {
      Wall wall = walls[w];
      if (ballPos.y > wall.start.y && ballPos.y < wall.end.y) {
        wall.highlight = true;
        // check left or right of wall, depending on tilt 
        //  and correct ballPos to keep the ball off the wall
        if (yTilt >= 0 && ballPos.x >= wall.start.x - ballSize * .6     // ball rolling right & touching the left side of the wall
                          && ballPos.x <= wall.start.x) {
          //ballPos.x = wall.start.x - ballSize *.6 - bounceFactor;  // TODO: works sort of, but makes the ball flicker back & forth
          ballPos.x = wall.start.x - ballSize *.6;
          touchingWall = true;
        } else if (yTilt <= 0 && ballPos.x <= wall.start.x + ballSize * .8    // ball rolling left & touching right side of the wall
                               && ballPos.x >= wall.start.x) {
          ballPos.x = wall.start.x + ballSize * .8;
          touchingWall = true;
          
        }
      } 
    }
    return touchingWall;
  }
  
  private boolean avoidWallsH(Wall[] walls, float xTilt, float bounceFactor) {
    boolean touchingWall = false;
    for (int w = 0; w < walls.length; w++) {
      Wall wall = walls[w];
      if (ballPos.x > wall.start.x && ballPos.x < wall.end.x) {
        wall.highlight = true;
        // check top or bottom of wall, depending on tilt 
        //  and correct ballPos to keep the ball off the wall
        if (xTilt <= 0 && ballPos.y >= wall.start.y - ballSize * .6
                          && ballPos.y <= wall.start.y) {
          ballPos.y = wall.start.y - ballSize *.6;
          touchingWall = true;
        } else if (xTilt >= 0 && ballPos.y <= wall.start.y + ballSize * .8
                               && ballPos.y >= wall.start.y) {
          ballPos.y = wall.start.y + ballSize * .8;
          touchingWall = true;
        }
      } 
    }
    return touchingWall;
  }

 
  private void drawMaze() {
    for (int row = 0; row < wallsH.length; row++) {
      Wall[] wallRow = wallsH[row];
      for (int wall = 0; wall < wallRow.length; wall++) {
        wallRow[wall].display(innerFrameWidth, trayColors);
      }
    }
    
    for (int col = 0; col < wallsV.length; col++) {
      Wall[] wallCol = wallsV[col];
      for (int wall = 0; wall < wallCol.length; wall++) {
        wallCol[wall].display(innerFrameWidth, trayColors);
      }
    }
    
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