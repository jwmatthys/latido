class UserProgress
{
  XML user;
  XML username;
  XML library;
  XML progress;
  XML[] exercise;
  int nextUnpassed;

  UserProgress (String playerName, String libName)
  {
    user = loadXML("newuser.xml");
    username = user.getChild("name");
    library = user.getChild("library");
    progress = user.getChild("progress");
    exercise = progress.getChildren("exercise");
    username.setContent(playerName);
    library.setContent(libName);
    nextUnpassed = 0;
  }

  void load (String f)
  {
    user=loadXML(f);
    username = user.getChild("name");
    library = user.getChild("library");
    progress = user.getChild("progress");
    exercise = progress.getChildren("exercise");
    int id;
    for (id = 0; id<exercise.length; id++)
    {
      int testval = exercise[id].getIntContent();
      if (testval < 4)
      {
        break;
      }
    }
    nextUnpassed = id;
  }

  void save (String f)
  {
    saveXML(user, f);
  }

  void updateInfo (int id, String n)
  {
    if (id>=exercise.length)
    {
      XML newEntry = progress.addChild("exercise");
      newEntry.setString("id", n);
      newEntry.setString("started", timeStamp());
      newEntry.setIntContent(0);
      exercise = progress.getChildren("exercise");
    }
  } 

  void updateScore (int id, int stars)
  { 
    int oldStars = exercise[id].getIntContent();
    if (stars > oldStars)
    {
      exercise[id].setIntContent(stars);
      if (stars > 3) exercise[id].setString("completed", timeStamp());
    }
  }

  int getCurrentStars (int id)
  {
    return exercise[id].getIntContent();
  }

  String getLibraryName()
  {
    return library.getContent();
  }

  String timeStamp()
  {
    return nf(hour(), 2)+":"+nf(minute(), 2)+" "+nf(month(), 2)+"/"+nf(day(), 2)+"/"+nf(year(), 2);
  }
}