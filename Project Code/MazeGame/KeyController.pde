class KeyController extends Controller {

  
  float xTiltChange = 0;   
  float yTiltChange = 0;   
  float TiltChangeRate = 0.001;

  KeyController() {
  }
  
  
  void keyAction() {
    println("key pressed");
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
  

  void update() {
    // translate cursor key strokes into tray tilt increase/decrease  (max ~ -3 and 3 degrees (in rad))
    xTilt += xTiltChange;  
    yTilt += yTiltChange;
    print("updating tilt: " + xTilt + " / " + yTilt);
    constrain(xTilt, -0.05, 0.05);
    constrain(yTilt, -0.05, 0.05);
    println(" constrained to: " + xTilt + " / " + yTilt);
  }


  void keyReset() {
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
}