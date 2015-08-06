void keyPressed()
{
  sendOscFloat("/rhy", library.rhythm ? 1 : 0);
}

void mousePressed()
{
  if (splash.active)
  {
    splash.active = false;
    music.showBirdie = true;
    setLock(gui.getController("nextButton"), false);
    notifyPd(library.rhythm);
  }
}

void nextButton (int v)
{
  setLock(gui.getController("previousButton"), false);
  setLock(gui.getController("redoButton"), true);
  scorecard.active = false;

  if (music.showBirdie)
  {
    music.showBirdie = false;
    setLock(gui.getController("playButton"), false);//.unlock();
    setLock(gui.getController("stopButton"), false);//.lock();
    setLock(gui.getController("pitchButton"), library.rhythm);
    setLock(gui.getController("playbackButton"), true);
    setLock(gui.getController("nextButton"), (userProgress.getCurrentStars(library.currentLine)<=3));
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
  }
}

void previousButton (int v)
{
  if (music.showBirdie || scorecard.active)
  {
    scorecard.active = false;
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
    scorecard.active = false;
  }
  setLock(gui.getController("previousButton"), (music.showBirdie && library.currentLine==0));
}

public void playButton (int value)
{
  sendOscString("/latido/transport", "play");
  setLock(gui.getController("stopButton"), false);
  scorecard.active = false;
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
  scorecard.active = false;
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
  int b = int(f);
  println("bang");
  metro.setLabel(nf(f,0,0));
}

public void metroStatePD (float f)
{
  int s = int(f);
  //metro.setState(s);
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
  scorecard.setScore(theScore);
  boolean advance = (theScore >= 0.7 ||
    userProgress.getCurrentStars(library.currentLine)>3);
  setLock(gui.getController("nextButton"), !advance);
  userProgress.updateScore(library.currentLine, scorecard.stars);
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
    scorecard.active = false;
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
/*
  if (theValue) {
    theController.setColorBackground(color(100, 100));
    theController.getCaptionLabel().setColor(color(0));
    theController.hide();
  } else {
    theController.show();
    theController.setColorBackground(color(0, 0, 200));
    theController.getCaptionLabel().setColor(color(255));
  }
  */
}

