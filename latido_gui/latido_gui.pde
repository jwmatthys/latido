import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;
import de.bezier.guido.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5tcpClient;
LaTiDoButton play, stop, pitch, replay;

void setup()
{
  oscP5tcpClient = new OscP5(this, "127.0.0.1", 11000, OscP5.TCP);
  PImage icon = loadImage("appbar.futurama.bender.png");

  size(800, 600);
  if (surface != null) {
    surface.setResizable(true);
  }
  frame.addComponentListener(new ComponentAdapter() {
    public void componentResized(ComponentEvent e) {
      if (e.getSource()==surface) {
        println("resized to:" + width+" x "+height+" mouse: "+mouseY +" "+mouseY);
      }
    }
  }
  );

  Interactive.make(this);
  play = new LaTiDoButton (10, 10, 50, 50, "appbar.control.play.png", 0);
  stop = new LaTiDoButton (10, 70, 50, 50, "appbar.control.stop.png", 1);
  pitch = new LaTiDoButton (10, 130, 50, 50, "tuningfork1.png", 2);
  replay = new LaTiDoButton (10, 190, 50, 50, "appbar.social.uservoice.png", 3);

  Interactive.on( play, "pressed", this, "transportButton" );
  Interactive.on( stop, "pressed", this, "transportButton" );
  Interactive.on( pitch, "pressed", this, "transportButton" );
  Interactive.on( replay, "pressed", this, "transportButton" );
}

void draw()
{
  background(255);
  fill(100);
  noStroke();
  rect(0, 0, 70, height);
}

void transportButton (int v)
{
  switch (v)
  {
  case 0:
    println("play button pressed");
    break;
  case 1:
    println("stop button pressed");
    break;
  case 2:
    println("pitch button pressed");
    break;
  case 3:
    println("replay button pressed");
  }
}

public class LaTiDoButton
{
  float x, y, width, height;
  int value;
  int state;
  PImage img;

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
    rect(x, y, width, height);
    image(img, x, y, width, height);
  }
}