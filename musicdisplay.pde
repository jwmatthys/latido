class MusicDisplay
{
  PImage music;
  boolean active;

  MusicDisplay()
  {
  }

  void load (String s)
  {
    music = loadImage(s);
  }

  void draw()
  {
    if (music != null && music.width > 0)
    {
      float rescale = (width-SIDEBAR_WIDTH-(2*PADDING))*1.0/music.width;
      float rescale2 = (height-TOPBAR_HEIGHT-(2*PADDING))*1.0/music.height;
      rescale = min(rescale, rescale2);
      image (music, SIDEBAR_WIDTH+PADDING, TOPBAR_HEIGHT+PADDING, music.width*rescale, music.height*rescale);
    }
  }


  /*
  void setText (String s)
   {
   text = loadStrings(s);
   }
   */

  /*
  void drawText()
   {
   textFont(font);
   textSize(18);
   noStroke();
   fill(0);
   float y = TOPBAR_HEIGHT+2*PADDING;
   if (text.length>0)
   {
   for (int i=0; i<text.length; i++)
   {
   text(text[i], (SIDEBAR_WIDTH+width)*0.55, y);
   y += (textAscent()+textDescent())*1.5;
   }
   }
   }*/
}

