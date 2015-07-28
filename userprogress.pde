class UserProgress
{
  XML user;
  XML username;
  XML library;
  XML progress;
  XML[] exercise;

  UserProgress ()
  {
    user = loadXML("newuser.xml");
    username = user.getChild("name");
    library = user.getChild("library");
    progress = user.getChild("progress");
    exercise = progress.getChildren("exercise");
    println("user name: "+username.getContent());
    println("library: "+library.getContent());
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
  
  void updateProgress (int id, int stars)
  {
    exercise[id].setInt("id",id);
    exercise[id].setIntContent(stars);
  }
}