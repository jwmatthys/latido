import javax.crypto.Cipher; //<>//
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.io.File;
import java.io.IOException;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.Image;
import javax.swing.JOptionPane;
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

OscP5 oscP5;
NetAddress latidoPD;

Process pd;
PFont font;
PFont biggerFont;

ControlP5 gui;

MusicDisplay music;
CalculateScore score;
MelodyModuleXML module;
UserProgress userProgress;
String libName;
String savePath;
boolean saving;
Group scorecardGroup;
Group optionGroup;
Group progressGroup;
CheckBox metro;
ScrollableList exerciseList;
Slider progressSlider;
Textarea textbox;
Canvas starCanvas;
boolean view;

void setup()
{
  PImage icon = loadImage("icons/thumbsdown.png");
  frame.setIconImage((Image) icon.getNative());

  font = loadFont("Inconsolata-18.vlw");
  biggerFont = loadFont("Inconsolata-72.vlw");
  String p = dataPath("");
  try {
    String os = System.getProperty("os.name");
    if (match(os, "Windows") != null)
    {
      pd = new ProcessBuilder(p+"/pdbin/pd-win/pd.exe", "-nogui", "-noprefs", "-inchannels", "2", "-outchannels", "2", "-r", "44100", p+"/pd/latido.pd").start();
    } else if (match(os, "Linux") != null)
    {
      if (match(System.getProperty("os.arch"), "amd") != null)
        pd = new ProcessBuilder(p+"/pdbin/pd-linux64", "-nogui", "-noprefs", "-alsa", "-inchannels", "2", "-outchannels", "2", "-r", "44100", p+"/pd/latido.pd").start();
      else
        pd = new ProcessBuilder(p+"/pdbin/pd-linux32", "-nogui", "-noprefs", "-alsa", "-inchannels", "2", "-outchannels", "2", "-r", "44100", p+"/pd/latido.pd").start();
    } else //assume OSX (for now)
    {
      pd = new ProcessBuilder(p+"/pdbin/pd-osx", "-nogui", "-noprefs", "-pa", "-inchannels", "2", "-outchannels", "2", "-r", "44100", p+"/pd/latido.pd").start();
    }
  } 
  catch (Exception e) {
    JOptionPane.showMessageDialog(null, "Can't open Pd Audio Engine", "Alert", JOptionPane.ERROR_MESSAGE);
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


  score = new CalculateScore();
  userProgress = new UserProgress(System.getProperty("user.name"), libName);
  userProgress.updateInfo(module.currentLine, module.getName());
  savePath = "";
  saving = false;

  gui = new ControlP5(this);
  createGui();
  for (int i=0; i<module.numMelodies; i++) {
    module.loadSpecific(i);
    exerciseList.addItem(module.getName(), i);
    //lbi.setColorBackground(0xffff0000);
  }
  module.loadSpecific(0);
  music.load(module.getImage());
  setText(module.getText());
  gui.getController("tempoSlider").setValue(module.getTempo());
  notifyPd(module.rhythm);
  userProgress.updateInfo(module.currentLine, module.getName());
  progressSlider.setRange(0, module.numMelodies * 5);

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
  surface.setTitle("Latido 0.9-beta");
  if (surface != null) {
    surface.setResizable(true);
  }
}