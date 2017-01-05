class Controller {
  
  public float xTilt = 0;
  public float yTilt = 0;
 
  Controller() {  
  }
  
  /* Functions *every* controler must implement: */
  
  public void update() {
  }

  
  /* Functions specific to individual controllers: 
     (for some reason I can't seem to cast the controller instances to their actual sub-class to get access to
      functions only defined in the specific controler 
      e.g.: (KeyController)keyController.keyAction();   gives an error, even though keyController IS a KeyController ..)
      // TODO: find out why ...
  */

  // KeyController and KinectController:    

  public void keyAction() {}                                       // KeyController and KinectController    
  
  public void keyReset() {}                                        // KeyController    
  
  public boolean getCalibrationInProgress() { return false; }      // KinectController    

  public void calibrate() {}                                       // KinectController
  
  public boolean getCameraAdjustmentInProgress() { return false; }      // KinectController  
  
  public void setCameraAdjustmentInProgress(boolean onOff) {}      // KinectController  
}