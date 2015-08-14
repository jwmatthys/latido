import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.crypto.Cipher; 
import javax.crypto.SecretKey; 
import javax.crypto.spec.SecretKeySpec; 
import java.io.File; 
import java.io.IOException; 
import java.awt.event.ComponentAdapter; 
import java.awt.event.ComponentEvent; 
import java.awt.Image; 
import static javax.swing.JOptionPane.*; 
import de.bezier.guido.*; 
import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Latido extends PApplet {

 //<>//












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

LatidoButton reportProblem;
LatidoButton play, stop, pitch, replay;
MicLevel micLevel;
VolSlider volume;
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

public void setup()
{
  String p = dataPath("");
  try {
    pd = new ProcessBuilder(p+"/pdbin/bin/pd", "-nogui", "-alsa", "-r", "44100", p+"/pd/latido.pd").start();
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

  surface.setTitle("Latido 0.82a1");
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
  reportProblem = new LatidoButton (10, height-55, 50, 45, "Bug?", "icons/ladybug.png", 0);
  libraryButton = new LatidoButton (width-60, height-60, 50, 50, "Load...", "icons/playback.png", 0);
  //libraryButton.visibility(false); // just for now, until this is ready for prime time
  play = new LatidoButton (10, 10, 50, 50, "Play", "icons/appbar.control.play.png", 0);
  stop = new LatidoButton (70, 10, 50, 50, "Stop", "icons/appbar.control.stop.png", 1);
  pitch = new LatidoButton (130, 10, 50, 50, "Pitch", "icons/tuningfork1.png", 2);
  replay = new LatidoButton (190, 10, 50, 50, "Playback", "icons/appbar.social.uservoice.png", 3);
  previous = new LatidoButton (350, 10, 50, 50, "Previous", "icons/left-arrow.png", 0);
  redo = new LatidoButton (410, 10, 50, 50, "Redo", "icons/redo.png", 2);
  next = new LatidoButton (470, 10, 50, 50, "Next", "icons/right-arrow.png", 0);
  previous.active = false;
  redo.active = false;
  userPrefsLabel = new Label((SIDEBAR_WIDTH+width)*0.555f, 32, "   User\nProgress", 12);
  loadProgress = new LatidoButton ((SIDEBAR_WIDTH+width)*0.55f+70, 10, 50, 50, "Load", null, 0);
  saveProgress = new LatidoButton ((SIDEBAR_WIDTH+width)*0.55f+130, 10, 50, 50, "Save as", null, 1);
  replay.active = false;
  play.active = false;
  pitch.active = false;
  stop.active = false;
  next.active = false;
  loadProgress.active = false;
  saveProgress.active = false;
  volume = new VolSlider (10, height-265, 20, 200);
  volume.set (0.25f);
  micLevel = new MicLevel (40, height-265, 20, 200);
  tempo = new HSlider (width-210, 10, 200, 20);
  tempoLabel = new Label (width-210, 50, "Tempo", 14);

  Interactive.on( play, "pressed", this, "transportButton" );
  Interactive.on( stop, "pressed", this, "transportButton" );
  Interactive.on( pitch, "pressed", this, "transportButton" );
  Interactive.on( replay, "pressed", this, "transportButton" );
  Interactive.on( loadProgress, "pressed", this, "userPrefs" );
  Interactive.on( saveProgress, "pressed", this, "userPrefs" );
  Interactive.on( volume, "valueChanged", this, "volumeSlider");
  Interactive.on( tempo, "valueChanged", this, "tempoSlider");
  Interactive.on( next, "pressed", this, "nextButton");
  Interactive.on( previous, "pressed", this, "prevButton");
  Interactive.on( libraryButton, "pressed", this, "libraryButton");
  Interactive.on( redo, "pressed", this, "libraryButton");
  Interactive.on( reportProblem, "pressed", this, "websiteLink");

  library = new MelodyLibraryXML();
  libName = library.load("eyes_and_ears");
  music.load(library.getImage());
  music.setText(library.getText());
  tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
  tempoLabel.set(library.getTempo()+" bpm");
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

public void stop()
{
  pd.destroy();
    OscMessage myMessage = new OscMessage("/latido/quit");
  myMessage.add(1);
  oscP5.send(myMessage, latidoPD);
}
public void draw()
{
  background(255);
  paintSidebar();
}

public void paintSidebar()
{
  fill(0xffE5E6E8);
  noStroke();
  rect(0, 0, SIDEBAR_WIDTH, height);
  rect(70, 0, width, TOPBAR_HEIGHT);
}

public void notifyPd(boolean rhythm)
{
  OscMessage myMessage = new OscMessage("/latido/isrhythm");
  myMessage.add(library.rhythm ? 1 : 0);
  oscP5.send(myMessage, latidoPD);
  myMessage = new OscMessage("/latido/tempo");
  myMessage.add(library.getTempo());
  oscP5.send(myMessage, latidoPD);
  myMessage = new OscMessage("/latido/countin");
  myMessage.add(library.getCountin());
  oscP5.send(myMessage, latidoPD);
  myMessage = new OscMessage("/latido/midifile");
  myMessage.add(library.getMidi());
  oscP5.send(myMessage, latidoPD);
}
public void keyPressed()
{
  OscMessage myMessage = new OscMessage("/rhy");
  myMessage.add(library.rhythm ? 1 : 0);
  oscP5.send(myMessage, latidoPD);
}

public void mousePressed()
{
  if (splash.active)
  {
    libraryButton.visibility(false);
    splash.active = false;
    music.showBirdie = true;
    next.active = true;
    loadProgress.active = true;
    saveProgress.active = true;
    notifyPd(library.rhythm);
  }
}

public void nextButton (int v)
{
  previous.active = true;
  scorecard.active = false;
  redo.active = false;
  if (music.showBirdie)
  {
    music.showBirdie = false;
    play.active = true;
    stop.active = false;
    pitch.active = !library.rhythm;
    replay.active = false;
    libraryButton.visibility(false);
    next.active = (userProgress.getCurrentStars(library.currentLine)>3);
  } else
  {
    music.showBirdie = true;
    replay.active = false;

    library.loadNext();
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
    tempoLabel.set(library.getTempo()+" bpm");
    notifyPd(library.rhythm);
    userProgress.updateInfo(library.currentLine, library.getName());
    next.active = true;
  }
}

public void prevButton (int v)
{
  if (music.showBirdie || scorecard.active)
  {
    scorecard.active = false;
    music.showBirdie = true;
    replay.active = false;

    library.loadPrevious();
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
    tempoLabel.set(library.getTempo()+" bpm");
    notifyPd(library.rhythm);
    userProgress.updateInfo(library.currentLine, library.getName());
    next.active = (userProgress.getCurrentStars(library.currentLine)>3);
  } else
  {
    music.showBirdie = true;
    play.active = false;
    stop.active = false;
    pitch.active = !library.rhythm;
    scorecard.active = false;
    next.active = true;
  }
  if (music.showBirdie && library.currentLine==0) previous.active = false;
}

public void transportButton (int v)
{
  OscMessage myMessage = new OscMessage("/latido/transport");
  switch (v)
  {
  case 0:
    myMessage.add("play");
    stop.active = true;
    scorecard.active = false;
    break;
  case 1:
    myMessage.add("stop");
    break;
  case 2:
    myMessage.add("pitch");
    break;
  case 3:
    myMessage.add("replay");
    stop.active = true;
  }
  oscP5.send(myMessage, latidoPD);
}

public void libraryButton (int v)
{
  if (v==0)
  {
    selectFolder("Choose your latido library folder...", "folderCallback");
  } else
  {
    if (v==2) //redo
    {
      scorecard.active = false;
      music.showBirdie = false;
      play.active = true;
      stop.active = false;
      pitch.active = !library.rhythm;
      replay.active = false;
      libraryButton.visibility(false);
    } else
    {
      scorecard.active = false;
      music.showBirdie = true;
      replay.active = false;

      library.loadPrevious();
      music.load(library.getImage());
      music.showBirdie = true;
      music.setText(library.getText());
      tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
      tempoLabel.set(library.getTempo()+" bpm");
      notifyPd(library.rhythm);
      userProgress.updateInfo(library.currentLine, library.getName());
    }
  }
}

public void userPrefs (int v)
{
  if (v == 0)
  {
    selectInput("Choose your Latido user progress file...", "loadCallback");
  } else
  {
    selectOutput("Choose where to save your Latido user progress file...", "saveCallback");
  }
}

public void volumeSlider (float v)
{
  OscMessage myMessage = new OscMessage("/latido/vol");
  myMessage.add(v);
  oscP5.send(myMessage, latidoPD);
}

public void tempoSlider (float v)
{
  tempoVal = (int)map (v, 0, 1, TEMPO_LOW, TEMPO_HIGH);
  String l = tempoVal + " bpm";
  tempoLabel.set (l);
  OscMessage myMessage = new OscMessage("/latido/tempo");
  myMessage.add(tempoVal);
  oscP5.send(myMessage, latidoPD);
}

public void micPD (float f)
{
  micLevel.set(sqrt(f*0.01f));
}

public void tempoPD (float f)
{
  int t = PApplet.parseInt(f);
  tempoLabel.set(t+" BPM");
  tempo.set(map(t, TEMPO_LOW, TEMPO_HIGH, 0, 1));
}

public void metroPD (float f)
{
  int b = PApplet.parseInt(f);
  metro.bang(b);
}

public void metroStatePD (float f)
{
  int s = PApplet.parseInt(f);
  metro.setState(s);
}

public void watchdogPD ()
{
  OscMessage myMessage = new OscMessage("/latido/watchdog");
  oscP5.send(myMessage, latidoPD);
}

public void scorePD (float theScore)
{
  play.active = false;
  stop.active = false;
  pitch.active = false;
  replay.active = true;
  scorecard.setScore(theScore);
  redo.active = true;
  if (theScore >= 0.7f || userProgress.getCurrentStars(library.currentLine)>3)
  {
    next.active = true;
  }
  userProgress.updateScore(library.currentLine, scorecard.stars);
  tree.updateGraph(userProgress.getTotalScore());
  treeLabel.set(userProgress.getTotalScore()+" Stars");
  if (saving) userProgress.save(savePath);
}

public void folderCallback(File f)
{
  try
  {
    String s = f.getAbsolutePath();
    String libName = library.load(s);
    userProgress = new UserProgress(System.getProperty("user.name"), libName);
    userProgress.updateInfo(library.currentLine, library.getName());
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
    tempoLabel.set(library.getTempo()+" bpm");
    tree.setMaxScore(library.numMelodies*5);
    notifyPd(library.rhythm);
  }
  catch (Exception e)
  {
    showMessageDialog(null, "Could not load Latido library", "Alert", ERROR_MESSAGE);
  }
}

public void loadCallback(File f)
{
  String s = f.getAbsolutePath();
  if (userProgress.load(s))
  {
    savePath = s;
    saving = true;
    scorecard.active = false;
    music.showBirdie = true;
    replay.active = false;

    library.loadSpecific(userProgress.nextUnpassed);
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
    tempoLabel.set(library.getTempo()+" bpm");
    notifyPd(library.rhythm);
    userProgress.updateInfo(library.currentLine, library.getName());
    tree.updateGraph(userProgress.getTotalScore());
    treeLabel.set(userProgress.getTotalScore()+" Stars");
    next.active = true;
    if (library.currentLine>0) previous.active = true;
  }
}

public void saveCallback(File f)
{
  String s = f.getAbsolutePath();
  userProgress.save(s);
  savePath = s;
  saving = true;
}

public void websiteLink (int v)
{
  link("http://joel.matthysmusic.com/contact/");
}
class MelodyLibraryXML
{
  String indexPath, midiPath, imagePath, textPath, filename;
  XML indexFile, shortname, image, midi, progress;
  XML[] exercises;
  int tempo;
  float countin;
  boolean rhythm;
  int numMelodies;
  int currentLine;

  MelodyLibraryXML ()
  {
  }

  public String load (String path)
  {
    try 
    {
      indexFile = loadXML(dataPath(path)+"/latido.xml");
      shortname = indexFile.getChild("shortname");
      image = indexFile.getChild("imageextension");
      midi = indexFile.getChild("midiextension");
      progress = indexFile.getChild("progress");
      exercises = progress.getChildren("exercise");
      indexPath = dataPath(path)+"/latido.xml";
      midiPath = dataPath(path)+"/midi/";
      imagePath = dataPath(path)+"/image/";
      textPath = dataPath(path)+"/text/";
      currentLine = 0;
      numMelodies = exercises.length;
      parse (0);
      return shortname.getContent();
    } 
    catch (Exception e)
    {
      showMessageDialog(null, "Could not load Latido library", "Alert", ERROR_MESSAGE);
      return "";
    }
  }

  public void parse (int line)
  {
    try
    {
      filename = exercises[line].getString("name");
      tempo = exercises[line].getInt("tempo");
      countin = exercises[line].getFloat("countin");
      rhythm = exercises[line].hasAttribute("rhythm");
    }
    catch (Exception e)
    {
      showMessageDialog(null, "Could not parse Latido library", "Alert", ERROR_MESSAGE);
    }
  }

  public void loadNext()
  {
    currentLine++;
    if (currentLine >= exercises.length) currentLine--;
    parse(currentLine);
  }

  public void loadPrevious()
  {
    currentLine--;
    if (currentLine < 0) currentLine++;
    parse(currentLine);
  }

  public void loadSpecific(int i)
  {
    if (i < exercises.length)
    {
      currentLine = i;
      parse(currentLine);
    }
  }

  public String getMidi ()
  {
    return midiPath+filename+"."+midi.getContent();
  }

  public String getImage ()
  {
    return imagePath+filename+"."+image.getContent();
  }

  public String getText ()
  {
    return textPath+filename+".txt";
  }

  public String getName ()
  {
    return filename;
  }
  public int getTempo ()
  {
    return tempo;
  }

  public float getCountin ()
  {
    return countin;
  }
}

class MelodyLibrary
{
  String[] lines;
  String indexPath, midiPath, imagePath, textPath;
  String midiExt, imageExt; // file extensions contained in second line of latido.txt
  String filename;
  int tempo;
  float countin;
  int currentLine;
  boolean rhythm;
  int numMelodies;
  final int lineOffset = 3;

  MelodyLibrary ()
  {
  }

  public String load (String path)
  {
    try 
    {
      indexPath = dataPath(path)+"/latido.txt";
      midiPath = dataPath(path)+"/midi/";
      imagePath = dataPath(path)+"/image/";
      textPath = dataPath(path)+"/text/";
      lines = loadStrings(indexPath);
      String[] extensions = split(lines[1], ' ');
      imageExt = extensions[0];
      midiExt = extensions[1];
      currentLine = 0;
      numMelodies = lines.length - lineOffset;
      parse (0);
      return lines[0];
    } 
    catch (Exception e)
    {
      showMessageDialog(null, "Could not load Latido library", "Alert", ERROR_MESSAGE);
      return "";
    }
  }

  public void parse (int line)
  {
    String[] current = split(lines[line], ' ');
    filename = current[0];
    tempo = PApplet.parseInt(current[1]);
    countin = PApplet.parseFloat(current[2]);
    rhythm = (current.length > 3);
  }

  public void loadNext()
  {
    currentLine++;
    if (currentLine >= lines.length - lineOffset) currentLine--;
    parse(currentLine);
  }

  public void loadPrevious()
  {
    currentLine--;
    if (currentLine < 0) currentLine++;
    parse(currentLine);
  }

  public void loadSpecific(int i)
  {
    if (i < lines.length - lineOffset)
    {
      currentLine = i;
      parse(currentLine);
    }
  }

  public String getMidi ()
  {
    return midiPath+filename+"."+midiExt;
  }

  public String getImage ()
  {
    return imagePath+filename+"."+imageExt;
  }

  public String getText ()
  {
    return textPath+filename+".txt";
  }

  public String getName ()
  {
    return filename;
  }
  public int getTempo ()
  {
    return tempo;
  }

  public float getCountin ()
  {
    return countin;
  }
}
public class LatidoButton
{
  float x, y, width, height;
  float textx, texty;
  int value;
  int state;
  PImage img;
  String label;
  PFont font;
  boolean active;
  boolean visible;

  LatidoButton ( float x, float y, float w, float h, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    active = true;
    visible = true;
  }

  LatidoButton ( float x, float y, float w, float h, String i, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    active = true;
    visible = true;
    img = loadImage(i);
  }

  LatidoButton ( float x, float y, float w, float h, String l, String i, int v)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = v;
    state = 0;
    if (i != null) img = loadImage(i);
    label = l;
    font = createFont("Droid Sans", 12, true);
    textFont(font);
    textSize(12);
    textx = x + (width - textWidth(label))/2;
    texty = y + height - textDescent();
    active = true;
    visible = true;
  }

  public void mousePressed () 
  {
    if (active)
    {
      fill(255);
      rect(x, y, width, height);
      Interactive.send( this, "pressed", value );
      state = 2;
    }
  }

  public void visibility (boolean b)
  {
    if (b) visible = true;
    else {
      visible = false;
      active = false;
    }
  }

  public void mouseReleased()
  {
    if (active)
    {
      state = 1;
    }
  }

  public void mouseEntered ()
  {
    if (active)
    {
      state = 1;
    }
  }

  public void mouseExited ()
  {
    if (active)
    {
      state = 0;
    }
  }

  public void draw () 
  {
    if (visible)
    {
      switch (state)
      {
      case 2:
        fill ( 0xffAED288 );
        break;
      case 1:
        fill( 0xff00ADEF );
        break;
      default:
        fill( 0xffF3DB7B );
      }
      if (!active) fill (200);
      stroke (0);
      rect(x, y, width, height, 3);
      if (font != null)
      {
        if (img != null) image(img, x+width*0.125f, y, width*0.75f, height*0.75f);
        textFont(font);
        textSize(12);
        noStroke();
        fill(0);
        text(label, textx, texty);
      } else if (img != null) image(img, x, y, width, height);
    }
  }
}

public class HSlider
{
  float x, y, width, height;
  float valueX = 0, value;
  boolean on;

  HSlider ( float x, float y, float w, float h ) 
  {
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;

    valueX = x;

    Interactive.add( this );
  }

  public void mouseEntered ()
  {
    on = true;
  }

  public void mouseExited ()
  {
    on = false;
  }

  public void mouseDragged ( float mx, float my )
  {
    valueX = mx - height/2;

    if ( valueX < x ) valueX = x;
    if ( valueX > x+width-height ) valueX = x+width-height;

    float oldval = value;
    value = map( valueX, x, x+width-height, 0, 1 );

    if (value != oldval)
    {
      Interactive.send( this, "valueChanged", value );
    }
  }

  public void set (float v)
  {
    value = v;
    valueX = map(v, 0, 1, x, x+width-height);
  }

  public void draw ()
  {
    noStroke();

    fill( 10 );
    rect( x, y, width, height );

    fill( on ? 255 : 120 );
    rect( valueX, y, height, height );
  }
}

public class VSlider
{
  float x, y, width, height;
  float valueY = 0, value;
  boolean on;

  VSlider ( float x, float y, float w, float h ) 
  {
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;

    valueY = this.y+height-width;

    Interactive.add( this );
  }

  public void mouseEntered ()
  {
    on = true;
  }

  public void mouseExited ()
  {
    on = false;
  }

  public void mouseDragged ( float mx, float my )
  {
    valueY = my - width/2;

    if ( valueY < y ) valueY = y;
    if ( valueY > y+height-width ) valueY = y+height-width;

    float oldval = value;
    value = map( valueY, y, y+height-width, 0, 1 );
    if (value != oldval)
    {
      Interactive.send( this, "valueChanged", value );
    }
  }

  public void draw ()
  {
    noStroke();

    fill( 10 );
    rect( x, y, width, height );

    fill( on ? 200 : 120 );
    rect( x, valueY, width, width );
  }
}

public class VolSlider
{
  float x, y, width, height;
  float valueY = 0, value;
  boolean on;

  VolSlider ( float x, float y, float w, float h ) 
  {
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;

    valueY = this.y+height;

    Interactive.add( this );
  }

  public void mouseEntered ()
  {
    on = true;
  }

  public void mouseExited ()
  {
    on = false;
  }

  public void set (float v)
  {
    valueY = map (v, 1, 0, y, y+height);
    value = v;
  }

  public void mouseDragged ( float mx, float my )
  {
    valueY = my;

    if ( valueY < y ) valueY = y;
    if ( valueY > y+height ) valueY = y+height;

    float oldval = value;
    value = map( valueY, y, y+height, 1, 0 );

    if (value != oldval)
    {
      Interactive.send( this, "valueChanged", value );
    }
  }

  public void draw ()
  {
    noStroke();

    fill( 10 );
    rect( x, y, width, height );

    if (!on) fill (120);
    else
      fill ( 0xffED1B24 );
    //fill (255, map(value, 0, 1, 255, 0), 0);
    rect( x, valueY, width, height+y-valueY );
  }
}

public class MicLevel
{
  float x, y, w, h;
  float value; // 0-1

  MicLevel (float x, float y, float w, float h)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    value = 0;
  }

  public void set (float v)
  {
    value = v;
  }

  public void draw()
  {
    noStroke();
    fill(0);
    rect(x, y, w, h);
    fill( 0xff2E3192 );
    float bar = map(value, 0, 1, 0, h);
    rect (x, y+h-bar, w, bar);
  }
}

public class Label
{
  float x, y;
  String text;
  PFont font;
  float size;

  Label (float x, float y, String text, float s)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.text = text;
    this.size = s;
    font = createFont("Droid Sans Mono", size*2, true);
  }

  public void set (String s)
  {
    text = s;
  }

  public void draw()
  {
    noStroke();
    fill(0);
    textFont(font);
    textSize(size);
    text(text, x, y);
  }
}

