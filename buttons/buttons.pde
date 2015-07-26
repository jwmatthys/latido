import de.bezier.guido.*;

LaTiDoButton play, stop;

void setup()
{
  size(800, 600);

  Interactive.make(this);
  play = new LaTiDoButton (10, 10, 50, 50, "appbar.control.play.png");
  stop = new LaTiDoButton (10, 70, 50, 50, "appbar.control.stop.png");

  Interactive.on( play, "pressed", this, "playButton" );
  Interactive.on( stop, "pressed", this, "stopButton" );
}

void draw()
{
  background(255);
}

void playButton ()
{
  println("play button pressed");
}

void stopButton ()
{
  println("stop button pressed");
}


public class LaTiDoButton
{
  float x, y, w, h;
  boolean active;
  PImage img;

  LaTiDoButton ( float x, float y, float w, float h, String i)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
    img = loadImage(i);
  }

  // called by manager

  void mousePressed () 
  {
    Interactive.send( this, "pressed" );
  }

  void mouseEntered ()
  {
    active = true;
  }

  void mouseExited ()
  {
    active = false;
  }

  void draw () 
  {
    if ( active ) fill( 0, 200, 0 );
    else fill( 200, 0, 0 );
    rect(x, y, w, h);
    image(img, x, y, w, h);
  }
}