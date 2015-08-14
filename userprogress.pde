class UserProgress
{
  XML user;
  XML username;
  XML module;
  XML progress;
  XML score;
  XML[] exercise;
  String secretKey;
  String extension=".latido";

  UserProgress (String playerName, String libName)
  {
    user = loadXML("newuser.xml");
    username = user.getChild("name");
    module = user.getChild("module");
    progress = user.getChild("progress");
    score = user.getChild("score");
    exercise = progress.getChildren("exercise");
    username.setContent(playerName);
    module.setContent(libName);
    secretKey = libName.substring(0, 8);
  }

  boolean load (String f)
  {
    try
    {
      byte[] data = loadBytes(f);
      File tempFile = File.createTempFile("guido", "arrezo");
      saveBytes(tempFile, decipher(secretKey, data));
      user=loadXML(tempFile.getAbsolutePath());
      tempFile.delete();
      username = user.getChild("name");
      module = user.getChild("module");
      progress = user.getChild("progress");
      score = user.getChild("score");
      exercise = progress.getChildren("exercise");
      secretKey = module.getContent().substring(0, 8);
      return true;
    } 
    catch (Exception e) {
      JOptionPane.showMessageDialog(null, "Could not load Latido user file", "Alert", JOptionPane.ERROR_MESSAGE);
    }
    return false;
  }

  void save (String f)
  {
    try
    {
      if (!f.substring(f.length()-extension.length(), f.length()).equals(".latido"))
      {
        f += extension;
      }
      byte[] data = user.toString().getBytes();
      saveBytes(f, cipher(secretKey, data));
    } 
    catch (Exception e) {
      JOptionPane.showMessageDialog(null, "Could not save Latido user file", "Alert", JOptionPane.ERROR_MESSAGE);
    }
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
      int oldScore = score.getIntContent();
      score.setIntContent(oldScore + stars - oldStars);
      if (stars > 3 && oldStars <= 3)
      {
        exercise[id].setString("completed", timeStamp());
      }
    }
  }

  int getCurrentStars (int id)
  {
    return exercise[id].getIntContent();
  }

  int getTotalScore ()
  {
    return score.getIntContent();
  }

  String getModuleName()
  {
    return module.getContent();
  }

  String timeStamp()
  {
    return nf(hour(), 2)+":"+nf(minute(), 2)+" "+nf(month(), 2)+"/"+nf(day(), 2)+"/"+nf(year(), 2);
  }

  int getNextUnpassed()
  {
    for (int id = 0; id<exercise.length; id++)
    {
      int testval = exercise[id].getIntContent();
      if (testval < 4)
      {
        return id;
      }
    }
    return exercise.length - 1;
  }

  /**
   * Encrypt data
   * @param secretKey -   a secret key used for encryption
   * @param data      -   data to encrypt
   * @return  Encrypted data
   * @throws Exception
   */
  byte[] cipher(String secretKey, byte[] data) throws Exception {
    // Key has to be of length 8
    if (secretKey == null || secretKey.length() != 8)
      throw new Exception("Invalid key length - 8 bytes key needed!");

    SecretKey key = new SecretKeySpec(secretKey.getBytes(), "DES");
    Cipher cipher = Cipher.getInstance("DES");
    cipher.init(Cipher.ENCRYPT_MODE, key);

    return cipher.doFinal(data);
  }

  /**
   * Decrypt data
   * @param secretKey -   a secret key used for decryption
   * @param data      -   data to decrypt
   * @return  Decrypted data
   * @throws Exception
   */
  byte[] decipher(String secretKey, byte[] data) throws Exception {
    // Key has to be of length 8
    if (secretKey == null || secretKey.length() != 8)
      throw new Exception("Invalid key length - 8 bytes key needed!");

    SecretKey key = new SecretKeySpec(secretKey.getBytes(), "DES");
    Cipher cipher = Cipher.getInstance("DES");
    cipher.init(Cipher.DECRYPT_MODE, key);

    return cipher.doFinal(data);
  }
}