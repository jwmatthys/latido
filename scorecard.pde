public class Scorecard
{
  float x, y, w, h;
  Integrator ix;
  Integrator[] starxi;
  float[] starx;
  float center;
  PFont font;
  int stars;
  PImage star;
  boolean active;
  float targets[] = {0.2, 0.4, 0.55, 0.7, 0.9 };
  float score;
  String thisResult;
  String[][] resultText = {
    { // 0 stars
      "No score.", 
      "Nada!", 
      "I got nothing."
    }, 
    { // 1 star
      "Miserable attempt!", 
      "Ouch! That was ugly.", 
      "Yikes! Not good."
    }, 
    { // 2 stars
      "Not so good.", 
      "Unimpressive.", 
      "Pretty weak."
    }, 
    { // 3 stars
      "Not quite there yet...", 
      "You can do better.", 
      "Close but no cigar."
    }, 
    { // 4 stars
      "Good job!", 
      "That's the way!", 
      "Well done."
    }, 
    { // 5 stars
      "Masterful!", 
      "Excellent!", 
      "Impressive!"
    }
    };

    Scorecard(float x, float y, float w, float h)
    {
      Interactive.add( this ); // register it with the manager
  this.x = x;
  this.y = y;
  this.w = w;
  this.h = h;
  ix = new Integrator(width);
  font = createFont("Helvetica", 48, true);
  star = loadImage("star1.png");
  center = x + w/2;
  active = false;
  score = 0;
  starx = new float[5];
  starxi = new Integrator[5];
  for (int i=0; i<5; i++)
  {
    starxi[i] = new Integrator(width, 0.8, map(i, 0, 4, 0.1, 0.05));
    starx[i] = map(i, -1, 6, x, x+w);
  }
  thisResult = "";
}

void setScore (float f)
{
  score = f;
  stars = numStars(score);
  for (int i=0; i<stars; i++)
  {
    starxi[i].value = width;
    starxi[i].target(starx[i]);
  }
  thisResult = resultText[stars][int(random(3))];
  active = true;
}

private int numStars (float score)
{
  int stars = 0;
  for (int i=0; i<targets.length; i++)
  {
    if (score >= targets[i]) stars = i+1;
  }
  return stars;
}

void draw()
{
  ix.update();
  if (active)
  {
    ix.target(x);
  } else ix.target(width+PADDING);
  if (ix.value < width)
  {
    center = ix.value + w/2;
    strokeWeight(2);
    stroke(0);
    fill(255);
    rect(ix.value, y, w, h, 10);
    strokeWeight(1);
    noStroke();
    fill(0);
    textFont(font);
    textSize(24);
    textAlign(CENTER);
    text("Score", center, y+48);
    text(thisResult, center, y+250);
    textAlign(LEFT);

    for (int i=0; i<stars; i++)
    {
      starxi[i].update();
      image(star, starxi[i].value, y+100);
    }
  }
}
}