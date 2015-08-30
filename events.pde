void keyPressed()
{
  sendOscFloat("/rhy", module.rhythm ? 1 : 0);
}

/*
void mouseWheel(MouseEvent event)
 {
 if (exerciseList.isMouseOver() && exerciseList.isOpen() && exerciseList.isVisible())
 {
 scroll = constrain(scroll+(event.getCount()*0.01), 0, 1);
 exerciseList.scroll(scroll);
 }
 }
 */

void nextButton (int v)
{
  exerciseList.close();
  optionGroup.close();
  setLock(gui.getController("redoButton"), true);
  setLock(gui.getController("playbackButton"), true);
  gui.getGroup("scorecard").hide();
  if (!optionGroup.isVisible())
  {
    optionGroup.show();
  }
  if (gui.getGroup("splash") != null && gui.getGroup("splash").isVisible())
  {
    loadAfterSplash();
  } else
  {
    if (view == SHOW_TEXT)
    {
      setView(SHOW_MUSIC);
      progressGroup.hide();
      setLock(gui.getController("playButton"), false);
      setLock(gui.getController("stopButton"), false);
      setLock(gui.getController("pitchButton"), module.rhythm);
      setLock(gui.getController("nextButton"), cantAdvance());
      setLock(gui.getController("previousButton"), false);
    } else
    {
      module.loadNext();
      loadExercise();
      setLock(gui.getController("nextButton"), false);
      setLock(gui.getController("previousButton"), false);
    }
  }
}

void previousButton (int v)
{
  progressGroup.show();
  setLock(gui.getController("nextButton"), false);
  setLock(gui.getController("redoButton"), true);
  gui.getGroup("scorecard").hide();
  if ( scorecardGroup.isVisible() )
  {
    scorecardGroup.hide();
    setView(SHOW_TEXT);
  } 
  if (view == SHOW_TEXT)
  {
    setLock(gui.getController("playbackButton"), true);
    module.loadPrevious();
    loadExercise();
    setLock(gui.getController("nextButton"), cantAdvance());
  } else // if view == SHOW_MUSIC
  {
    setView(SHOW_TEXT);
    setLock(gui.getController("playButton"), true);
    setLock(gui.getController("stopButton"), true);
    setLock(gui.getController("pitchButton"), true);
  }
  setLock(gui.getController("previousButton"), (view == SHOW_TEXT && module.currentLine==0));
}

public void playButton (int value)
{
  sendOscString("/latido/transport", "play");
  setLock(gui.getController("stopButton"), false);
  gui.getGroup("scorecard").hide();
  setLock(gui.getController("previousButton"), true);
  setLock(gui.getController("redoButton"), true);
  setLock(gui.getController("nextButton"), true);
}

public void stopButton (int value)
{
  sendOscString("/latido/transport", "stop");
  setLock(gui.getController("playbackButton"), false);
  setLock(gui.getController("previousButton"), false);
  setLock(gui.getController("redoButton"), false);
  setLock(gui.getController("nextButton"), cantAdvance());
}

public void pitchButton (int value)
{
  sendOscString("/latido/transport", "pitch");
}

public void playbackButton (int value)
{
  sendOscString("/latido/transport", "replay");
  setLock(gui.getController("stopButton"), false);
} 

void redoButton (int value)
{
  gui.getGroup("scorecard").hide();
  progressGroup.hide();
  setView(SHOW_MUSIC);
  setLock(gui.getController("playButton"), false);
  setLock(gui.getController("stopButton"), false);
  setLock(gui.getController("pitchButton"), module.rhythm);
  setLock(gui.getController("playbackButton"), false);
  setLock(gui.getController("previousButton"), false);
  setLock(gui.getController("redoButton"), true);
}

void moduleButton (int v)
{
  selectInput("Choose your latido module file...", "moduleCallback");
}

void loadButton (int v)
{
  selectInput("Choose your Latido user progress file...", "loadCallback");
}

void saveButton (int v)
{
  selectOutput("Choose where to save your Latido user progress file...", "saveCallback");
}

void volumeSlider (float v)
{
  sendOscFloat("/latido/vol", v*0.01);
}

void tempoSlider (float v)
{
  sendOscFloat("/latido/tempo", v);
}

void latencyOutSlider (float v)
{
  sendOscFloat("/latido/latency", v);
}

void latencyToggle (float v)
{
  sendOscFloat("/latido/testlatency", v);
}