public class MetroButton
{
  float x, y, width, height;
  float textx, texty;
  int value;
  int state;
  int offFrame;
  int flashFrames;
  PImage img;
  String label;
  PFont font;

  MetroButton ( float x, float y, float w, float h, int f)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x; 
    this.y = y; 
    width = w; 
    height = h;
    value = 0;
    state = 0;
    offFrame = -1;
    flashFrames = f;
    font = createFont("Droid Sans Mono Bold", 60, true);
    textFont(font);
    textSize(60);
    textx = x + (width - textWidth('4'))/2;
    texty = y + (height+textAscent()-textDescent())/2;
  }

  public void bang(int v)
  {
    offFrame = frameCount + flashFrames;
    value = v-1;
  }

  public void setState(int s)
  {
    state = s;
  }

  public void set (int v)
  {
    value = v-1;
  }

  public void draw () 
  {
    boolean on = (frameCount < offFrame);
    if (state>0)
    {
      switch (state)
      {
      case 2:
        // green
        fill ( 0xffB1D28B );
        break;
      case 1:
        // red
        fill( 0xffDE6C6C );
        break;
      default:
        fill(255);
      }
      if (on) fill(0);
      stroke (0);
      rect(x, y, width, height, 5);
      noStroke();
      fill(on? 255 : 0);
      textFont(font);
      textSize(60);
      text(nf(value+1, 1), textx, texty);
    }
  }
}
public class Integrator {
 
