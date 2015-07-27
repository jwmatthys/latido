public class Scorecard
{
  float x, y, w, h;
  float center;
  PFont font;
  int stars;
  PImage star;
  boolean active;
  float targets[] = {0.2, 0.4, 0.55, 0.7, 0.9 };
  float score;

  Scorecard(float x, float y, float w, float h)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    font = createFont("Helvetica", 24, true);
    star = loadImage("star1.png");
    center = x + w/2;
    active = false;
    score = 0;
  }
 
  void setScore (float f)
  {
    score = f;
    stars = numStars(score);
    println("stars: "+stars);
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
    if (active)
    {
      strokeWeight(2);
      stroke(0);
      fill(255);
      rect(x, y, w, h, 10);
      strokeWeight(1);
      noStroke();
      fill(0);
      textFont(font);
      textSize(24);
      textAlign(CENTER);
      text("Latido Score", center, y+48);
      textAlign(LEFT);
    }
  }
}