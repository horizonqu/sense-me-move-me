import gab.opencv.*;
import KinectPV2.*;

KinectPV2 kinect;
OpenCV opencv;

// Resolution of contour
float polygonFactor = 1;

// Contour threshold
int threshold = 10;

//Distance in cm
int maxD = 4500; //4.5m
int minD = 50; //50cm

// Drawing mode
int mode = 0;


void setup() {
  size(800, 600, P2D);
  opencv = new OpenCV(this, 512, 424);
  kinect = new KinectPV2(this);
  kinect.enableBodyTrackImg(true);
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  kinect.init();
}

void draw() {
  background(0);

  noFill();

  opencv.loadImage(kinect.getBodyTrackImage());
  opencv.gray();
  opencv.threshold(threshold);
  PImage dst = opencv.getOutput();
  //image(dst, 0, 0);

  ArrayList<Contour> contours = opencv.findContours(false, false);

  if (contours.size() > 0) {
    for (Contour contour : contours) {

      contour.setPolygonApproximationFactor(polygonFactor);
      if (contour.numPoints() > 50) {

        noFill();
        stroke(255);       
        strokeWeight(10);

        beginShape();
        for (PVector point : contour.getPolygonApproximation ().getPoints()) {
          if (point.x < 10 || point.x > dst.width-10) continue;

          // Scale the contour to 2x its size
          point.mult(2);
          PVector offset = new PVector();

          if (mode > 0) {
            switch(mode) {
            case 1:
              // Defining a circular pathway
              float x = sin(frameCount*0.01)*cos(frameCount*0.01)*width + width/2;
              float y = cos(frameCount*0.01)*sin(frameCount*0.02)*width + height/2;
              PVector mouse = new PVector(x, y);

              // Define a vector radiating from the contour point to the mouse
              offset = PVector.sub(mouse, point);
              offset.setMag(250);
              point.add(offset);
              break;
            case 2:
              // Define a vector radiating from the contour point to the corner
              PVector center = new PVector(width/2, height/2);
              offset = PVector.sub(point, center);
              offset.setMag(500);
              offset.add(point);
              stroke(255, 10);
              // Draw radiating line
              line(point.x, point.y, offset.x, offset.y);
              break;
            }
          }
          // Draw the point
          vertex(point.x, point.y);
        }
        endShape();
      }
    }
  }

  // Draw the "mouse"
  if (mode == 1) {
    noStroke();
    fill(255, 0, 0);
    ellipse(mouse.x, mouse.y, 50, 50);
  }

  noStroke();
  fill(255);
  textSize(18);
  text("Press TAB to change modes: " + mode, 10, 20);
  text("Press RT/LT arrow keys to change resolution: " + polygonFactor, 10, 40);
}

void keyPressed() {
  switch(keyCode) {
  case TAB:
    mode++;
    mode%=3;
    break;
  case RIGHT:
    polygonFactor++;
    break;
  case LEFT:
    polygonFactor--;
    break;
  }
  polygonFactor = constrain(polygonFactor, 1, 50);
}