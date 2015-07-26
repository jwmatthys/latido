import de.bezier.guido.*;

LaTiDoButton play, stop;

void setup()
{
  size(800,600);
  
  Interactive.make(this);
  play = new LaTiDoButton (10,10,50,50);
  stop = new LaTiDoButton (10,70,50,50);
  
}

void draw()
{
}

public class LaTiDoButton
{
    float x, y, width, height;
    boolean on;
    
    LaTiDoButton ( float xx, float yy, float w, float h )
    {
        x = xx; y = yy; width = w; height = h;
        
        Interactive.add( this ); // register it with the manager
    }
    
    // called by manager
    
    void mousePressed () 
    {
        on = !on;
    }

    void draw () 
    {
        if ( on ) fill( 200 );
        else fill( 100 );
        
        rect(x, y, width, height);
    }
}