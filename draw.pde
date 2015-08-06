void draw()
{
  background(255);
  paintSidebar();
}

void paintSidebar()
{
  fill(#E5E6E8);
  noStroke();
  rect(0, 0, SIDEBAR_WIDTH, height);
  rect(70, 0, width, TOPBAR_HEIGHT);
}

void notifyPd(boolean rhythm)
{
  pd.sendFloat("isrhythm", library.rhythm ? 1.0 : 0.0);
  pd.sendFloat("new-bpm", (float)library.getTempo());
  pd.sendFloat("countin", (float)library.getCountin());
  pd.sendSymbol("midifilename",library.getMidi());
  
  /*
  OscMessage myMessage = new OscMessage("/latido/isrhythm");
  myMessage.add();
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
  */
}