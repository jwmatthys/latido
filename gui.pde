public class LatidoButton
{
  float x, y, width, height;
  float textx, texty;
  int value;
  int state;
  PImage img;
  String label;
  PFont font;
  boolean active;
  boolean visible;

  LatidoButton ( float x, float y, float w, float h, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    active = true;
    visible = true;
  }

  LatidoButton ( float x, float y, float w, float h, String i, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    active = true;
    visible = true;
    img = loadImage(i);
  }

  LatidoButton ( float x, float y, float w, float h, String l, String i, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    if (i != null) img = loadImage(i);
    label = l;
    font = createFont("Droid Sans", 12, true);
    textFont(font);
    textSize(12);
    textx = x + (width - textWidth(label))/2;
    texty = y + height - textDescent();
    active = true;
    visible = true;
  }

  // called by manager

  void mousePressed () 
  {
    if (active)
    {
      fill(255);
      rect(x, y, width, height);
      Interactive.send( this, "pressed", value );
      state = 2;
    }
  }

  void visibility (boolean b)
  {
    if (b) visible = true;
    else {
      visible = false;
      active = false;
    }
  }

  void mouseReleased()
  {
    if (active)
    {
      state = 1;
    }
  }

  void mouseEntered ()
  {
    if (active)
    {
      state = 1;
    }
  }

  void mouseExited ()
  {
    if (active)
    {
      state = 0;
    }
  }

  void draw () 
  {
    if (visible)
    {
      switch (state)
      {
      case 2:
        fill ( #AED288 );
        break;
      case 1:
        fill( #00ADEF );
        break;
      default:
        fill( #F3DB7B );
      }
      if (!active) fill (200);
      stroke (0);
      rect(x, y, width, height, 3);
      if (font != null)
      {
        if (img != null) image(img, x+width*0.125, y, width*0.75, height*0.75);
        textFont(font);
        textSize(12);
        noStroke();
        fill(0);
        text(label, textx, texty);
      } else if (img != null) image(img, x, y, width, height);
    }
  }
}

public class HSlider
{
  float x, y, width, height;
  float valueX = 0, value;
  boolean on;

  HSlider ( float x, float y, float w, float h ) 
  {
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;

    valueX = x;

    Interactive.add( this );
  }

  void mouseEntered ()
  {
    on = true;
  }

  void mouseExited ()
  {
    on = false;
  }

  void mouseDragged ( float mx, float my )
  {
    valueX = mx - height/2;

    if ( valueX < x ) valueX = x;
    if ( valueX > x+width-height ) valueX = x+width-height;

    float oldval = value;
    value = map( valueX, x, x+width-height, 0, 1 );

    if (value != oldval)
    {
      Interactive.send( this, "valueChanged", value );
    }
  }

  void set (float v)
  {
    value = v;
    valueX = map(v, 0, 1, x, x+width-height);
  }

  public void draw ()
  {
    noStroke();

    fill( 10 );
    rect( x, y, width, height );

    fill( on ? 255 : 120 );
    rect( valueX, y, height, height );
  }
}

public class VSlider
{
  float x, y, width, height;
  float valueY = 0, value;
  boolean on;

  VSlider ( float x, float y, float w, float h ) 
  {
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;

    valueY = this.y+height-width;

    Interactive.add( this );
  }

  void mouseEntered ()
  {
    on = true;
  }

  void mouseExited ()
  {
    on = false;
  }

  void mouseDragged ( float mx, float my )
  {
    valueY = my - width/2;

    if ( valueY < y ) valueY = y;
    if ( valueY > y+height-width ) valueY = y+height-width;

    float oldval = value;
    value = map( valueY, y, y+height-width, 0, 1 );
    if (value != oldval)
    {
      Interactive.send( this, "valueChanged", value );
    }
  }

  public void draw ()
  {
    noStroke();

    fill( 10 );
    rect( x, y, width, height );

    fill( on ? 200 : 120 );
    rect( x, valueY, width, width );
  }
}

public class VolSlider
{
  float x, y, width, height;
  float valueY = 0, value;
  boolean on;

  VolSlider ( float x, float y, float w, float h ) 
  {
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;

    valueY = this.y+height;

    Interactive.add( this );
  }

  void mouseEntered ()
  {
    on = true;
  }

  void mouseExited ()
  {
    on = false;
  }

  void set (float v)
  {
    valueY = map (v, 1, 0, y, y+height);
    value = v;
  }

  void mouseDragged ( float mx, float my )
  {
    valueY = my;

    if ( valueY < y ) valueY = y;
    if ( valueY > y+height ) valueY = y+height;

    float oldval = value;
    value = map( valueY, y, y+height, 1, 0 );

    if (value != oldval)
    {
      Interactive.send( this, "valueChanged", value );
    }
  }

  public void draw ()
  {
    noStroke();

    fill( 10 );
    rect( x, y, width, height );

    if (!on) fill (120);
    else
      fill ( #ED1B24 );
    //fill (255, map(value, 0, 1, 255, 0), 0);
    rect( x, valueY, width, height+y-valueY );
  }
}

public class MicLevel
{
  float x, y, w, h;
  float value; // 0-1

  MicLevel (float x, float y, float w, float h)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    value = 0;
  }

  void set (float v)
  {
    value = v;
  }

  void draw()
  {
    noStroke();
    fill(0);
    rect(x, y, w, h);
    fill( #2E3192 );
    float bar = map(value, 0, 1, 0, h);
    rect (x, y+h-bar, w, bar);
  }
}

public class Label
{
  float x, y;
  String text;
  PFont font;

  Label (float x, float y, String text)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.text = text;
    font = createFont("Droid Sans Mono", 14, true);
  }

  void set (String s)
  {
    text = s;
  }

  void draw()
  {
    noStroke();
    fill(0);
    textFont(font);
    textSize(14);
    text(text, x, y);
  }
}

public class MetroButton
{
  float x, y, width, height;
  float textx, texty;
  int value;
  int state;
  int offFrame;
  int flashFrames;
  PImage img;
  String label;
  PFont font;

  MetroButton ( float x, float y, float w, float h, int f)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = 0;
    state = 0;
    offFrame = -1;
    flashFrames = f;
    font = createFont("Droid Sans Mono Bold", 60, true);
    textFont(font);
    textSize(60);
    textx = x + (width - textWidth('4'))/2;
    texty = y + (height+textAscent()-textDescent())/2;
  }

  void bang(int v)
  {
    offFrame = frameCount + flashFrames;
    value = v-1;
  }

  void setState(int s)
  {
    state = s;
  }

  void set (int v)
  {
    value = v-1;
  }

  void draw () 
  {
    boolean on = (frameCount < offFrame);
    if (state>0)
    {
      switch (state)
      {
      case 2:
        // green
        fill ( #B1D28B );
        break;
      case 1:
        // red
        fill( #DE6C6C );
        break;
      default:
        fill(255);
      }
      if (on) fill(0);
      stroke (0);
      rect(x, y, width, height, 5);
      noStroke();
      fill(on? 255 : 0);
      textFont(font);
      textSize(60);
      text(nf(value+1, 1), textx, texty);
    }
  }
}