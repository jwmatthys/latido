class Splash extends Canvas
{
  PImage splashImage;

  public void setup(PApplet p)
  {
    splashImage = loadImage("images/splash.png");
  }

  public void draw(PApplet pg)
  {
    //image (splashImage, 0, 0, (width-SIDEBAR_WIDTH-4*PADDING), (int)(height-4*PADDING));
    noFill();
    stroke(0);
    strokeWeight(3);
    rect(0, 0, (width-SIDEBAR_WIDTH-4*PADDING), (int)(height-4*PADDING));
    strokeWeight(1);
  }
}

