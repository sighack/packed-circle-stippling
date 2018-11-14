import processing.pdf.*;
import megamu.mesh.*;

final int LINEAR = 0;
final int SQRT = 8;
final int QUADRATIC = 1;
final int CUBIC = 2;
final int QUARTIC = 3;
final int QUINTIC = 4;
final int SINUSOIDAL = 5;
final int EXPONENTIAL = 6;
final int CIRCULAR = 7;

final int EASE_IN = 0;
final int EASE_OUT = 1;
final int EASE_IN_OUT = 2;

float map3(float value, float start1, float stop1, float start2, float stop2, float v, int when) {
  float b = start2;
  float c = stop2 - start2;
  float t = value - start1;
  float d = stop1 - start1;
  float p = v;
  float out = 0;
  if (when == EASE_IN) {
    t /= d;
    out = c*pow(t, p) + b;
  } else if (when == EASE_OUT) {
    t /= d;
    out = c * (1 - pow(1 - t, p)) + b;
  } else if (when == EASE_IN_OUT) {
    t /= d/2;
    if (t < 1) return c/2*pow(t, p) + b;
    out = c/2 * (2 - pow(2 - t, p)) + b;
  }
  return out;
}

float map2(float value, float start1, float stop1, float start2, float stop2, int type, int when) {
  float b = start2;
  float c = stop2 - start2;
  float t = value - start1;
  float d = stop1 - start1;
  float p = 0.5;
  switch (type) {
  case LINEAR:
    return c*t/d + b;
  case SQRT:
    if (when == EASE_IN) {
      t /= d;
      return c*pow(t, p) + b;
    } else if (when == EASE_OUT) {
      t /= d;
      return c * (1 - pow(1 - t, p)) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*pow(t, p) + b;
      return c/2 * (2 - pow(2 - t, p)) + b;
    }
    break;
  case QUADRATIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      return -c * t*(t-2) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t + b;
      t--;
      return -c/2 * (t*(t-2) - 1) + b;
    }
    break;
  case CUBIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return c*(t*t*t + 1) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t*t + b;
      t -= 2;
      return c/2*(t*t*t + 2) + b;
    }
    break;
  case QUARTIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return -c * (t*t*t*t - 1) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t*t*t + b;
      t -= 2;
      return -c/2 * (t*t*t*t - 2) + b;
    }
    break;
  case QUINTIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t*t*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return c*(t*t*t*t*t + 1) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t*t*t*t + b;
      t -= 2;
      return c/2*(t*t*t*t*t + 2) + b;
    }
    break;
  case SINUSOIDAL:
    if (when == EASE_IN) {
      return -c * cos(t/d * (PI/2)) + c + b;
    } else if (when == EASE_OUT) {
      return c * sin(t/d * (PI/2)) + b;
    } else if (when == EASE_IN_OUT) {
      return -c/2 * (cos(PI*t/d) - 1) + b;
    }
    break;
  case EXPONENTIAL:
    if (when == EASE_IN) {
      return c * pow( 2, 10 * (t/d - 1) ) + b;
    } else if (when == EASE_OUT) {
      return c * ( -pow( 2, -10 * t/d ) + 1 ) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2 * pow( 2, 10 * (t - 1) ) + b;
      t--;
      return c/2 * ( -pow( 2, -10 * t) + 2 ) + b;
    }
    break;
  case CIRCULAR:
    if (when == EASE_IN) {
      t /= d;
      return -c * (sqrt(1 - t*t) - 1) + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return c * sqrt(1 - t*t) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return -c/2 * (sqrt(1 - t*t) - 1) + b;
      t -= 2;
      return c/2 * (sqrt(1 - t*t) + 1) + b;
    }
    break;
  };
  return 0;
}

