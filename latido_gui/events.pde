void transportButton (int v)
{
  OscMessage myMessage = new OscMessage("/latido/transport");
  switch (v)
  {
  case 0:
    myMessage.add("play");
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
  tempoVal = (int)map (v,0,1,TEMPO_LOW,TEMPO_HIGH);
  String l = tempoVal + " BPM";
  tempoLabel.set (l);
  OscMessage myMessage = new OscMessage("/latido/tempo");
  myMessage.add(tempoVal);
  oscP5.send(myMessage, latidoPD);
}

public void micPD (float f)
{
  micLevel.set(sqrt(f*0.01));
}

public void tempoPD (int t)
{
  tempoLabel.set(t+" BPM");
  tempo.set(map(t,TEMPO_LOW,TEMPO_HIGH,0,1));
}

public void metroPD (int b)
{
  metro.bang(b);
}

public void metroStatePD (int s)
{
  metro.setState(s);
}