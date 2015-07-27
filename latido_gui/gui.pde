public class LaTiDoButton
{
  float x, y, width, height;
  float textx, texty;
  int value;
  int state;
  PImage img;
  String label;
  PFont font;

  LaTiDoButton ( float x, float y, float w, float h, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
  }

  LaTiDoButton ( float x, float y, float w, float h, String i, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    img = loadImage(i);
  }

  LaTiDoButton ( float x, float y, float w, float h, String l, String i, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    img = loadImage(i);
    label = l;
    font = createFont("Droid Sans",12,true);
    textFont(font);
    textx = x + (width - textWidth(label))/2;
    texty = y + height - textDescent();
  }

  // called by manager

  void mousePressed () 
  {
    fill(255);
    rect(x, y, width, height);
    Interactive.send( this, "pressed", value );
    state = 2;
  }

  void mouseReleased()
  {
    state = 1;
  }

  void mouseEntered ()
  {
    state = 1;
  }

  void mouseExited ()
  {
    state = 0;
  }

  void draw () 
  {
    switch (state)
    {
    case 2:
      fill (255);
      break;
    case 1:
      fill( 0, 200, 0 );
      break;
    default:
      fill( 200, 0, 0 );
    }
    stroke (0);
    rect(x, y, width, height);
    if (img != null) image(img, x, y, width, height);
    if (font != null)
    {
      textFont(font);
      noStroke();
      fill(0);
      text(label,textx,texty);
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

    fill( on ? 200 : 120 );
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
  
  void set (float v)
  {
    valueY = map (v, 1, 0, y, y+height-width);
    value = v;
  }

  void mouseDragged ( float mx, float my )
  {
    valueY = my - width/2;

    if ( valueY < y ) valueY = y;
    if ( valueY > y+height-width ) valueY = y+height-width;

    float oldval = value;
    value = map( valueY, y, y+height-width, 1, 0 );

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
      fill (255, map(value, 0, 1, 255, 0), 0);
    rect( x, valueY, width, height+y-valueY );
  }
}

public class MicLevel
{
  float x, y, w, h;
  float value; // 0-1

  MicLevel (float x, float y, float w, float h)
  {
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
    fill(20, map(value,0,1,10,100), 200);
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
    this.x = x;
    this.y = y;
    this.text = text;
    font = createFont("Droid Sans Mono", 14, true);
    textFont(font);
  }
  
  void set (String s)
  {
    text = s;
  }
  
  void draw()
  {
    noStroke();
    fill(0);
    text(text,x,y);
  }
}