class UserProgress
{
  XML user;
  XML username;
  XML library;
  XML progress;
  XML[] exercise;
  int nextUnpassed;
  String secretKey;
  String extension=".latido";

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
      secretKey = library.getContent().substring(0, 8);
      return true;
    } 
    catch (Exception e) {
      println(e);
    }
    return false;
  }

  void save (String f)
  {
    try
    {
      if (f.substring(f.length()-extension.length(), f.length()) != ".latido")
      {
        f += extension;
      }
      byte[] data = user.toString().getBytes();
      saveBytes(f, cipher(secretKey, data));
    } 
    catch (Exception e) {
      println(e);
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