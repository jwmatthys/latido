void mousePressed()
{
  if (mouseButton==RIGHT)
  {
    selectInput("Choose your latido.txt library file", "folderCallback");
  } else {
    if (music.showBirdie)
    {
      music.showBirdie = false;
      play.active = true;
      stop.active = true;
      pitch.active = true;
      replay.active = true;
    }
    if (scorecard.active)
    {
      scorecard.active = false;
      music.showBirdie = true;
    }
  }
}

void transportButton (int v)
{
  OscMessage myMessage = new OscMessage("/latido/transport");
  switch (v)
  {
  case 0:
    myMessage.add("play");
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
  }
  oscP5.send(myMessage, latidoPD);
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

public void scorePD (float f)
{
  println("Score: "+f);
  play.active = false;
  stop.active = false;
  pitch.active = false;
  replay.active = true;
  scorecard.setScore(f);
}

void folderCallback(File f)
{
  //println("callback: "+f.getAbsoluteFile().getParent());
  //if (f == null) library.load("eyes_and_ears");
  String s = f.getAbsoluteFile().getParent();
  library.load(s);
}