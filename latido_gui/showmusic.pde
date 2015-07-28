public class ShowMusic
{
  PImage music;
  PImage birdie;
  boolean showBirdie;

  ShowMusic ()
  {
    Interactive.add( this ); // register it with the manager
    birdie = loadImage("birdie.png");
    showBirdie = true;
  }

  void load (String s)
  {
    music = loadImage(s);
    showBirdie = false;
  }

  void draw()
  {
    if (music.width==-1 || showBirdie)
    {
      image (birdie, SIDEBAR_WIDTH, TOPBAR_HEIGHT, width-SIDEBAR_WIDTH, height-TOPBAR_HEIGHT);
    } else
    {
      float rescale = (width-SIDEBAR_WIDTH-(2*PADDING))*1.0/music.width;
      image (music, SIDEBAR_WIDTH+PADDING, TOPBAR_HEIGHT+PADDING, music.width*rescale, music.height*rescale);
    }
  }
}