boolean contains(MPolygon region, int x, int y) {
  int i;
  int j;
  boolean result = false;
  float[][] points = region.getCoords();
  for (i = 0, j = points.length - 1; i < points.length; j = i++) {
    if ((points[i][1] > y) != (points[j][1] > y) &&
      (x < (points[j][0] - points[i][0]) * (y - points[i][1]) / (points[j][1]-points[i][1]) + points[i][0])) {
      result = !result;
    }
  }
  return result;
}

color getColor(MPolygon region)
{
  int xmin = 999999999, xmax = 0, ymin = 999999999, ymax = 0;
  float[][] points = region.getCoords();
  for (int i = 0; i < points.length; i++) {
    if (points[i][0] < xmin) {
      xmin = int(points[i][0]);
      if (xmin < 0)
        xmin = 0;
    }
    if (points[i][0] > xmax) {
      xmax = int(points[i][0]) + 1;
      if (xmax >= img.width)
        xmax = img.width - 1;
    }

    if (points[i][1] < ymin) {
      ymin = int(points[i][1]);
      if (ymin < 0)
        ymin = 0;
    }
    if (points[i][1] > ymax) {
      ymax = int(points[i][1]) + 1;
      if (ymax >= img.height)
        ymax = img.height - 1;
    }
  }

  img_original.loadPixels();
  float r = 0, g = 0, b = 0;
  int npixels = 0;
  for (int y = ymin; y <= ymax; y+=1) {
    for (int x = xmin; x <= xmax; x+=1) {
      if (!contains(region, x, y))
        continue;
      int loc = x + y*width;
      r += red(img_original.pixels[loc]) * red(img_original.pixels[loc]);
      g += green(img_original.pixels[loc]) * green(img_original.pixels[loc]);
      b += blue(img_original.pixels[loc]) * blue(img_original.pixels[loc]);
      npixels++;
    }
  }
  return color(sqrt(r/npixels), sqrt(g/npixels), sqrt(b/npixels));
}

int MARGIN = 1;

PGraphics out;

void drawVoronoi() {
  float[][] points = new float[circles.size()][2];
  for (int i = 0; i < circles.size(); i++) {
    points[i][0] = circles.get(i).x;
    points[i][1] = circles.get(i).y;   
  }
  Voronoi myVoronoi = new Voronoi(points);
  out = createGraphics(width, height);
  out.beginDraw();
  MPolygon[] regions = myVoronoi.getRegions();
  out.noFill();
  out.noStroke();
  for (int i = 0; i < regions.length; i++) {
    color c = getColor(regions[i]);
    out.fill(c);
    out.stroke(c);
    regions[i].draw(out); // draw this shape
  }
  out.endDraw();
  image(out, 0, 0);
}

class Circle {
  float x;
  float y;
  float r;
  Circle(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
  }
  boolean collides(Circle c) {
    float dist = sq(c.x - x) + sq(c.y - y);
    if (dist <= sq(r + c.r + MARGIN))
      return true;
    return false;
  }
}

ArrayList<Circle> circles;

float r;
float minr = 16;
int iteration = 0;
int failed = 0;
int max_failed = 10000000;
//int max_failed = 1000;
ArrayList<Circle> collision_objects;

void find_stroke() {
  float x, y;
  boolean collides;
  
  while (failed < max_failed) {
    x = random(width);
    y = random(height);
    
    float rad = map2(red(img.get(int(x), int(y))), 0, 255, 0.5, 3, QUADRATIC, EASE_IN_OUT); 
    Circle nc = new Circle(x, y, rad);
    Circle nc2 = new Circle(x, y, rad + MARGIN/2);
    
    collides = false;
    collision_objects.clear();
    quad.retrieve(collision_objects, nc2);
    for (int k = 0; k < collision_objects.size(); k++) {
      // Run collision detection algorithm between objects
      if (collision_objects.get(k).collides(nc2)) {
        collides = true;
        break;
      }
    }

    if (collides) {
      failed++;
      if (failed % 100000 == 0)
        println(failed + " tries completed");
      continue;
    }

    //colorMode(HSB, 360, 255, 255);
    //fill(img.get(int(x), int(y)));
    noFill();
    //stroke(0);
    //if (red(img.get(int(x), int(y))) > 128)
    //  stroke(0);
    //ellipse(x, y, 2*rad, 2*rad);
    //ellipse(x, y, 2, 2);
    stroke(0);
    strokeWeight(1);
    point(x, y);
    strokeWeight(0.5);
    ellipse(x, y, rad*2, rad*2);
    points.add(new PVector(x, y));
    circles.add(nc);
    quad.insert(nc);
    if (points.size() % 100 == 0)
      saveFrame("#####.png");
    break;
  }
}

