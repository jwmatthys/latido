import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;

void setup()
{
  PImage icon = loadImage("myicon.gif");
 
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
}

void draw()
{
  background(255);
  ellipse(width/2, height/2, 50, 50);
}

void keyPressed()
{
  exit();
}