void practiceToggle (boolean v)
{
  try
  {
    gui.getGroup("scorecard").hide();
    practiceMode = !v;
    gui.getController("practiceLabel")
      .setStringValue( practiceMode ? "ON" : "OFF");
    setLock(gui.getController("nextButton"), false);
    if (practiceMode) exerciseList.show();
    else 
    {
      exerciseList.hide();
      int nextUnpassed = userProgress.getNextUnpassed();
      if (module.currentLine > nextUnpassed)
      {
        module.loadSpecific(nextUnpassed);
        loadExercise();
      }
    }
  } 
  catch (Exception e) {
  }
}

void jump (int v)
{
  module.loadSpecific(v);
  loadExercise();
  exerciseList.close();
  optionGroup.close();
}

boolean cantAdvance ()
{
  if (practiceMode) return false;
  if (module.extracredit) return false;
  else if (userProgress.getCurrentStars(module.currentLine)>3) return false;
  return true;
}

//---------------------------------------------------------------
// OSC Communication with Pd - plug methods

public void micPD (float f)
{
  gui.getController("micLevel").setValue(f);
}

public void tempoPD (float f)
{
  gui.getController("tempoSlider").setValue(f);
}

public void metroPD (float f)
{
  metro.activate(0);
  metroOff = frameCount+5;
  metro.getItem(0).setLabel(nf(f, 0, 0));
}

public void metroStatePD (float f)
{
  int s = int(f);
  switch(s)
  {
  case 0:
    metro.hide();
    break;
  case 1:
    metro.show();
    metro.setColorActive(color(200, 0, 0)); //on - should be lighter
    metro.setColorBackground(color(100, 0, 0)); //off - should be darker
    metro.setColorForeground(color(100, 0, 0)); //mouseover - should be same as background
    break;
  case 2:
  default:
    metro.show();
    metro.setColorActive(color(0, 200, 0)); //on - should be lighter
    metro.setColorBackground(color(0, 100, 0)); //off - should be darker
    metro.setColorForeground(color(0, 100, 0)); //mouseover - should be same as background
  }
}

public void watchdogPD ()
{
  OscMessage myMessage = new OscMessage("/latido/watchdog");
  oscP5.send(myMessage, latidoPD);
}

public void latencyPD(float f)
{
  gui.getController("latencyInSlider").setValue(int(f));
}

public void scorePD (float theScore)
{
  setLock(gui.getController("playButton"), true);
  setLock(gui.getController("stopButton"), true);
  setLock(gui.getController("pitchButton"), true);
  setLock(gui.getController("playbackButton"), false);
  setLock(gui.getController("previousButton"), false);
  setLock(gui.getController("redoButton"), false);
  int stars = score.get(theScore);
  //println("theScore: "+theScore+", stars: "+stars);
  if (!practiceMode)
  {
    userProgress.updateScore(module.currentLine, stars);
  }
  setLock(gui.getController("nextButton"), cantAdvance());
  //tree.updateGraph(userProgress.getTotalScore());
  //treeLabel.set(userProgress.getTotalScore()+" Stars");
  userProgress.save();
  gui.getController("progressLabel").setStringValue(userProgress.getTotalScore()+" stars earned");
  progressSlider.setValue(userProgress.getTotalScore());
  progressGroup.show();
  showScorecard (stars);
}

void showScorecard(int stars)
{
  HACK_STARS = stars; // :( we have to use a global variable and create a new controlP5 canvas
  scorecardGroup.removeCanvas(starCanvas);
  starCanvas = new StarCanvas();
  scorecardGroup.addCanvas(starCanvas);
  gui.getGroup("scorecard").show();
}

void moduleCallback(File f)
{
  userProgress.save();
  gui.getGroup("scorecard").hide();
  if (module.load(f))
  {
    try
    {
      libName = module.getLibName();
      userProgress = new UserProgress(System.getProperty("user.name"), libName, saveFile);
      userProgress.updateInfo(module.currentLine, module.getName());
      exerciseList.clear();
      for (int i=0; i<module.numMelodies; i++) {
        module.loadSpecific(i);
        exerciseList.addItem(module.getName(), i);
      }
      module.loadSpecific(0);
      loadExercise();
      progressSlider.setRange(0, module.numMelodies * 5);
      gui.getController("progressLabel").setStringValue(userProgress.getTotalScore()+" stars earned");
      progressSlider.setValue(userProgress.getTotalScore());
      JOptionPane.showMessageDialog(null, "Loaded new module:\n"+module.getDescription(), "New Latido Module Loaded", JOptionPane.INFORMATION_MESSAGE); 
      setLock(gui.getController("nextButton"), false);
      config.setModulePath(f.getAbsolutePath());
      saveFile = File.createTempFile("guido", "arrezo");
      userProgress.setUserFile(saveFile);
      userProgress.save();
    }
    catch (Exception e)
    {
      JOptionPane.showMessageDialog(null, "Yikes! Something went mysteriously wrong.\n"+e+"\nPlease report this bug!", "Latido", JOptionPane.ERROR_MESSAGE);
      link("http://joel.matthysmusic.com/contact.html");
    }
  }
}

