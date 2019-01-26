class KeyController extends Controller {

  
  private float xTiltChange = 0;   
  private float yTiltChange = 0;   
  private float TiltChangeRate = 0.001;

  KeyController() {
  }

  
  public void update() {
    // translate cursor key strokes into tray tilt increase/decrease  (max ~ -3 and 3 degrees (in rad))
    xTilt += xTiltChange;  
    yTilt += yTiltChange;
    xTilt = constrain(xTilt, -0.05, 0.05);  
    yTilt = constrain(yTilt, -0.05, 0.05);
  }

  
  /*
  * called by keyPressed() in main MazeGame
  */
  public void keyAction() {
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
  

  /*
  * called by keyReleased() in main MazeGame
  */
  public void keyReset() {
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