import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;
import de.bezier.guido.*;
import oscP5.*;
import netP5.*;

final float SIDEBAR_WIDTH = 70;
final float TOPBAR_HEIGHT = 70;
int PADDING;
final int TEMPO_LOW = 40;
final int TEMPO_HIGH = 280;
int tempoVal = 60;

OscP5 oscP5tcpClient;
OscP5 oscP5;
NetAddress latidoPD;

LatidoButton play, stop, pitch, replay;
MicLevel micLevel;
VolSlider volume;
HSlider tempo;
Label tempoLabel;
MetroButton metro;
ShowMusic music;
Scorecard scorecard;
MelodyLibrary library;
LatidoButton libraryButton, next, previous, redo;
LatidoButton goButton;
boolean showSplash = true;

void setup()
{
  oscP5tcpClient = new OscP5(this, "127.0.0.1", 11000, OscP5.TCP);
  oscP5 = new OscP5 (this, 12000);
  latidoPD = new NetAddress("127.0.0.1", 12001);
  oscP5.plug(this, "micPD", "/mic");
  oscP5.plug(this, "tempoPD", "/tempo");
  oscP5.plug(this, "metroPD", "/metro");
  oscP5.plug(this, "metroStatePD", "/metrostate");
  oscP5.plug(this, "scorePD", "/score");

  PImage icon = loadImage("appbar.futurama.bender.png");

  size(1024, 500);
  smooth();
  PADDING = width/20;

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
  music = new ShowMusic();
  libraryButton = new LatidoButton (10, height-60, 50, 50, "Load...", "playback.png", 0);
  play = new LatidoButton (10, 10, 50, 50, "Play", "appbar.control.play.png", 0);
  stop = new LatidoButton (70, 10, 50, 50, "Stop", "appbar.control.stop.png", 1);
  pitch = new LatidoButton (130, 10, 50, 50, "Pitch", "tuningfork1.png", 2);
  replay = new LatidoButton (190, 10, 50, 50, "Playback", "appbar.social.uservoice.png", 3);
  replay.active = false;
  play.active = false;
  pitch.active = false;
  stop.active = false;
  volume = new VolSlider (10, 70, 20, 200);
  volume.set (0.25);
  micLevel = new MicLevel (40, 70, 20, 200);
  tempo = new HSlider (width-210, 10, 200, 20);
  tempoLabel = new Label (width-210, 50, "Tempo");
  Interactive.on( play, "pressed", this, "transportButton" );
  Interactive.on( stop, "pressed", this, "transportButton" );
  Interactive.on( pitch, "pressed", this, "transportButton" );
  Interactive.on( replay, "pressed", this, "transportButton" );
  Interactive.on( volume, "valueChanged", this, "volumeSlider");
  Interactive.on( tempo, "valueChanged", this, "tempoSlider");

  library = new MelodyLibrary();
  boolean loaded = library.load("eyes_and_ears");

  music.load(library.getImage());
  music.showBirdie = true;
  music.setText(library.getText());
  tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
  tempoLabel.set(library.getTempo()+" bpm");
  notifyPd();
  goButton = new LatidoButton ((SIDEBAR_WIDTH+width)*0.55,height-100, 60, 60, "Go!", "warning.png", 0);
  metro = new MetroButton( SIDEBAR_WIDTH+(width-SIDEBAR_WIDTH)/2-250, height-150, 500, 100, 2);
  scorecard = new Scorecard (SIDEBAR_WIDTH + 2*PADDING, TOPBAR_HEIGHT+PADDING, width-SIDEBAR_WIDTH-4*PADDING, height-TOPBAR_HEIGHT-2*PADDING);
  float buttonXpos = (width+SIDEBAR_WIDTH)/2 - 100 - 40;
  float buttonYpos = height-TOPBAR_HEIGHT-PADDING - 40;
  previous = new LatidoButton (buttonXpos, buttonYpos, 80, 80, "Previous", "left-arrow.png", 1);
  redo = new LatidoButton (buttonXpos + 100, buttonYpos, 80, 80, "Redo", "redo.png", 2);
  next = new LatidoButton (buttonXpos + 200, buttonYpos, 80, 80, "Next", "right-arrow.png", 3);
  previous.visibility(false);
  redo.visibility(false);
  next.visibility(false);
  Interactive.on( goButton, "pressed", this, "goButtonPressed");
  Interactive.on( libraryButton, "pressed", this, "libraryButton");
  Interactive.on( previous, "pressed", this, "libraryButton");
  Interactive.on( redo, "pressed", this, "libraryButton");
  Interactive.on( next, "pressed", this, "libraryButton");
}

void draw()
{
  background(255);
  paintSidebar();
}

void paintSidebar()
{
  fill(#E5E6E8);
  noStroke();
  rect(0, 0, SIDEBAR_WIDTH, height);
  rect(70, 0, width, TOPBAR_HEIGHT);
}

void notifyPd()
{
  OscMessage myMessage = new OscMessage("/latido/tempo");
  myMessage.add(library.getTempo());
  oscP5.send(myMessage, latidoPD);
  myMessage = new OscMessage("/latido/countin");
  myMessage.add(library.getCountin());
  oscP5.send(myMessage, latidoPD);
  myMessage = new OscMessage("/latido/midifile");
  myMessage.add(library.getMidi());
  oscP5.send(myMessage, latidoPD);
}