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
  sendOscFloat("/latido/isrhythm", library.rhythm ? 1 : 0);
  sendOscFloat("/latido/tempo", library.getTempo());
  sendOscFloat("/latido/countin", library.getCountin());
  sendOscString("/latido/midifile", library.getMidi());
}

void sendOscString (String tag, String msg)
{
  OscMessage myMessage = new OscMessage(tag);
  myMessage.add(msg);
  oscP5.send(myMessage, latidoPD);
} 

void sendOscFloat (String tag, float f)
{
  OscMessage myMessage = new OscMessage(tag);
  myMessage.add(f);
  oscP5.send(myMessage, latidoPD);
} 

