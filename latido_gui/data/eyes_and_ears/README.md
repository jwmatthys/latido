How to make your own Latido library

You need 3 folders: image, midi, and rhythms.

The midi folder should contain single line midi files with correct meter and no extra rests in the beginning or end.

The image folder should contain image files with the same name as the midi files. For instance, if your midi file is myawesomesong.midi, your image file should be myawesomesong.jpg.

If there is no image file associated with the midi file, Latido will just display the default splash screen (the birdie).

The rhythms folder contains txt files, each with its own rhythm written in custom Latido rhythm notation. You can read about it in RHYTHMS.md, located in the rhythms folder.

There must be a main file in the top folder called latido.txt. This file has the following layout:

The first line should be a comment or acknowledgement. It will be shown on the Latido screen when it loads.
The second line should list the file extensions of the images and the midi files.
The third line can be anything.
The rest of the file should follow this syntax for every line:
Filename tempo countin optional:rhythm

