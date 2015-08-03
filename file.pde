class MelodyLibrary
{
  String[] lines;
  String indexPath, midiPath, imagePath, textPath;
  String midiExt, imageExt; // file extensions contained in second line of latido.txt
  String filename;
  int tempo;
  float countin;
  int currentLine;
  boolean rhythm;
  int numMelodies;
  final int lineOffset = 3;

  MelodyLibrary ()
  {
  }

  String load (String path)
  {
    try 
    {
      indexPath = dataPath(path)+"/latido.txt";
      midiPath = dataPath(path)+"/midi/";
      imagePath = dataPath(path)+"/image/";
      textPath = dataPath(path)+"/text/";
      lines = loadStrings(indexPath);
      String[] extensions = split(lines[1], ' ');
      imageExt = extensions[0];
      midiExt = extensions[1];
      currentLine = 0;
      numMelodies = lines.length - lineOffset;
      parse (0);
      return lines[0];
    } 
    catch (Exception e)
    {
      showMessageDialog(null, "Could not load Latido library", "Alert", ERROR_MESSAGE);
      return "";
    }
  }

  void parse (int line)
  {
    String[] current = split(lines[line+lineOffset], ' ');
    filename = current[0];
    tempo = int(current[1]);
    countin = float(current[2]);
    rhythm = (current.length > 3);
  }

  void loadNext()
  {
    currentLine++;
    if (currentLine >= lines.length - lineOffset) currentLine--;
    parse(currentLine);
  }

  void loadPrevious()
  {
    currentLine--;
    if (currentLine < 0) currentLine++;
    parse(currentLine);
  }

  void loadSpecific(int i)
  {
    if (i < lines.length - lineOffset)
    {
      currentLine = i;
      parse(currentLine);
    }
  }

  String getMidi ()
  {
    return midiPath+filename+"."+midiExt;
  }

  String getImage ()
  {
    return imagePath+filename+"."+imageExt;
  }

  String getText ()
  {
    return textPath+filename+".txt";
  }

  String getName ()
  {
    return filename;
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