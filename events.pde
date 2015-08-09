void keyPressed()
{
  sendOscFloat("/rhy", module.rhythm ? 1 : 0);
}

void mouseWheel(MouseEvent event)
{
  if (exerciseList.isMouseOver() && exerciseList.isOpen() && exerciseList.isVisible())
  {
    scroll = constrain(scroll+(event.getCount()*0.01), 0, 1);
    exerciseList.scroll(scroll);
  }
}

void nextButton (int v)
{
  setLock(gui.getController("redoButton"), true);
  gui.getGroup("scorecard").hide();
  optionGroup.close();
  if (gui.getGroup("splash") != null && gui.getGroup("splash").isVisible())
  {
    gui.getGroup("splash").hide();
    gui.getGroup("splash").remove();
    optionGroup.show();
    setView(SHOW_TEXT);
    setLock(gui.getController("nextButton"), false);
    notifyPd(module.rhythm);
  } else
  {
    if (view == SHOW_TEXT)
    {
      setView(SHOW_MUSIC);
      progressGroup.hide();
      setLock(gui.getController("playButton"), false);
      setLock(gui.getController("stopButton"), false);
      setLock(gui.getController("pitchButton"), module.rhythm);
      setLock(gui.getController("playbackButton"), true);
      setLock(gui.getController("nextButton"), cantAdvance());
      setLock(gui.getController("previousButton"), false);
    } else
    {
      setView(SHOW_TEXT);
      setLock(gui.getController("playbackButton"), true);
      progressGroup.show();
      module.loadNext();
      music.load(module.getImage());
      setText(module.getText());
      gui.getController("tempoSlider").setValue(module.getTempo());
      notifyPd(module.rhythm);
      userProgress.updateInfo(module.currentLine, module.getName());
      setLock(gui.getController("nextButton"), false);
      setLock(gui.getController("previousButton"), false);
      gui.getController("progressLabel").setStringValue(userProgress.getTotalScore()+" stars earned");
      progressSlider.setValue(module.currentLine);
    }
  }
}

void previousButton (int v)
{
  setLock(gui.getController("nextButton"), false);
  gui.getGroup("scorecard").hide();
  if ( scorecardGroup.isVisible() )
  {
    scorecardGroup.hide();
  } else if (view == SHOW_TEXT)
  {
    setLock(gui.getController("playbackButton"), true);
    module.loadPrevious();
    music.load(module.getImage());
    setText(module.getText());
    //setView(SHOW_TEXT);
    gui.getController("tempoSlider").setValue(module.getTempo());
    notifyPd(module.rhythm);
    userProgress.updateInfo(module.currentLine, module.getName());
    setLock(gui.getController("nextButton"), cantAdvance());
  } else // if view == SHOW_MUSIC
  {
    setView(SHOW_TEXT);
    setLock(gui.getController("playButton"), true);
    setLock(gui.getController("stopButton"), true);
    setLock(gui.getController("pitchButton"), module.rhythm);
  }
  setLock(gui.getController("previousButton"), (view == SHOW_TEXT && module.currentLine==0));
}

public void playButton (int value)
{
  sendOscString("/latido/transport", "play");
  setLock(gui.getController("stopButton"), false);
  gui.getGroup("scorecard").hide();
}

public void stopButton (int value)
{
  sendOscString("/latido/transport", "stop");
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
  setView(SHOW_MUSIC);
  setLock(gui.getController("playButton"), false);
  setLock(gui.getController("stopButton"), true);
  setLock(gui.getController("pitchButton"), module.rhythm);
  setLock(gui.getController("playbackButton"), false);
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

void practiceToggle (boolean v)
{
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
      music.load(module.getImage());
      setText(module.getText());
      setView(SHOW_TEXT);
      gui.getController("tempoSlider").setValue(module.getTempo());
      notifyPd(module.rhythm);
      userProgress.updateInfo(module.currentLine, module.getName());
    }
  }
}

void controlEvent(ControlEvent theEvent)
{
  if (theEvent.isGroup() && theEvent.name().equals("Jump"))
  {
    int val = (int)theEvent.group().value();
    module.loadSpecific(val);
    music.load(module.getImage());
    setText(module.getText());
    progressSlider.setRange(0, module.numMelodies);
    setView(SHOW_TEXT);
    exerciseList.close();
    optionGroup.close();
  }
}

void progress (int v)
{
  println("progress bar touched! "+v);
}

boolean cantAdvance ()
{
  if (practiceMode) return false;
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

public void scorePD (float theScore)
{
  setLock(gui.getController("playButton"), true);
  setLock(gui.getController("stopButton"), true);
  setLock(gui.getController("pitchButton"), true);
  setLock(gui.getController("playbackButton"), false);
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
  if (saving) userProgress.save(savePath);
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
  try
  {
    String libName = module.load(f);
    userProgress = new UserProgress(System.getProperty("user.name"), libName);
    userProgress.updateInfo(module.currentLine, module.getName());
    music.load(module.getImage());
    exerciseList.clear();
    for (int i=0; i<module.numMelodies; i++) {
      module.loadSpecific(i);
      exerciseList.addItem(module.getName(), i);
      //lbi.setColorBackground(0xffff0000);
    }
    module.loadSpecific(0);
    setText(module.getText());
    setView(SHOW_TEXT);
    gui.getController("tempoSlider").setValue(module.getTempo());
    progressSlider.setRange(0, module.numMelodies);
    notifyPd(module.rhythm);
    showMessageDialog(null, "Loaded new module:\n"+module.getDescription(), "New Latido Module Loaded", INFORMATION_MESSAGE);
  }
  catch (Exception e)
  {
    showMessageDialog(null, "Could not load Latido module", "Alert", ERROR_MESSAGE);
  }
}

void loadCallback(File f)
{
  String s = f.getAbsolutePath();
  if (userProgress.load(s))
  {
    savePath = s;
    saving = true;
    gui.getGroup("scorecard").hide();
    setLock(gui.getController("playbackButton"), true);
    module.loadSpecific(userProgress.getNextUnpassed());
    music.load(module.getImage());
    setText(module.getText());
    setView(SHOW_TEXT);
    gui.getController("tempoSlider").setValue(module.getTempo());
    notifyPd(module.rhythm);
    userProgress.updateInfo(module.currentLine, module.getName());
    setLock(gui.getController("nextButton"), false);
    setLock(gui.getController("previousButton"), (module.currentLine<=0));
  }
}

void saveCallback(File f)
{
  String s = f.getAbsolutePath();
  userProgress.save(s);
  savePath = s;
  saving = true;
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

