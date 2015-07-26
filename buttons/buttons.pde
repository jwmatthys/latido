import de.bezier.guido.*;

LaTiDoButton play, stop;

void setup()
{
  size(800,600);
  
  Interactive.make(this);
  play = new LaTiDoButton (10,10,50,50);
  stop = new LaTiDoButton (10,70,50,50);
  
  Interactive.on( play, "pressed", this, "playButton" );
  Interactive.on( stop, "pressed", this, "stopButton" );
}

void draw()
{
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
    float x, y, width, height;
    boolean active;
    
    LaTiDoButton ( float xx, float yy, float w, float h )
    {
        x = xx; y = yy; width = w; height = h;
        
        Interactive.add( this ); // register it with the manager
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
        
        rect(x, y, width, height);
    }
}