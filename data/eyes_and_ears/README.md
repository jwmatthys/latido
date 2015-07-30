##How to make your own Latido library

Create a folder, within it 3 folders: image, midi, and text, and a file called `latido.txt`.

```
YourLibrary/
   |
   latido.txt
   image/
   midi/
   text/
```

####The midi folder
This should contain single line midi files with correct meter and no extra rests in the beginning or end.

####The image folder
This should contain image files with the same name as the midi files. For instance, if your midi file is `myawesomesong.midi`, your image file should be `myawesomesong.jpg`.

If there is no image file associated with the midi file, Latido will just display the default splash screen (the birdie).

####The text folder
The text folder should contain plain text files ending with .txt with the same name as your midi files. This is the text that will be displayed on the screen above the melody. If there is no text file associated with the midi file, the text will be ignored.

####latido.txt
There must be a main file in the top folder called latido.txt. This file has the following layout:

* The first line should be the complete name of the library. It will be stored in the user's XML progress file to prevent someone from loading a progress file from a different library.
* The second line should list the file extensions of the images and the midi files.
  - for instance,
  `gif mid`
* The third line can be anything. It can be blank, or you can make a note for yourself.

The rest of the file should follow this syntax for every line:
__filename tempo countin *optional:* R *(for rhythm exercises)*__

###Example `latido.txt`

```
Bach Chorales SATB
jpg midi
------------------
chorale1S 60 4
chorale1A 60 4
chorale1T 60 4
chorale1B 60 4
chorale2S 88 3 R
chorale2S 88 3
chorale2A 88 3
chorale2T 88 3
chorale2B 88 3
```
