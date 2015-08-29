class MelodyModuleXML
{
  String indexPath, midiPath, imagePath, textPath, filename;
  XML indexFile, modulekey, image, midi, progress;
  XML[] exercises;
  int tempo;
  float countin;
  boolean rhythm, extracredit;
  int numMelodies;
  int currentLine;

  MelodyModuleXML ()
  {
  }

  boolean load (File index)
  {
    try
    {
      indexPath = index.getAbsolutePath();
      indexFile = loadXML(indexPath);
      String folder = index.getParentFile().getAbsolutePath();
      modulekey = indexFile.getChild("modulekey");
      if (null == modulekey) modulekey = indexFile.getChild("shortname"); // shortname is now deprecated!
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
    }
    catch (NullPointerException e)
    {
      return false;
    }
    catch (Exception e)
    {
      JOptionPane.showMessageDialog(null, "Could not load Latido module\n"+e, "Alert", JOptionPane.ERROR_MESSAGE);
      return false;
    }
    return true;
  }

  String getLibName()
  {
    return modulekey.getContent();
  }

  void parse (int line)
  {
    try
    {
      filename = exercises[line].getString("name");
      tempo = exercises[line].getInt("tempo");
      countin = exercises[line].getFloat("countin");
      rhythm = exercises[line].hasAttribute("rhythm");
      extracredit = exercises[line].hasAttribute("extracredit") || exercises[line].hasAttribute("ec");
    }
    catch (Exception e)
    {
      JOptionPane.showMessageDialog(null, "Could not parse Latido module", "Alert", JOptionPane.ERROR_MESSAGE);
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