  final float DAMPING = 0.7f;
  final float ATTRACTION = 0.15f;
 
  float value;
  float vel;
  float accel;
  float force;
  float mass = 1;
 
  float damping = DAMPING;
  float attraction = ATTRACTION;
  boolean targeting;
  float target;
 
 
  Integrator() { }
 
 
  Integrator(float value) {
    this.value = value;
  }
 
 
  Integrator(float value, float damping, float attraction) {
    this.value = value;
    this.damping = damping;
    this.attraction = attraction;
  }
 
 
  public void set(float v) {
    value = v;
  }
 
 
  public void update() {
    if (targeting) {
      force += attraction * (target - value);     
    }
 
    accel = force / mass;
    vel = (vel + accel) * damping;
    value += vel;
 
    force = 0;
  }
 
 
  public void target(float t) {
    targeting = true;
    target = t;
  }
 
 
  public void noTarget() {
    targeting = false;
  }
}
public class ProgressGraph
{
  float x, y, w, h;
  int maxScore;
  PImage tree;
  final int stepsToNextImage = 15;
  int currentStep;

  ProgressGraph (float x, float y, float w, float h)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    tree = null;
    maxScore = 1500;
    currentStep = 0;
  }

  public void draw()
  {
    if (tree != null) image(tree, x, y, w, h);
  }

  public void setMaxScore (int s)
  {
    maxScore = s;
  }

  public void updateGraph (int s)
  {
    int progress = PApplet.parseInt(map(s, 0, maxScore, 0, 100));
    if (progress != currentStep)
    {
      int picnum = progress*4;
      String newfn = "tree/output_"+nf(picnum, 3)+".png";
      tree = loadImage(newfn);
      currentStep = progress;
    }
  }
}
public class Scorecard
{
  float x, y, w, h;
  Integrator ix;
  Integrator[] starxi;
  float[] starx;
  float center;
  PFont font;
  int stars;
  PImage star;
  boolean active;
  float targets[] = {0.2f, 0.4f, 0.55f, 0.7f, 0.9f };
  float score;
  String thisResult;
  String[][] resultText = {
    { // 0 stars
      "No score.", 
      "Nada!", 
      "I got nothing."
    }, 
    { // 1 star
      "Miserable attempt!", 
      "Ouch! That was ugly.", 
      "Yikes! Not good."
    }, 
    { // 2 stars
      "Not so good.", 
      "Unimpressive.", 
      "Pretty weak."
    }, 
    { // 3 stars
      "Not quite there yet...", 
      "You can do better.", 
      "Close but no cigar."
    }, 
    { // 4 stars
      "Good job!", 
      "That's the way!", 
      "Well done."
    }, 
    { // 5 stars
      "Masterful!", 
      "Excellent!", 
      "Impressive!"
    }
    };

