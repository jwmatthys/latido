class CalculateScore
{
  int stars;
  float floatScore;

  final float targets[] = {
    0.2, 0.4, 0.55, 0.7, 0.9
  };

  final String[][] resultText =
  {
    { // 0 stars
      "No score.", 
      "Nada!", 
      "I got nothing."
    }
    , 
    { // 1 star
      "Miserable attempt!", 
      "Ouch! That was ugly.", 
      "Yikes! Not good."
    }
    , 
    { // 2 stars
      "Not so good.", 
      "Unimpressive.", 
      "Pretty weak."
    }
    , 
    { // 3 stars
      "Not quite there yet...", 
      "You can do better.", 
      "Close but no cigar."
    }
    , 
    { // 4 stars
      "Good job!", 
      "That's the way!", 
      "Well done."
    }
    , 
    { // 5 stars
      "Masterful!", 
      "Excellent!", 
      "Impressive!"
    }
  };

  CalculateScore()
  {
    floatScore = 0;
    stars = 0;
  }

  int get (float f)
  {
    floatScore = f;
    stars = numStars(f);
    return stars;
  }

  int get ()
  {
    return stars;
  }

  String starText (int s)
  {
    return resultText[stars][int(random(3))];
  }

  private int numStars (float s)
  {
    int result = 0;
    for (int i=0; i<targets.length; i++)
    {
      if (s >= targets[i]) result = i+1;
    }
    return result;
  }
}

class Stars
{
  Stars()
  {
  }

  void draw()
  {
  }
}

