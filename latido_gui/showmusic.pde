public class ShowMusic
{
  PImage music;

  ShowMusic ()
  {
    Interactive.add( this ); // register it with the manager
  }

  void load (String s)
  {
    music = loadImage(s);
  }

  void draw()
  {
    float rescale = (width-SIDEBAR_WIDTH-(2*PADDING))*1.0/music.width;
    if (music != null)
      image (music, SIDEBAR_WIDTH+PADDING, TOPBAR_HEIGHT+PADDING, music.width*rescale, music.height*rescale);
  }
}