void keyPressed()
{
  sendOscFloat("/rhy", library.rhythm ? 1 : 0);
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
    notifyPd(library.rhythm);
  } else
  {
    if (music.showBirdie)
    {
      music.showBirdie = false;
      setLock(gui.getController("playButton"), false);//.unlock();
      setLock(gui.getController("stopButton"), false);//.lock();
      setLock(gui.getController("pitchButton"), library.rhythm);
      setLock(gui.getController("playbackButton"), true);
      setLock(gui.getController("nextButton"), cantAdvance(0));
      setLock(gui.getController("previousButton"), false);
    } else
    {
      music.showBirdie = true;
      setLock(gui.getController("playbackButton"), true);
      library.loadNext();
      music.load(library.getImage());
      music.showBirdie = true;
      music.setText(library.getText());
      gui.getController("tempoSlider").setValue(library.getTempo());
      notifyPd(library.rhythm);
      userProgress.updateInfo(library.currentLine, library.getName());
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

    library.loadPrevious();
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    gui.getController("tempoSlider").setValue(library.getTempo());
    notifyPd(library.rhythm);
    userProgress.updateInfo(library.currentLine, library.getName());
    setLock(gui.getController("nextButton"), (userProgress.getCurrentStars(library.currentLine)<=3));
  } else
  {
    music.showBirdie = true;
    setLock(gui.getController("playButton"), true);//.lock();
    setLock(gui.getController("stopButton"), true);//.lock();
    setLock(gui.getController("pitchButton"), library.rhythm);

    setLock(gui.getController("nextButton"), false);
    gui.getGroup("scorecard").hide();
  }
  setLock(gui.getController("previousButton"), (music.showBirdie && library.currentLine==0));
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
  setLock(gui.getController("pitchButton"), library.rhythm);
  setLock(gui.getController("playbackButton"), false);
}

void libraryButton (int v)
{
  selectFolder("Choose your latido library folder...", "folderCallback");
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

boolean cantAdvance (float score)
{
  if (score > 0.7) return false;
  if (practiceMode) return false;
  else if (userProgress.getCurrentStars(library.currentLine)>3) return false;
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
  setLock(gui.getController("playButton"), true);//.lock();
  setLock(gui.getController("stopButton"), true);
  setLock(gui.getController("pitchButton"), true);
  setLock(gui.getController("playbackButton"), false);
  setLock(gui.getController("redoButton"), false);
  //scorecard.setScore(theScore);
  setLock(gui.getController("nextButton"), cantAdvance(theScore));
  //if (!practiceMode) userProgress.updateScore(library.currentLine, scorecard.stars);
  tree.updateGraph(userProgress.getTotalScore());
  treeLabel.set(userProgress.getTotalScore()+" Stars");
  if (saving) userProgress.save(savePath);
}

void folderCallback(File f)
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
    gui.getController("tempoSlider").setValue(library.getTempo());
    tree.setMaxScore(library.numMelodies*5);
    notifyPd(library.rhythm);
    showMessageDialog(null, "Loaded new library:\n"+library.getDescription(), "New Latido Library Loaded", INFORMATION_MESSAGE);
  }
  catch (Exception e)
  {
    showMessageDialog(null, "Could not load Latido library", "Alert", ERROR_MESSAGE);
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

    library.loadSpecific(userProgress.nextUnpassed);
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    gui.getController("tempoSlider").setValue(library.getTempo());
    notifyPd(library.rhythm);
    userProgress.updateInfo(library.currentLine, library.getName());
    tree.updateGraph(userProgress.getTotalScore());
    treeLabel.set(userProgress.getTotalScore()+" Stars");
    setLock(gui.getController("nextButton"), false);
    setLock(gui.getController("previousButton"), (library.currentLine<=0));
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