    Scorecard(float x, float y, float w, float h)
    {
      Interactive.add( this ); // register it with the manager
  this.x = x;
  this.y = y;
  this.w = w;
  this.h = h;
  ix = new Integrator(width);
  font = createFont("Helvetica", 48, true);
  star = loadImage("icons/star1.png");
  center = x + w/2;
  active = false;
  score = 0;
  starx = new float[5];
  starxi = new Integrator[5];
  for (int i=0; i<5; i++)
  {
    starxi[i] = new Integrator(width, 0.8f, map(i, 0, 4, 0.1f, 0.05f));
    starx[i] = map(i, -1, 6, x, x+w);
  }
  thisResult = "";
}

public void setScore (float f)
{
  score = f;
  stars = numStars(score);
  for (int i=0; i<stars; i++)
  {
    starxi[i].value = width;
    starxi[i].target(starx[i]);
  }
  thisResult = resultText[stars][PApplet.parseInt(random(3))];
  active = true;
}

private int numStars (float score)
{
  int stars = 0;
  for (int i=0; i<targets.length; i++)
  {
    if (score >= targets[i]) stars = i+1;
  }
  return stars;
}

public void draw()
{
  ix.update();
  if (active)
  {
    ix.target(x);
  } else ix.target(width+PADDING);
  if (ix.value < width)
  {
    center = ix.value + w/2;
    strokeWeight(2);
    stroke(0);
    fill(255);
    rect(ix.value, y, w, h, 10);
    strokeWeight(1);
    noStroke();
    fill(0);
    textFont(font);
    textSize(24);
    textAlign(CENTER);
    text("Score", center, y+48);
    text(thisResult, center, y+250);
    textAlign(LEFT);

    for (int i=0; i<stars; i++)
    {
      starxi[i].update();
      image(star, starxi[i].value, y+100);
    }
  }
}
}
public class ShowMusic
{
  PImage music;
  PImage birdie;
  boolean showBirdie;
  PFont font;
  String[] text;

