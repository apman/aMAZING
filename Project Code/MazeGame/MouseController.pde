class MouseController extends Controller {

  MouseController() {
  }

  void update() {
    // translate mouse movement to tray tilt angles between ~ -3 and 3 degrees (in rad)
    xTilt = map(mouseY, height, 0, -0.05, 0.05);  
    yTilt = map(mouseX, 0, width, -0.05, 0.05);
  }
}