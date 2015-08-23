class Config
{
  String home;
  String configPath;
  String modulePath;
  String userfilePath;
  XML configOptions;

  Config()
  {
    home = System.getProperty("user.home");
    configPath = home+"/.latido.config";
    modulePath = "";
    userfilePath = "";
  }

  boolean askReload()
  {
    File f = new File(configPath);
    if (f.exists())
    {
      int n = JOptionPane.showConfirmDialog(null, 
        "Would you like to reload your last session?", 
        "Latido", 
        JOptionPane.YES_NO_OPTION);
      return (n==0);
    }
    return false;
  }

  void load()
  {

    try
    {
      configOptions = loadXML(configPath);
      modulePath = configOptions.getChild("modulepath").getContent();
      userfilePath = configOptions.getChild("userfile").getContent();
    }
    catch (Exception e)
    {
    }
  }

  void create()
  {
    try
    {
      XML newConfig = loadXML("config_template.xml");
      modulePath = dataPath("eyes_and_ears/latido.xml");
      newConfig.getChild("modulepath").setContent(modulePath);
      saveXML (newConfig, configPath);
      configOptions = loadXML(configPath);
    } 
    catch (Exception e) {
    }
  }

  String getModulePath()
  {
    return modulePath;
  }

  String getUserfilePath()
  {
    return userfilePath;
  }  

  void setModulePath (String mp)
  {
    configOptions.getChild("modulepath").setContent(mp);
    saveXML (configOptions, configPath);
  }

  void setUserfilePath (String mp)
  {
    configOptions.getChild("userfile").setContent(mp);
    saveXML (configOptions, configPath);
  }
}