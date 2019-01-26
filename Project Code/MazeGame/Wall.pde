class Wall {
  
  public Point start;
  public Point end;
  private String type;
  
  // temp var for debugging (turn on to see which walls are actively watching out for the ball at any time)
  public boolean highlight = false;
  
  
  Wall(Point start, Point end, String type) {
    this.start = start;
    this.end = end; 
    this.type = type;
  }
  
  
  public void display(int lineWidth, IntDict colors, float xTilt, float yTilt) {
    strokeWeight(lineWidth);
    //strokeCap(ROUND);   // not working
    stroke(colors.get("shadow"));
    
    // for outside walls:
    //  - draw only the shadow  (the actual visual wall is drawn separtely with rounded corners)
    //  - only draw the shadow if it falls to the inside of the frame
    if ((type == "topFrame" && xTilt < 0) || (type == "bottomFrame" && xTilt > 0)) {
      line(start.x, start.y - xTilt * 80, end.x, end.y - xTilt * 80);  
    } else if ((type == "leftFrame" && yTilt > 0) || (type == "rightFrame" && yTilt < 0)) {
      line(start.x + yTilt * 80, start.y, end.x + yTilt * 80, end.y);  
    } else if (type == "maze") {
      // for maze walls draw everything
      
      // shadow
      line(start.x + yTilt * 100, start.y - xTilt * 100, end.x + yTilt * 100, end.y - xTilt * 100);
      noStroke();
      fill(colors.get("shadow"));
      ellipse(start.x + yTilt * 100, start.y - xTilt * 100, lineWidth, lineWidth);
      ellipse(end.x + yTilt * 100, end.y - xTilt * 100, lineWidth, lineWidth);
      
      pushMatrix();
      
      // 1. layer of 3D wall (dark edges)
      translate(0, 0, 1);
      noStroke();
      fill(colors.get("shade"));
      ellipse(start.x, start.y, lineWidth, lineWidth);
      ellipse(end.x, end.y, lineWidth, lineWidth);
      strokeWeight(lineWidth);
      stroke(colors.get("shade"));
      // tmp debugging color change:
      //if (highlight) stroke(0, 255, 0);
      highlight = false;
      line(start.x, start.y, end.x, end.y); 
     
      // 2. layer of 3D wall  (gray)
      translate(0, 0, 1);
      noStroke();
      fill(colors.get("mainColor"));
      ellipse(start.x, start.y, lineWidth * .8, lineWidth * .8);
      ellipse(end.x, end.y, lineWidth * .8, lineWidth * .8);
      stroke(colors.get("mainColor"));
      strokeWeight(lineWidth * .8);
      line(start.x, start.y, end.x, end.y); 
 
      // 3. layer of 3D wall  (highlights)
      translate(0, 0, 1);
      noStroke();
      fill(colors.get("highlight"));
      ellipse(start.x, start.y, lineWidth * .2, lineWidth * .2);
      ellipse(end.x, end.y, lineWidth * .2, lineWidth * .2);
      stroke(colors.get("highlight"));
      strokeWeight(lineWidth * .2);
      line(start.x, start.y, end.x, end.y); 
      popMatrix();
    }
  }
}
