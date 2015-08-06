import javax.crypto.Cipher; //<>//
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.IOException;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;
import static javax.swing.JOptionPane.*;
import de.bezier.guido.*;
import controlP5.*;
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

Process pd;

ControlP5 gui;

LatidoButton reportProblem;
LatidoButton play, stop, pitch, replay;
HSlider tempo;
Label tempoLabel, userPrefsLabel;
MetroButton metro;
ShowMusic music;
Scorecard scorecard;
MelodyLibraryXML library;
LatidoButton libraryButton, next, previous, redo;
LatidoButton loadProgress, saveProgress;
UserProgress userProgress;
String libName;
String savePath;
boolean saving;
Splash splash;
ProgressGraph tree;
Label treeLabel;

void setup()
{
  String p = dataPath("");
  try {
    pd = new ProcessBuilder(p+"/pdbin/bin/pd", "-nogui", "-noprefs", "-r", "44100", p+"/pd/latido.pd").start();
  } 
  catch (Exception e) {
    showMessageDialog(null, "Can't open Pd Audio Engine", "Alert", ERROR_MESSAGE);
  }
  oscP5 = new OscP5 (this, 12000);
  latidoPD = new NetAddress("127.0.0.1", 12001);

  PImage icon = loadImage("icons/appbar.futurama.bender.png");

  size(1024, 540);
  smooth();
  PADDING = width/20;

  frame.setTitle("Latido 0.83a1");
  if (frame != null) {
    frame.setResizable(true);
  }
  frame.addComponentListener(new ComponentAdapter() {
    public void componentResized(ComponentEvent e) {
      if (e.getSource()==frame) {
        println("resized to:" + width+" x "+height+" mouse: "+mouseY +" "+mouseY);
      }
    }
  }
  );

  Interactive.make(this);
  gui = new ControlP5(this);

  music = new ShowMusic();

  PImage[] imgs = {
    loadImage("icons/appbar.control.play.png"), loadImage("icons/appbar.control.play.png"), loadImage("icons/appbar.control.play.png")
    };

    gui.addButton("playButton")
      .setLabel("Play")
        .setPosition(10, 10)
          .setSize(50, 50);

  gui.addButton("stopButton")
    .setLabel("Stop")
      .setPosition(70, 10)
        .setSize(50, 50);

  gui.addButton("pitchButton")
    .setLabel("Pitch")
      .setPosition(130, 10)
        .setSize(50, 50);

  gui.addButton("playbackButton")
    .setLabel("PlayBack")
      .setPosition(190, 10)
        .setSize(50, 50);

  gui.addButton("previousButton")
    .setLabel("Previous")
      .setPosition(350, 10)
        .setSize(50, 50);

  gui.addButton("redoButton")
    .setLabel("Redo")
      .setPosition(410, 10)
        .setSize(50, 50);

  gui.addButton("nextButton")
    .setLabel("Next")
      .setPosition(470, 10)
        .setSize(50, 50);

  //gui.getController("playButton").lock();


  //libraryButton.visibility(false); // just for now, until this is ready for prime time
  play = new LatidoButton (10, 110, 50, 50, "Play", "icons/appbar.control.play.png", 0);
  stop = new LatidoButton (70, 110, 50, 50, "Stop", "icons/appbar.control.stop.png", 1);
  pitch = new LatidoButton (130, 110, 50, 50, "Pitch", "icons/tuningfork1.png", 2);
  replay = new LatidoButton (190, 110, 50, 50, "Playback", "icons/appbar.social.uservoice.png", 3);
  play.visibility(false);
  stop.visibility(false);
  pitch.visibility(false);
  replay.visibility(false);

  previous = new LatidoButton (350, 110, 50, 50, "Previous", "icons/left-arrow.png", 0);
  redo = new LatidoButton (410, 110, 50, 50, "Redo", "icons/redo.png", 2);
  next = new LatidoButton (470, 110, 50, 50, "Next", "icons/right-arrow.png", 0);

  previous.visibility(false);
  redo.visibility(false);
  next.visibility(false);

  reportProblem = new LatidoButton (10, height-55, 50, 45, "Bug?", "icons/ladybug.png", 0);
  libraryButton = new LatidoButton (width-60, height-60, 50, 50, "Load...", "icons/playback.png", 0);
  previous.active = false;
  redo.active = false;
  userPrefsLabel = new Label((SIDEBAR_WIDTH+width)*0.555, 32, "   User\nProgress", 12);
  loadProgress = new LatidoButton ((SIDEBAR_WIDTH+width)*0.55+70, 10, 50, 50, "Load", null, 0);
  saveProgress = new LatidoButton ((SIDEBAR_WIDTH+width)*0.55+130, 10, 50, 50, "Save as", null, 1);
  replay.active = false;
  play.active = false;
  pitch.active = false;
  stop.active = false;
  next.active = false;
  loadProgress.active = false;
  saveProgress.active = false;
  //volume = new VolSlider (10, height-265, 20, 200);
  //volume.set (0.25);
  //tempo = new HSlider (width-210, 10, 200, 20);
  //tempoLabel = new Label (width-210, 50, "Tempo", 14);

  gui.addSlider("tempoSlider")
    .setLabel("Tempo")
      .setPosition(width-210, 10)
        .setSize(200, 20)
          .setRange(40, 280)
            .setValue(40)
              .setDecimalPrecision(0)
              .getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
              .setColor(color(0));


  gui.addSlider("volumeSlider")
    .setLabel("vol")
      .setPosition(10, height-265)
        .setSize(20, 200)
          .setRange(0, 100)
            .setValue(25)
              .setLabelVisible(false);

  gui.addSlider("micLevel")
    .setPosition(40, height-265)
      .setSize(20, 200)
        .setRange(0, 100)
          .setLabelVisible(false)
            ;

  Interactive.on( loadProgress, "pressed", this, "userPrefs" );
  Interactive.on( saveProgress, "pressed", this, "userPrefs" );
  Interactive.on( tempo, "valueChanged", this, "tempoSlider");
  Interactive.on( libraryButton, "pressed", this, "libraryButton");
  Interactive.on( reportProblem, "pressed", this, "websiteLink");

  library = new MelodyLibraryXML();
  libName = library.load("eyes_and_ears");
  music.load(library.getImage());
  music.setText(library.getText());
  gui.getController("tempoSlider").setValue((int)library.getTempo());
  //tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
  //tempoLabel.set(library.getTempo()+" bpm");
  metro = new MetroButton( SIDEBAR_WIDTH+(width-SIDEBAR_WIDTH)/2-250, height-110, 500, 100, 2);
  scorecard = new Scorecard (SIDEBAR_WIDTH + 2*PADDING, TOPBAR_HEIGHT+PADDING, width-SIDEBAR_WIDTH-4*PADDING, height-TOPBAR_HEIGHT-4*PADDING);

  userProgress = new UserProgress(System.getProperty("user.name"), libName);
  userProgress.updateInfo(library.currentLine, library.getName());
  savePath = "";
  saving = false;

  tree = new ProgressGraph(0, 80, 70, 81);
  treeLabel = new Label(5, 170, "0 Stars", 11);
  splash = new Splash();
  tree.setMaxScore(library.numMelodies*5);

  oscP5.plug(this, "micPD", "/mic");
  oscP5.plug(this, "tempoPD", "/tempo");
  oscP5.plug(this, "metroPD", "/metro");
  oscP5.plug(this, "metroStatePD", "/metrostate");
  oscP5.plug(this, "scorePD", "/score");
  oscP5.plug(this, "watchdogPD", "/watchdog");
}

void stop()
{
  pd.destroy();
  OscMessage myMessage = new OscMessage("/latido/quit");
  myMessage.add(1);
  oscP5.send(myMessage, latidoPD);
}

