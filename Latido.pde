import javax.crypto.Cipher; //<>//
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.IOException;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;
import static javax.swing.JOptionPane.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

final boolean SHOW_MUSIC = true;
final boolean SHOW_TEXT = false;
final int SIDEBAR_WIDTH = 70;
final int TOPBAR_HEIGHT = 70;
int PADDING;
final int TEMPO_LOW = 40;
final int TEMPO_HIGH = 280;
int tempoVal = 60;
int metroOff = 0; // updates frame to deactivate metro toggle
boolean practiceMode = false;

public int HACK_STARS = 0;

OscP5 oscP5tcpClient;
OscP5 oscP5;
NetAddress latidoPD;

Process pd;
PFont font;
PFont biggerFont;

ControlP5 gui;
Group group;
CheckBox metro;

MusicDisplay music;
CalculateScore score;
MelodyModuleXML module;
UserProgress userProgress;
String libName;
String savePath;
boolean saving;
Group scorecardGroup;
Group splashGroup;
Group optionGroup;
Group progressGroup;
Slider progressSlider;
Textarea textbox;
Canvas starCanvas;
boolean view;

void setup()
{
  font = loadFont("Inconsolata-18.vlw");
  String p = dataPath("");
  try {
    pd = new ProcessBuilder(p+"/pdbin/bin/pd", "-nogui", "-noprefs", "-r", "44100", p+"/pd/latido.pd").start();
  } 
  catch (Exception e) {
    showMessageDialog(null, "Can't open Pd Audio Engine", "Alert", ERROR_MESSAGE);
  }
  oscP5 = new OscP5 (this, 12000);
  latidoPD = new NetAddress("127.0.0.1", 12001);

  size(1024, 560);
  setupFrame();
  smooth();
  PADDING = width/20;

  module = new MelodyModuleXML();
  music = new MusicDisplay();
  libName = module.load(new File(dataPath("eyes_and_ears/latido.xml")));
  music.load(module.getImage());

  score = new CalculateScore();
  userProgress = new UserProgress(System.getProperty("user.name"), libName);
  userProgress.updateInfo(module.currentLine, module.getName());
  savePath = "";
  saving = false;

  gui = new ControlP5(this);
  createGui();
  view = SHOW_MUSIC;
  setText(module.getText());

  //stars = new Stars(HACK_STARS, SIDEBAR_WIDTH, (width+SIDEBAR_WIDTH)/2, TOPBAR_HEIGHT+100, 20, 500);

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

void setupFrame()
{
  frame.setTitle("Latido 0.9-alpha");
  if (frame != null) {
    frame.setResizable(true);
  }
  frame.addComponentListener(new ComponentAdapter() {
    public void componentResized(ComponentEvent e) {
      if (e.getSource()==frame) {
        //gui.getController("options").setPosition(width-230, 20);
        //gui.getController("websiteLink").setPosition(width-80, height-30);
        //println("resized to:" + width+" x "+height+" mouse: "+mouseY +" "+mouseY);
      }
    }
  }
  );
}

