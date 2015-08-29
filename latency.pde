class Latency extends Canvas
{
  boolean loaded = false;

  public void setup(PGraphics pg)
  {
  }

  public void draw(PGraphics pg)
  {
    if (!loaded)
    {
      loaded = true;
    } else
    {
      stroke(0);
      strokeWeight(1);
      fill(255);
      rect(0, 0, (width-SIDEBAR_WIDTH-4*PADDING), (int)(height-4*PADDING));
    }
  }
}