  ShowMusic ()
  {
    Interactive.add( this ); // register it with the manager
    birdie = loadImage("images/birdie.png");
    showBirdie = true;
    font = createFont("Droid Sans", 18, true);
    text = new String[1];
    text[0] = "";
  }

  public void load (String s)
  {
    music = loadImage(s);
    showBirdie = false;
    text = new String[1];
    text[0] = "";
  }

  public void setText (String s)
  {
    text = loadStrings(s);
  }

  public void draw()
  {
    if (music.width==-1 || showBirdie)
    {
      image (birdie, SIDEBAR_WIDTH, TOPBAR_HEIGHT, width-SIDEBAR_WIDTH, height-TOPBAR_HEIGHT);
      drawText();
    } else
    {
      float rescale = (width-SIDEBAR_WIDTH-(2*PADDING))*1.0f/music.width;
      float rescale2 = (height-TOPBAR_HEIGHT-(2*PADDING))*1.0f/music.height;
      rescale = min(rescale,rescale2);
      image (music, SIDEBAR_WIDTH+PADDING, TOPBAR_HEIGHT+PADDING, music.width*rescale, music.height*rescale);
    }
  }

  public void drawText()
  {
    textFont(font);
    textSize(18);
    noStroke();
    fill(0);
    float y = TOPBAR_HEIGHT+2*PADDING;
    if (text.length>0)
    {
      for (int i=0; i<text.length; i++)
      {
        text(text[i], (SIDEBAR_WIDTH+width)*0.55f, y);
        y += (textAscent()+textDescent())*1.5f;
      }
    }
  }
}
public class Splash
{
  boolean active;
  PImage splashImage;

