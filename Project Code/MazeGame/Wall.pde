class Wall {
  
  public Point start;
  public Point end;
  
  // temp var for debugging
  public boolean highlight = false;
  
  
  Wall(Point start, Point end) {
    this.start = start;
    this.end = end;    
  }
  
  
  public void display(int lineWidth, IntDict colors) {
    stroke(colors.get("shadow"));
    // tmp debugging color change:
    //if (highlight) stroke(0, 255, 0);
    highlight = false;
    strokeWeight(lineWidth);
    strokeCap(ROUND);
    line(start.x, start.y, end.x, end.y); 
    pushMatrix();
    translate(0, 0, 1);
    stroke(colors.get("mainColor"));
    strokeWeight(lineWidth * .8);
    strokeCap(ROUND);
    line(start.x, start.y, end.x, end.y); 
    translate(0, 0, 1);
    stroke(colors.get("highlight"));
    strokeWeight(lineWidth * .2);
    strokeCap(ROUND);
    line(start.x, start.y, end.x, end.y); 
    popMatrix();
  }
}