class Splash extends Canvas
{
  PImage splashImage;
  boolean loaded = false;

  public void setup(PGraphics pg)
  {
  }

  public void draw(PGraphics pg)
  {
    if (!loaded)
    {
      splashImage = loadImage("images/newsplash.png");
      loaded = true;
    } else
    {
      image (splashImage, 0, 0, (width-SIDEBAR_WIDTH-4*PADDING), (int)(height-4*PADDING));
      noFill();
      stroke(0);
      strokeWeight(3);
      rect(0, 0, (width-SIDEBAR_WIDTH-4*PADDING), (int)(height-4*PADDING));
      strokeWeight(1);
    }
  }
}