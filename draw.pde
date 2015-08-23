void draw()
{
  background(255);
  paintSidebar();
  if (frameCount == metroOff) metro.deactivate(0);
  if (view == SHOW_MUSIC) music.draw();
}

void paintSidebar()
{
  fill(#E8E8E8); //<>//
  noStroke();
  rect(0, 0, SIDEBAR_WIDTH, height);
  rect(70, 0, width, TOPBAR_HEIGHT);
}

void setView (boolean v)
{
  if (v == SHOW_MUSIC)
  {
    view = SHOW_MUSIC;
    textbox.hide();
  } else
  {
    view = SHOW_TEXT;
    textbox.show();
  }
}

void setText (String path)
{
  try
  {
    String[] paragraph = loadStrings(path);
    String theText = PApplet.join(paragraph, '\n');
    textbox.setText(theText);
  } 
  catch (Exception e)
  {
    textbox.setText(module.getDescription()+"\n\nExercise "+module.getName());
  }
}

void notifyPd(boolean rhythm)
{
  sendOscFloat("/latido/isrhythm", module.rhythm ? 1 : 0);
  sendOscFloat("/latido/tempo", module.getTempo());
  sendOscFloat("/latido/countin", module.getCountin());
  sendOscString("/latido/midifile", module.getMidi());
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