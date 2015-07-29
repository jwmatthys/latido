public class Splash
{
  boolean active;
  PImage splashImage;

  Splash()
  {
    Interactive.add( this ); // register it with the manager
    splashImage = loadImage("splash.png");
    active = true;
  }

  void draw()
  {
    if (active)
    {
      image (splashImage, 2*PADDING, 2*PADDING,width-4*PADDING, height-4*PADDING);
      noFill();
      stroke(0);
      strokeWeight(3);
      rect(2*PADDING, 2*PADDING, width-4*PADDING, height-4*PADDING);
      strokeWeight(1);
    }
  }
}