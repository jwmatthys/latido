void keyPressed()
{
  sendOscFloat("/rhy", library.rhythm ? 1 : 0);
}

void mousePressed()
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

void nextButton (int v)
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

void previousButton (int v)
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

public void playButton (int value)
{
  sendOscString("/latido/transport", "play");
  stop.active = true;
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

public void replayButton (int value)
{
  sendOscString("/latido/transport", "replay");
  stop.active = true;
} 

void redoButton (int value)
{
  scorecard.active = false;
  music.showBirdie = false;
  play.active = true;
  stop.active = false;
  pitch.active = !library.rhythm;
  replay.active = false;
  libraryButton.visibility(false);
}

void libraryButton (int v)
{
  selectFolder("Choose your latido library folder...", "folderCallback");
}

void userPrefs (int v)
{
  if (v == 0)
  {
    selectInput("Choose your Latido user progress file...", "loadCallback");
  } else
  {
    selectOutput("Choose where to save your Latido user progress file...", "saveCallback");
  }
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
  int t = int(f);
  tempoLabel.set(t+" BPM");
  tempo.set(map(t, TEMPO_LOW, TEMPO_HIGH, 0, 1));
}

public void metroPD (float f)
{
  int b = int(f);
  metro.bang(b);
}

public void metroStatePD (float f)
{
  int s = int(f);
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
  if (theScore >= 0.7 || userProgress.getCurrentStars(library.currentLine)>3)
  {
    next.active = true;
  }
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
    tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
    tempoLabel.set(library.getTempo()+" bpm");
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
