import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;
import de.bezier.guido.*;
import oscP5.*;
import netP5.*;

final float SIDEBAR_WIDTH = 70;
final float TOPBAR_HEIGHT = 60;
final int TEMPO_LOW = 40;
final int TEMPO_HIGH = 280;
int tempoVal = 60;

OscP5 oscP5tcpClient;
OscP5 oscP5;
NetAddress latidoPD;

LaTiDoButton play, stop, pitch, replay;
MicLevel micLevel;
VolSlider volume;
HSlider tempo;
Label tempoLabel;

void setup()
{
  //oscP5tcpClient = new OscP5(this, "127.0.0.1", 11000, OscP5.TCP);
  oscP5 = new OscP5 (this, 12000);
  latidoPD = new NetAddress("127.0.0.1", 12001);
  oscP5.plug(this,"micPD","/mic");
  oscP5.plug(this,"tempoPD","/tempo");
  
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
  play = new LaTiDoButton (10, 10, 50, 50, "Play", "appbar.control.play.png", 0);
  stop = new LaTiDoButton (10, 70, 50, 50, "Stop", "appbar.control.stop.png", 1);
  pitch = new LaTiDoButton (10, 130, 50, 50, "Pitch", "tuningfork1.png", 2);
  replay = new LaTiDoButton (10, 190, 50, 50, "Playback", "appbar.social.uservoice.png", 3);
  volume = new VolSlider (10, height-210, 20, 200);
  volume.set (0.25);
  micLevel = new MicLevel (40, height-210, 20, 200);
  tempo = new HSlider (width-210, 10, 200, 20);
  tempoLabel = new Label (width-210, 50, "Tempo");
  Interactive.on( play, "pressed", this, "transportButton" );
  Interactive.on( stop, "pressed", this, "transportButton" );
  Interactive.on( pitch, "pressed", this, "transportButton" );
  Interactive.on( replay, "pressed", this, "transportButton" );
  Interactive.on( volume, "valueChanged", this, "volumeSlider");
  Interactive.on( tempo, "valueChanged", this, "tempoSlider");
}

void draw()
{
  background(255);
  paintSidebar();
  micLevel.draw();
  tempoLabel.draw();
}

void paintSidebar()
{
  fill(150);
  noStroke();
  rect(0, 0, SIDEBAR_WIDTH, height);
  rect(70,0, width, TOPBAR_HEIGHT);
}