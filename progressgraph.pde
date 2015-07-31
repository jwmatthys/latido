public class ProgressGraph
{
  float x, y, w, h;
  int maxScore;
  PImage tree;
  final int stepsToNextImage = 15;
  int currentStep;

  ProgressGraph (float x, float y, float w, float h)
  {
    Interactive.add( this ); // register it with the manager
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    tree = null;
    maxScore = 1500;
    currentStep = 0;
  }

  void draw()
  {
    if (tree != null) image(tree, x, y, w, h);
  }

  void setMaxScore (int s)
  {
    maxScore = s;
  }

  void updateGraph (int s)
  {
    int progress = int(map(s, 0, maxScore, 0, 100));
    if (progress != currentStep)
    {
      int picnum = progress*4;
      String newfn = "tree/output_"+nf(picnum, 3)+".png";
      tree = loadImage(newfn);
      currentStep = progress;
    }
  }
}