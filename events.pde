void keyPressed()
{
  sendOscFloat("/rhy", module.rhythm ? 1 : 0);
}

void nextButton (int v)
{
  setLock(gui.getController("redoButton"), true);
  gui.getGroup("scorecard").hide();
  if (gui.getGroup("splash").isVisible())
  {
    gui.getGroup("splash").hide();
    //gui.getGroup("splash").remove();
    music.showBirdie = true;
    setLock(gui.getController("nextButton"), false);
    notifyPd(module.rhythm);
  } else
  {
    if (music.showBirdie)
    {
      music.showBirdie = false;
      setLock(gui.getController("playButton"), false);//.unlock();
      setLock(gui.getController("stopButton"), false);//.lock();
      setLock(gui.getController("pitchButton"), module.rhythm);
      setLock(gui.getController("playbackButton"), true);
      setLock(gui.getController("nextButton"), cantAdvance());
      setLock(gui.getController("previousButton"), false);
    } else
    {
      music.showBirdie = true;
      setLock(gui.getController("playbackButton"), true);
      module.loadNext();
      music.load(module.getImage());
      music.showBirdie = true;
      music.setText(module.getText());
      gui.getController("tempoSlider").setValue(module.getTempo());
      notifyPd(module.rhythm);
      userProgress.updateInfo(module.currentLine, module.getName());
      setLock(gui.getController("nextButton"), false);
      setLock(gui.getController("previousButton"), false);
    }
  }
}

void previousButton (int v)
{
  if (music.showBirdie ||   gui.getGroup("scorecard").isVisible())
  {
    gui.getGroup("scorecard").hide();
    music.showBirdie = true;
    setLock(gui.getController("playbackButton"), true);//.lock();

    module.loadPrevious();
    music.load(module.getImage());
    music.showBirdie = true;
    music.setText(module.getText());
    gui.getController("tempoSlider").setValue(module.getTempo());
    notifyPd(module.rhythm);
    userProgress.updateInfo(module.currentLine, module.getName());
    setLock(gui.getController("nextButton"), (userProgress.getCurrentStars(module.currentLine)<=3));
  } else
  {
    music.showBirdie = true;
    setLock(gui.getController("playButton"), true);//.lock();
    setLock(gui.getController("stopButton"), true);//.lock();
    setLock(gui.getController("pitchButton"), module.rhythm);

    setLock(gui.getController("nextButton"), false);
    gui.getGroup("scorecard").hide();
  }
  setLock(gui.getController("previousButton"), (music.showBirdie && module.currentLine==0));
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
  music.showBirdie = false;
  setLock(gui.getController("playButton"), false);//.unlock();
  setLock(gui.getController("stopButton"), true);//.lock();
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
    .setStringValue( practiceMode ? "PRACTICE MODE ON" : "PRACTICE MODE OFF");
  setLock(gui.getController("nextButton"), false);
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
  if (!practiceMode) userProgress.updateScore(module.currentLine, stars);
  setLock(gui.getController("nextButton"), cantAdvance());
  gui.getGroup("scorecard").show();
  //tree.updateGraph(userProgress.getTotalScore());
  //treeLabel.set(userProgress.getTotalScore()+" Stars");
  if (saving) userProgress.save(savePath);
}

void moduleCallback(File f)
{
  try
  {
    String libName = module.load(f);
    userProgress = new UserProgress(System.getProperty("user.name"), libName);
    userProgress.updateInfo(module.currentLine, module.getName());
    music.load(module.getImage());
    music.showBirdie = true;
    music.setText(module.getText());
    gui.getController("tempoSlider").setValue(module.getTempo());
    tree.setMaxScore(module.numMelodies*5);
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
    music.showBirdie = true;
    setLock(gui.getController("playbackButton"), true);

    module.loadSpecific(userProgress.nextUnpassed);
    music.load(module.getImage());
    music.showBirdie = true;
    music.setText(module.getText());
    gui.getController("tempoSlider").setValue(module.getTempo());
    notifyPd(module.rhythm);
    userProgress.updateInfo(module.currentLine, module.getName());
    tree.updateGraph(userProgress.getTotalScore());
    treeLabel.set(userProgress.getTotalScore()+" Stars");
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