  Splash()
  {
    Interactive.add( this ); // register it with the manager
    splashImage = loadImage("images/splash.png");
    active = true;
  }

  public void draw()
  {
    if (active)
    {
      image (splashImage, 2*PADDING+SIDEBAR_WIDTH, 2*PADDING, width-SIDEBAR_WIDTH-4*PADDING, height-4*PADDING);
      noFill();
      stroke(0);
      strokeWeight(3);
      rect(2*PADDING+SIDEBAR_WIDTH, 2*PADDING, width-SIDEBAR_WIDTH-4*PADDING, height-4*PADDING);
      strokeWeight(1);
    }
  }
}
class UserProgress
{
  XML user;
  XML username;
  XML library;
  XML progress;
  XML score;
  XML[] exercise;
  int nextUnpassed;
  String secretKey;
  String extension=".latido";

  UserProgress (String playerName, String libName)
  {
    user = loadXML("newuser.xml");
    username = user.getChild("name");
    library = user.getChild("library");
    progress = user.getChild("progress");
    score = user.getChild("score");
    exercise = progress.getChildren("exercise");
    username.setContent(playerName);
    library.setContent(libName);
    nextUnpassed = 0;
    secretKey = libName.substring(0, 8);
  }

  public boolean load (String f)
  {
    try
    {
      byte[] data = loadBytes(f);
      File tempFile = File.createTempFile("guido", "arrezo");
      saveBytes(tempFile, decipher(secretKey, data));
      user=loadXML(tempFile.getAbsolutePath());
      tempFile.delete();
      username = user.getChild("name");
      library = user.getChild("library");
      progress = user.getChild("progress");
      score = user.getChild("score");
      exercise = progress.getChildren("exercise");
      int id;
      for (id = 0; id<exercise.length; id++)
      {
        int testval = exercise[id].getIntContent();
        if (testval < 4)
        {
          break;
        }
      }
      nextUnpassed = id;
      secretKey = library.getContent().substring(0, 8);
      return true;
    } 
    catch (Exception e) {
      showMessageDialog(null, "Could not load Latido user file", "Alert", ERROR_MESSAGE);
    }
    return false;
  }

