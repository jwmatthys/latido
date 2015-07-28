class MelodyLibrary
{
  String[] lines;
  String indexPath, midiPath, imagePath, rhythmPath,  textPath;
  String midiExt, imageExt; // file extensions contained in second line of latido.txt
  String filename;
  int tempo;
  float countin;
  int currentLine;
  boolean rhythm;
  final int lineOffset = 3;

  MelodyLibrary ()
  {
  }

  boolean load (String path)
  {
    indexPath = path+"/latido.txt";
    midiPath = path+"/midi/";
    imagePath = path+"/image/";
    rhythmPath = path+"/rhythm/";
    textPath = path+"/text/";
    lines = loadStrings(indexPath);
    if (lines==null) return false;

    println(lines[0]);
    String[] extensions = split(lines[1], ' ');
    imageExt = extensions[0];
    midiExt = extensions[1];
    currentLine = 0;
    parse (0);
    return true;
  }

  void parse (int line)
  {
    String[] current = split(lines[line+lineOffset], ' ');
    filename = current[0];
    tempo = int(current[1]);
    countin = float(current[2]);
    if (current.length>3) rhythm = true;
  }

  String getMidi ()
  {
    return midiPath+filename+"."+midiExt;
  }

  String getImage ()
  {
    return imagePath+filename+"."+imageExt;
  }
  
  String getRhythm ()
  {
    return rhythmPath+filename+".txt";
  }

 String getText ()
  {
    return textPath+filename+".txt";
  }
  
  int getTempo ()
  {
    return tempo;
  }

  float getCountin ()
  {
    return countin;
  }
}