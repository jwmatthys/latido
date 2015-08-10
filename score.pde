class StarCanvas extends Canvas
{
  boolean loaded = false;
  final int w = width;
  Stars stars;
  PFont biggerFont;
  String theText;
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

  public void setup(PGraphics p)
  {
  }

  public void draw(PGraphics p)
  {
    if (!loaded)
    {
      stars = new Stars(HACK_STARS, 0, width*2/3, 165, 25, 500);
      theText = resultText[HACK_STARS][(int)random(3)];
      biggerFont = loadFont("Inconsolata-72.vlw");
      textFont(biggerFont, 36);
      textAlign(CENTER);
      loaded = true;
    } else
    {
    textFont(biggerFont, 36);
    textAlign(CENTER);
      if (theText == null) theText = resultText[HACK_STARS][(int)random(3)];
      noStroke();
      fill (0);
      text("Score", w/3, 70);
      text(theText, w/3, 300);
      stars.draw();
    }
  }
}

class CalculateScore
{
  int stars;
  float floatScore;

  final float targets[] = {
    0.2, 0.4, 0.55, 0.7, 0.9
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
  final int numStars;
  final int rotation;
  final float radius;
  final float x0, x1, y;
  Integrator[] xpos;
  final int[] targetTime;
  PImage thumb;

  Stars(int s, float x0, float x1, float y, float r, int rate)
  {
    numStars = s;
    radius = r;
    this.x0 = x0;
    this.x1 = x1;
    this.y = y;
    xpos = new Integrator[5];
    targetTime = new int[5];
    for (int i=0; i<5; i++)
    {
      targetTime[i] = millis() + (i * rate);
      xpos[i] = new Integrator(width+radius, 0.8, 0.1);
      xpos[i].target(map (i, -1, numStars, x0, x1));
      xpos[i].targeting = false;
    }
    rotation = constrain (s-3, 0, 2);
    thumb = loadImage("icons/thumbsdown.png");
  }

  void draw()
  {
    if (numStars > 0)
    {
      for (int i=0; i<numStars; i++)
      {
        if (millis() >= targetTime[i]) xpos[i].targeting = true;
        xpos[i].update();
        drawStar(xpos[i].value, y, radius, rotation*frameCount*-1, #EE0000);
      }
    } else
    {
      image(thumb, (x1-thumb.width)/2, y-35);
    }
  }

  void drawStar(float x, float y, float radius, int rotation, color col)
  {
    float pointOneX, pointOneY;
    float pointTwoX, pointTwoY;
    float pointThreeX, pointThreeY;
    float pointFourX, pointFourY;
    float pointFiveX, pointFiveY;
    float angle; // in radians

    angle = toRadians(18 + rotation);    
    pointOneX = cos(angle)*radius; // Horizontal difference from centre of circle that would circumscribe the star
    pointOneX = pointOneX + x;    // Set 'x' relative to left side of canvas, not just centre of the circle
    pointOneY = sin(angle)*radius;    // Vertical difference from centre of circle that would circumscribe the star 
    pointOneY = (pointOneY * -1) + y;    // Set 'y' relative to top edge of canvas, not just centre of the circle


    // Second point
    angle = toRadians(90 + rotation);    
    pointTwoX = cos(angle)*radius;
    pointTwoX = pointTwoX + x;
    pointTwoY = sin(angle)*radius;
    pointTwoY = (pointTwoY * -1) + y;

    // Third point
    angle = toRadians(162 + rotation);    
    pointThreeX = cos(angle)*radius;
    pointThreeX = pointThreeX + x;
    pointThreeY = sin(angle)*radius;
    pointThreeY = (pointThreeY * -1) + y;

    // Fourth point
    angle = toRadians(234 + rotation);    
    pointFourX = cos(angle)*radius;
    pointFourX = pointFourX + x;
    pointFourY = sin(angle)*radius;
    pointFourY = (pointFourY * -1) + y;

    // Fifth point
    angle = toRadians(306 + rotation);    
    pointFiveX = cos(angle)*radius;
    pointFiveX = pointFiveX + x;
    pointFiveY = sin(angle)*radius;
    pointFiveY = (pointFiveY * -1) + y;

    noStroke();
    fill (col);
    beginShape();
    vertex(pointOneX, pointOneY);
    vertex(pointThreeX, pointThreeY);
    vertex(pointFiveX, pointFiveY);
    vertex(pointTwoX, pointTwoY);
    vertex(pointFourX, pointFourY);
    vertex(pointOneX, pointOneY);
    endShape();
  }

  private float toRadians(float angleInDegrees)
  {
    return (angleInDegrees*TWO_PI)/360;
  }
}

