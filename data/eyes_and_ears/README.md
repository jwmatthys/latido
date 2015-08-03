##How to make your own Latido library

Create a folder, and within it add a file called `latido.xml` and 3 folders named: `image`, `midi`, and `text`.

#####Folder structure
```
YourLibrary/
   |
   latido.xml
   image/
   midi/
   text/
```

####The midi folder
This should contain single line midi files with correct meter and no extra rests at the beginning or end.

####The image folder
This should contain image files with the same name as the midi files. For instance, if your midi file is `myawesomesong.midi`, your image file should be `myawesomesong.jpg`.

If there is no image file associated with the midi file, Latido will just display the default splash screen (the birdie).

####The text folder
The text folder should contain plain text files ending with .txt with the same name as your midi files. This is the text that will be displayed on the screen above the melody. If there is no text file associated with the midi file, the text will be ignored.

####latido.xml
There must be a main file in the top folder called `latido.xml`. The structure of this XML file is:

```
<latido>
  <name>Melodies from Eyes and Ears Anthology by Benjamin Crowell</name>
  <shortname>eyesears</shortname>
  <imageextension>gif</imageextension>
  <midiextension>midi</midiextension>
  <progress>
    <exercise name="intro3" countin="4" tempo="120"/>
    <exercise name="001" countin="4" tempo="120"  rhythm="true"/>
  </progress>
</latido>
```
* The `name` line should be the complete name of the library, for your reference and for proper attribution.
* The `shortname` tag is very important. __It should be a unique ID exactly 8 characters long.__ It will be stored in the user's XML progress file to prevent someone from loading a progress file from a different library.
* The image extension and midi extension tags indicate the file extensions for all of the files in their respective folders.
* All of the exercises are listed under the `<progress>` tag. Each exercise must have:
..* The name (the part of the filename before the .)
..* The tempo (integer values only)
..* The countin (float values; partial beat pickups are allowed, eg. 3.5 (an eighth note pickup into a 4/4 bar) or 1.666666 (an eighth note pickup into a 6/8 bar)

#####Example `latido.xml`

```
<?xml version="1.0" encoding="UTF-8"?>
<latido>
  <name>Bach Chorales SATB</name>
  <shortname>jsbchor4</shortname>
  <imageextension>jpg</imageextension>
  <midiextension>mid</midiextension>
  <progress>
    <exercise name="chorale1-rhythm" countin="4" tempo="60" rhythm="true"/>
    <exercise name="chorale1-s" countin="4" tempo="60"/>
    <exercise name="chorale1-a" countin="4" tempo="60"/>
    <exercise name="chorale1-t" countin="4" tempo="60"/>
    <exercise name="chorale1-b" countin="4" tempo="60"/>
  </progress>
</latido>
```