  public void save (String f)
  {
    try
    {
      if (!f.substring(f.length()-extension.length(), f.length()).equals(".latido"))
      {
        f += extension;
      }
      byte[] data = user.toString().getBytes();
      saveBytes(f, cipher(secretKey, data));
    } 
    catch (Exception e) {
      showMessageDialog(null, "Could not save Latido user file", "Alert", ERROR_MESSAGE);
    }
  }

  public void updateInfo (int id, String n)
  {
    if (id>=exercise.length)
    {
      XML newEntry = progress.addChild("exercise");
      newEntry.setString("id", n);
      newEntry.setString("started", timeStamp());
      newEntry.setIntContent(0);
      exercise = progress.getChildren("exercise");
    }
  } 

  public void updateScore (int id, int stars)
  { 
    int oldStars = exercise[id].getIntContent();
    if (stars > oldStars)
    {
      exercise[id].setIntContent(stars);
      int oldScore = score.getIntContent();
      score.setIntContent(oldScore + stars - oldStars);
      if (stars > 3 && oldStars <= 3)
      {
        exercise[id].setString("completed", timeStamp());
      }
    }
  }

  public int getCurrentStars (int id)
  {
    return exercise[id].getIntContent();
  }

  public int getTotalScore ()
  {
    return score.getIntContent();
  }

