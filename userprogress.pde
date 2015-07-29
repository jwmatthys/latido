class UserProgress
{
  XML user;
  XML username;
  XML library;
  XML progress;
  XML[] exercise;

  UserProgress (String playerName, String libName)
  {
    user = loadXML("newuser.xml");
    username = user.getChild("name");
    library = user.getChild("library");
    username.setContent(playerName);
    library.setContent(libName);
    progress = user.getChild("progress");
    exercise = progress.getChildren("exercise");
    //println("user name: "+username.getContent());
    //println("library: "+library.getContent());
  }

  void loadProgress (String f)
  {
    user=loadXML(f);
    username = user.getChild("name");
    library = user.getChild("library");
    progress = user.getChild("progress");
    exercise = progress.getChildren("exercise");
    println("user name: "+username.getContent());
    println("library: "+library.getContent());
  }

  void saveProgress (String f)
  {
    saveXML(user, f);
  }

  void updateInfo (int id, String n)
  {
    exercise = progress.getChildren("exercise");
    if (id>=exercise.length)
    {
      XML newEntry = progress.addChild("exercise");
      newEntry.setString("name", n);
      XML score = newEntry.addChild("score");
      score.setIntContent(0);
      XML time = newEntry.addChild("started");
      newEntry.addChild("completed");
      time.setContent(timeStamp());
    }
  } 

  void updateScore (int id, int stars)
  {
    exercise = progress.getChildren("exercise");
    XML score = exercise[id].getChild("score");
    XML time =  exercise[id].getChild("completed");
    int oldStars = score.getIntContent();
    if (stars > oldStars)
    {
      score.setIntContent(stars);
      if (stars>3) time.setContent(timeStamp());
    }
  }

  int getCurrentStars (int id)
  {
    exercise = progress.getChildren("exercise");
    XML score = exercise[id].getChild("score");
    return score.getIntContent();
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