void loadCallback(File f)
{
  String s = f.getAbsolutePath();
  if (!s.substring(s.length()-extension.length(), s.length()).equals(".latido"))
  {
    JOptionPane.showMessageDialog(null, f.getName()+"\nis not a valid Latido progress file.", "Alert", JOptionPane.ERROR_MESSAGE);
  } else
  {
    if (userProgress.load(s))
    {
      userProgress.setUserFile(f);
      config.setUserfilePath(s);
      gui.getGroup("scorecard").hide();
      setLock(gui.getController("playbackButton"), true);
      module.loadSpecific(userProgress.getNextUnpassed());
      loadExercise();
      gui.getController("progressLabel").setStringValue(userProgress.getTotalScore()+" stars earned");
      progressSlider.setValue(userProgress.getTotalScore());
      setLock(gui.getController("nextButton"), false);
      setLock(gui.getController("previousButton"), (module.currentLine<=0));
    }
  }
}

void saveCallback(File f)
{
  gui.getGroup("scorecard").hide();
  userProgress.setUserFile(f);
  userProgress.save();
  config.setUserfilePath(userProgress.getUserFile());
}

void websiteLink (int v)
{
  link("http://joel.matthysmusic.com/contact/");
}

void setLock(Controller theController, boolean theValue)
{

  if (theValue) {
    theController.setColorBackground(color(100, 100));
    theController.setMouseOver(false);
    theController.lock();
    theController.getCaptionLabel().setColor(color(0));
  } else {
    theController.unlock();
    theController.setColorBackground(color(0, 45, 90));
    theController.getCaptionLabel().setColor(color(255));
  }
}

void loadExercise()
{
  progressGroup.show();
  music.load(module.getImage());
  setText(module.getText());
  setView(SHOW_TEXT);
  gui.getController("tempoSlider").setValue(module.getTempo());
  notifyPd(module.rhythm);
  userProgress.updateInfo(module.currentLine, module.getName());
  setLock(gui.getController("playButton"), true);
  setLock(gui.getController("stopButton"), true);
  setLock(gui.getController("pitchButton"), true);
}

void loadAfterSplash()
{
  float latency = OSX_LATENCY;
  if (match(OS, "Windows") != null) latency=WINDOWS_LATENCY;
  else if (match(OS, "Linux") != null) latency=LINUX_LATENCY;
  gui.getController("latencyOutSlider").setValue(latency);
  sendOscFloat("/latido/latency", latency); // is this redundant?
  boolean reload = config.askReload();
  if (reload)
  {
    config.load();
    saveFile = new File(config.getUserfilePath());
  } else
  {
    config.create();
  }

  if (module.load(new File(config.getModulePath()))) libName = module.getLibName();
  score = new CalculateScore();

  userProgress = new UserProgress(System.getProperty("user.name"), libName, saveFile);
  if (reload) loadCallback(saveFile);
  userProgress.updateInfo(module.currentLine, module.getName());

  for (int i=0; i<module.numMelodies; i++) {
    module.loadSpecific(i);
    exerciseList.addItem(module.getName(), i);
  }
  module.loadSpecific(userProgress.getNextUnpassed());
  music.load(module.getImage());
  setText(module.getText());
  gui.getController("tempoSlider").setValue(module.getTempo());
  notifyPd(module.rhythm);
  userProgress.updateInfo(module.currentLine, module.getName());
  progressSlider.setRange(0, module.numMelodies * 5);

  gui.getGroup("splash").hide();
  gui.getGroup("splash").remove();
  gui.getController("loadButton").unlock();
  gui.getController("practiceToggle").unlock();
  setView(SHOW_TEXT);
  setLock(gui.getController("nextButton"), false);
}

public void showLatency()
{
  if (latencyGroup.isVisible())
  {
    latencyGroup.hide();
    sendOscFloat("/latido/testlatency", 0);
  } else
  {
    latencyGroup.show();
  }
}