  public String getLibraryName()
  {
    return library.getContent();
  }

  public String timeStamp()
  {
    return nf(hour(), 2)+":"+nf(minute(), 2)+" "+nf(month(), 2)+"/"+nf(day(), 2)+"/"+nf(year(), 2);
  }


  /**
   * Encrypt data
   * @param secretKey -   a secret key used for encryption
   * @param data      -   data to encrypt
   * @return  Encrypted data
   * @throws Exception
   */
  public byte[] cipher(String secretKey, byte[] data) throws Exception {
    // Key has to be of length 8
    if (secretKey == null || secretKey.length() != 8)
      throw new Exception("Invalid key length - 8 bytes key needed!");

    SecretKey key = new SecretKeySpec(secretKey.getBytes(), "DES");
    Cipher cipher = Cipher.getInstance("DES");
    cipher.init(Cipher.ENCRYPT_MODE, key);

    return cipher.doFinal(data);
  }

  /**
   * Decrypt data
   * @param secretKey -   a secret key used for decryption
   * @param data      -   data to decrypt
   * @return  Decrypted data
   * @throws Exception
   */
  public byte[] decipher(String secretKey, byte[] data) throws Exception {
    // Key has to be of length 8
    if (secretKey == null || secretKey.length() != 8)
      throw new Exception("Invalid key length - 8 bytes key needed!");

    SecretKey key = new SecretKeySpec(secretKey.getBytes(), "DES");
    Cipher cipher = Cipher.getInstance("DES");
    cipher.init(Cipher.DECRYPT_MODE, key);

    return cipher.doFinal(data);
  }
}
  public void settings() {  size(1024, 540); smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Latido" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
