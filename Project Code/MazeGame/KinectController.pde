class KinectController extends Controller {
  
  // Connection code for Kinect is adapted from: 
  // Daniel Shiffman
  // All features test
  
  // https://github.com/shiffman/OpenKinect-for-Processing
  // http://shiffman.net/p5/kinect/
  
  //import org.openkinect.freenect.*;
  //import org.openkinect.processing.*;
  
  Kinect kinect;
  
  float deg;
  PImage img;
  int currentHue = 0;
  int currentBrightness = 0;
  int xWeight;
  int yWeight;
  int relevantPoints;
  
  // default values - will be adjusted by calibration
  int minXWeight = 100;
  int maxXWeight = 500;
  int minYWeight = 20;
  int maxYWeight = 80;
 
  
  boolean calibrationInProgress = false;
  int calibrationStart;
  boolean cameraAdjustmentInProgress = false;
  
  

  KinectController(Kinect kinect) {
    this.kinect = kinect;
    kinect.initDepth();
    kinect.enableColorDepth(true);
    kinect.enableMirror(true);
  
    deg = kinect.getTilt();    // for moving the actual camera up and down    
  }

 
 public boolean getCalibrationInProgress() {
    return calibrationInProgress;
 }
 
 public boolean getCameraAdjustmentInProgress() { 
   return cameraAdjustmentInProgress; 
 }
 
 public void setCameraAdjustmentInProgress(boolean onOff) { 
    cameraAdjustmentInProgress = onOff; 
 }
 
  public void calibrate() {
    
    calibrationInProgress = true;
    calibrationStart = millis();
    
    
    // reset current thresholds 
    minXWeight = 9999;
    maxXWeight = 0;
    minYWeight = 9999;
    maxYWeight = 0;
  }
  
  
  private void showCameraScreen() {
    
    // set the board level (just so the corners don't stick up through calibration screen)
    xTilt = 0;
    yTilt = 0;
    
    pushMatrix();
    translate(0, 0, 40);
    fill(50);
    noStroke();
    rectMode(CORNER);
    rect(0, 0, width, height);
    imageMode(CENTER);
    image(img, width/2, height/2);  // display depth image    
    popMatrix();
  }
  
  private void runCalibration() {
    
    // show calibration screen
    showCameraScreen();

    pushMatrix();
    translate(0, 0, 40);

    int timeNow = millis();
    int stepTime = 5000;   // time the user has to complete each calibration step 
    if (timeNow - calibrationStart < stepTime) {
      displayInstructions("LEFT");
    } else if (timeNow - calibrationStart < 2 * stepTime) {
      displayCalibrationData(LEFT);
      if (xWeight < minXWeight) minXWeight = xWeight;
    } else if (timeNow - calibrationStart < 3 * stepTime) {
      displayInstructions("RIGHT");
    } else if (timeNow - calibrationStart < 4 * stepTime) {
      displayCalibrationData(RIGHT);
      if (xWeight > maxXWeight) maxXWeight = xWeight;
    } else if (timeNow - calibrationStart < 5 * stepTime) {
      displayInstructions("FRONT");
    } else if (timeNow - calibrationStart < 6 * stepTime) {
      displayCalibrationData(TOP);
      if (yWeight < minYWeight) minYWeight = yWeight;
    } else if (timeNow - calibrationStart < 7 * stepTime) {
      displayInstructions("BACK");
    } else if (timeNow - calibrationStart < 8 * stepTime) {
      displayCalibrationData(BOTTOM);
      if (yWeight > maxYWeight) maxYWeight = yWeight;
    } else {
      calibrationInProgress = false;
    }
    popMatrix();
    
    
    updateTilt();
  }
  
  private void displayInstructions(String dir) {
    String text = "Stand in the center \n  and get ready to \n move to the " + dir + "\n of your playing area.";
    fill(0);
    textAlign(CENTER);
    textSize(45);
    text(text, width/2 + 3, height/3 +3);      
    fill(255);
    text(text, width/2, height/3);      
  }
  
  private void displayCalibrationData(int dir) {
    fill(255);
    textAlign(CENTER);
    textSize(45);
    int currentWeight = (dir == LEFT || dir == RIGHT) ? xWeight : yWeight;
    int threshold = (dir == LEFT) ? minXWeight : (dir == RIGHT) ? maxXWeight : (dir == TOP) ? minYWeight : maxYWeight;
    int x = (dir == TOP || dir == BOTTOM) ? width/2 : (dir == LEFT) ? (width - 640)/4 : width - (width - 640)/4 ;
    int y = (dir == LEFT || dir == RIGHT) ? height/2 : (dir == TOP) ? (height - 520)/4 : height - (height - 520)/4 ;
    String divider = (dir == LEFT || dir == RIGHT) ? "\n => \n" : " => ";
    text(currentWeight + divider + threshold, x, y);      
  }
  
  
  public void update() {
    img = kinect.getDepthImage();
    
    if (calibrationInProgress) {
      runCalibration();
    } else {
      updateTilt();
    }
    
    if (cameraAdjustmentInProgress) {
      showCameraScreen();
    }
  }
  
  
  public void updateTilt() {
    
    relevantPoints = 0;  // points that contain useful data (i.e. not black (= too far / too close) or blue (= too far)
    float totalXWeight = 0;
    float totalYWeight = 0;
    // check points at 10 pixels apart for their hue and brightness
    for (int col = 10; col < img.width; col += 10) {
      for (int row = 10; row < img.height; row += 10) {
         int index = row * img.width + col;
         int currentPix = img.pixels[index];
         if (brightness(currentPix) > 0 && hue(currentPix) < 100) {  // ignore black and blue pixels
           totalXWeight += col;     // for left/right movement each valid colour counts the same, but the further right the pixel the more it counts  
           totalYWeight += hue(currentPix);  // for front/back movement red pixels count most, then yellow, and green the least
           relevantPoints++;
         }
      }
    }
    if (relevantPoints > 0) {
      xWeight = (int)totalXWeight/relevantPoints;
      yWeight = (int)totalYWeight/relevantPoints;
    }
    
    if (!calibrationInProgress) {
      // translate depth-image data to tray tilt angles between ~ -3 and 3 degrees (in rad)
      yTilt = map(xWeight, minXWeight, maxXWeight, -0.05, 0.05);  
      xTilt = map(yWeight, maxYWeight, minYWeight, -0.05, 0.05);
      yTilt = constrain(yTilt, -0.06, 0.06); 
      xTilt = constrain(xTilt, -0.06, 0.06); 
    }

    // println(xWeight + " / " + yWeight + " (" + relevantPoints + " points)");

  }
  
  public void keyAction() {
  
    if (key == CODED) {
      if (keyCode == UP) {
        deg++;
      } else if (keyCode == DOWN) {
        deg--;
      }
      deg = constrain(deg, 0, 30);
      kinect.setTilt(deg);
      cameraAdjustmentInProgress = true;
    } else {
      cameraAdjustmentInProgress = false;
    }
    
  }

}