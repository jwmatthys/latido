void keyPressed()
{
  OscMessage myMessage = new OscMessage("/rhy");
  myMessage.add(library.rhythm ? 1 : 0);
  oscP5.send(myMessage, latidoPD);
}

void nextButton (int v)
{
  previous.active = true;
  if (music.showBirdie)
  {
    music.showBirdie = false;
    play.active = true;
    stop.active = false;
    pitch.active = true;
    replay.active = false;
    libraryButton.visibility(false);
    scorecard.active = false;
    if (userProgress.getCurrentStars(library.currentLine)>3) next.active = true;
    else next.active = false;
  } else
  {
    scorecard.active = false;
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
  }
}

void prevButton (int v)
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
  } else
  {
    music.showBirdie = true;
    play.active = false;
    stop.active = false;
    pitch.active = true;
    scorecard.active = false;
    next.active = true;
  }
  if (music.showBirdie && library.currentLine==0) previous.active = false;
}

void transportButton (int v)
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

void libraryButton (int v)
{
  if (v==0)
  {
    selectInput("Choose your latido.txt library file...", "folderCallback");
  } else
  {
    if (v==2) //redo
    {
      scorecard.active = false;
      music.showBirdie = false;
      play.active = true;
      stop.active = false;
      pitch.active = true;
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
  OscMessage myMessage = new OscMessage("/latido/vol");
  myMessage.add(v);
  oscP5.send(myMessage, latidoPD);
}

void tempoSlider (float v)
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
  micLevel.set(sqrt(f*0.01));
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
}

void folderCallback(File f)
{
  if (f != null)
  {
    String s = f.getAbsoluteFile().getParent();
    library.load(s);
    music.load(library.getImage());
    music.showBirdie = true;
    music.setText(library.getText());
    tempo.set(map(library.getTempo(), TEMPO_LOW, TEMPO_HIGH, 0, 1));
    tempoLabel.set(library.getTempo()+" bpm");
    notifyPd(library.rhythm);
  }
}

void loadCallback(File f)
{
  String s = f.getAbsolutePath();
  userProgress.loadProgress(s);
}

void saveCallback(File f)
{
  String s = f.getAbsolutePath();
  userProgress.saveProgress(s);
}