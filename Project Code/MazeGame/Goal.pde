class Goal {
  
  int maxRadius;
  Point pos;
  boolean found = false;
  
 Goal(int maxSize) {
   maxRadius = maxSize/2;
 }
 
 public void display() {
   pushMatrix();
   translate(0, 0, 2);
   noFill();
   if (found) {
      int radius = int(maxRadius * .6);
      ellipseMode(RADIUS);
      stroke(255,200,0);
      strokeWeight(10);
      ellipse(pos.x, pos.y, radius, radius);
      stroke(255,255,0);
      strokeWeight(5);
      ellipse(pos.x, pos.y, radius, radius);
      stroke(255,255,255);
      strokeWeight(2);
      ellipse(pos.x, pos.y, radius, radius);
   } else {
      int radius = int(maxRadius * .3);
      ellipseMode(RADIUS);
      stroke(130);
      strokeWeight(4);
      ellipse(pos.x, pos.y, radius, radius);
   }
   popMatrix();
 }
 
 public void checkIfFound(Point ballPos) {
   if (!found) {
     if (ballPos.x > pos.x - maxRadius && ballPos.x < pos.x + maxRadius && 
         ballPos.y > pos.y - maxRadius && ballPos.y < pos.y + maxRadius) {
       found = true;
     }
   }
 }
}