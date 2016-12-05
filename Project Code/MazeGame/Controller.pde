class Controller {
  
  public float xTilt = 0;
  public float yTilt = 0;
 
  Controller() {  
  }
  
  /* Functions *every* controler must implement: */
  
  void update() {
    
  }

  
  /* Functions specific to KeyController: 
     (for some reason functions only defined in the subclass seem invisible to the 
       main code, even if you specifically reference a KeyController object) 
  */

  public void keyAction() { 
  }
  
  public void keyReset() {  
  }
  
  
}