class Rectangle {
  double x, y, w, h;
  Rectangle(double x, double y, double w, double h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  double getX() { 
    return x;
  }
  double getY() { 
    return y;
  }
  double getWidth() { 
    return w;
  }
  double getHeight() { 
    return h;
  }
}

class Quadtree {
  int MAX_OBJECTS = 10;
  int MAX_LEVELS = 20;

  int level;                  /* The level of this QuadTree node */
  int quad;
  ArrayList<Circle> objects;  /* Objects at this level */
  Rectangle bounds;           /* The bounds of this QuadTree node */
  Quadtree[] nodes;           /* Nodes for each child quadrant */
  boolean is_split;

  /* Constructor */
  Quadtree(int pLevel, int pQuad, Rectangle pBounds) {
    level = pLevel;
    quad = pQuad;
    objects = new ArrayList<Circle>();
    bounds = pBounds;
    nodes = new Quadtree[4];
    is_split = false;
  }

  void clear() {
    objects.clear();
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i] != null) {
        nodes[i].clear();
        nodes[i] = null;
        nodes[i].is_split = false;
      }
    }
  }

  void split() {
    double x = bounds.getX();
    double y = bounds.getY();
    double subWidth = bounds.getWidth() / 2;
    double subHeight = bounds.getHeight() / 2;
    
    //println("Splitting new level: " + (level + 1));

    /* Top-right */
    nodes[0] = new Quadtree(level+1, 0, new Rectangle(x + subWidth, y, subWidth, subHeight));
    /* Top-left */
    nodes[1] = new Quadtree(level+1, 1, new Rectangle(x, y, subWidth, subHeight));
    /* Bottom-left */
    nodes[2] = new Quadtree(level+1, 2, new Rectangle(x, y + subHeight, subWidth, subHeight));
    /* Bottom-right */
    nodes[3] = new Quadtree(level+1, 3, new Rectangle(x + subWidth, y + subHeight, subWidth, subHeight));
    
    is_split = true;
  }
  
  boolean intersects(Circle circle, Rectangle rect)
  {
      float circleDistance_x = abs((float)(circle.x - (rect.x + rect.getWidth()/2)));
      float circleDistance_y = abs((float)(circle.y - (rect.y + rect.getHeight()/2)));
  
      if (circleDistance_x > (rect.getWidth()/2 + circle.r)) { return false; }
      if (circleDistance_y > (rect.getHeight()/2 + circle.r)) { return false; }
  
      if (circleDistance_x <= (rect.getWidth()/2)) { return true; } 
      if (circleDistance_y <= (rect.getHeight()/2)) { return true; }
  
      float cornerDistance_sq = sq((float)(circleDistance_x - rect.getWidth()/2)) + sq((float)(circleDistance_y - rect.getHeight()/2));
  
      return (cornerDistance_sq <= sq(circle.r));
  }

  int get_indices(Circle c) {
    int index = 0;

    double xmin = bounds.getX();
    double ymin = bounds.getY();
    double xmax = xmin + bounds.getWidth();
    double ymax = ymin + bounds.getHeight();
    double xmid = xmin + (bounds.getWidth() / 2);
    double ymid = ymin + (bounds.getHeight() / 2);
    double nwidth = bounds.getWidth();
    double nheight = bounds.getHeight();

    double cxmin = c.x - c.r;
    double cxmax = c.x + c.r;
    double cymin = c.y - c.r;
    double cymax = c.y + c.r;

    boolean top =    (cymin <= ymid && cymax >= ymin);
    boolean bottom = (cymax >= ymid && cymin <  ymax);
    boolean left =   (cxmin <= xmid && cxmax >= xmin);
    boolean right =  (cxmax >= xmid && cxmin <  xmax);
    
    top = intersects(c, new Rectangle(xmin, ymin, nwidth, nheight/2));
    bottom = intersects(c, new Rectangle(xmin, ymid, nwidth, nheight/2));
    left = intersects(c, new Rectangle(xmin, ymin, nwidth/2, nheight));
    right = intersects(c, new Rectangle(xmid, ymin, nwidth/2, nheight));
    
    //println(top + "," + bottom + "," + left + "," + right);
    //println("xmin=" + xmin + ",xmax=" + xmax + ",ymin=" + ymin + ",ymax=" + ymax);
    //println("cxmin=" + cxmin + ",cxmax=" + cxmax + ",cymin=" + cymin + ",cymax=" + cymax);
    //println("xmid=" + xmid + ",ymid=" + ymid);

    if (left) {
      if (top)    { index |= 1 << 1; }
      if (bottom) { index |= 1 << 2; }
    }
    if (right) {
      if (top)    { index |= 1 << 0; }
      if (bottom) { index |= 1 << 3; }
    }

    return index;
  }

  void insert(Circle c) {
    if (is_split) {
      int index = get_indices(c);
      if (index != 0) {
        for (int k = 0; k < 4; k++) {
          if ((index & (1 << k)) != 0)
            nodes[k].insert(c);
        }
      }
      return;
    } else {
      objects.add(c);
      //println("Inserting into quadrant " + (quad + 1) + " at level " + level);
      if (objects.size() > MAX_OBJECTS && level < MAX_LEVELS) {
        split();
        while (objects.size() > 0) {
          Circle x = objects.remove(0);
          int index = get_indices(x);
          if (index != 0) {
            for (int k = 0; k < 4; k++) {
              if ((index & (1 << k)) != 0)
                nodes[k].insert(x);
            }
          } else {
            //println("Whoops unable to find place for object at quadrant " + quad + " @ level " + level);
            stroke(0);
            noFill(); 
          }
        }
        objects.clear();
      }
    }
  }

  ArrayList<Circle> retrieve(ArrayList<Circle> ret, Circle c) {
    if (is_split) {
      int index = get_indices(c);
      for (int i = 0; i < 4; i++) {
        if ((index & (1 << i)) != 0)
          nodes[i].retrieve(ret, c);
      }
    } else {
      ret.addAll(objects);
    }
    return ret;
  }
}

PImage img, img_original;
Quadtree quad;

void setup() {
  size(500, 500); //, PDF, "scape" + n + ".pdf");
  img = loadImage("l2.jpg");
  img.filter(GRAY);
  img_original = loadImage("l2.jpg");
  background(255);
  noStroke();
  circles = new ArrayList<Circle>();
  quad = new Quadtree(0, 0, new Rectangle(0, 0, width, height));
  quad.clear();
  r = 128;
  minr = 1;
  failed = 0;
  iteration = 0;
  collision_objects = new ArrayList<Circle>();
  //image(img, 0, 0);
  points = new ArrayList<PVector>(); 
}

ArrayList<PVector> points;

void draw() {
  noStroke();
  if (failed < max_failed)
    find_stroke();
  else {
    //filter(BLUR, 1);
    //drawVoronoi();
    background(255);
    for (int i = 0; i < points.size(); i++) {
      fill(0);
      ellipse(points.get(i).x, points.get(i).y, 2, 2);
    }
    saveFrame("#####.png");
    noLoop();
  }
  //stroke(0);
  //line(0, height/2, width, height/2);
  //line(width/2, 0, width/2, height);
}
