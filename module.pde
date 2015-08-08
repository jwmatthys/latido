class MelodyModuleXML
{
  String indexPath, midiPath, imagePath, textPath, filename;
  XML indexFile, shortname, image, midi, progress;
  XML[] exercises;
  int tempo;
  float countin;
  boolean rhythm;
  int numMelodies;
  int currentLine;

  MelodyModuleXML ()
  {
  }

  String load (File index)
  {
    try 
    {
      indexPath = index.getAbsolutePath();
      indexFile = loadXML(indexPath);
      String folder = index.getParentFile().getAbsolutePath();
      shortname = indexFile.getChild("shortname");
      image = indexFile.getChild("imageextension");
      midi = indexFile.getChild("midiextension");
      progress = indexFile.getChild("progress");
      exercises = progress.getChildren("exercise");
      midiPath = folder+"/midi/";
      imagePath = folder+"/image/";
      textPath = folder+"/text/";
      currentLine = 0;
      numMelodies = exercises.length;
      parse (0);
      return shortname.getContent();
    } 
    catch (Exception e)
    {
      showMessageDialog(null, "Could not load Latido module", "Alert", ERROR_MESSAGE);
      return "";
    }
  }

  void parse (int line)
  {
    try
    {
      filename = exercises[line].getString("name");
      tempo = exercises[line].getInt("tempo");
      countin = exercises[line].getFloat("countin");
      rhythm = exercises[line].hasAttribute("rhythm");
    }
    catch (Exception e)
    {
      showMessageDialog(null, "Could not parse Latido module", "Alert", ERROR_MESSAGE);
    }
  }

  void loadNext()
  {
    currentLine++;
    if (currentLine >= exercises.length) currentLine--;
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
    if (i < exercises.length)
    {
      currentLine = i;
      parse(currentLine);
    }
  }

  String getMidi ()
  {
    return midiPath+filename+"."+midi.getContent();
  }

  String getImage ()
  {
    return imagePath+filename+"."+image.getContent();
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

  String getDescription ()
  {
    XML name = indexFile.getChild("name");
    return name.getContent();
  }
}
