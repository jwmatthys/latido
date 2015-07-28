class MelodyLibrary
{
  String[] lines;
  String indexPath, midiPath, imagePath;
  String midiExt, imageExt; // file extensions contained in second line of latido.txt
  String filename;
  int tempo;
  float countin;
  int currentLine;
  final int lineOffset = 3;

  MelodyLibrary ()
  {
  }

  boolean load (String path)
  {
    indexPath = path+"/latido.txt";
    midiPath = path+"/midi/";
    imagePath = path+"/image/";
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
  }

  String getMidi ()
  {
    return midiPath+filename+"."+midiExt;
  }

  String getImage ()
  {
    return imagePath+filename+"."+imageExt;
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