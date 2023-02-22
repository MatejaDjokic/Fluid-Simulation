
   Fluid fluid;
   float t = 0;

   void settings() {
    size(1000, 1000);
  }

   void setup() {
    frameRate(60);
    fluid = new Fluid(0.3f, 0.0000001f, 0.00000000000000000001f);
  }

   void draw() {
    stroke(0);
    strokeWeight(2);

    //int cx = (int) ((0.5 * width) / SCALE);
    //int cy = (int) ((0.5 * height) / SCALE);
    int cx = (int) ((1 * map(mouseX, 0, width, 10, width-10) / SCALE));
    int cy = (int) ((1 * map(mouseY, 0, height, 10, height-10)) / SCALE);
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
          if (mousePressed && mouseButton == LEFT) {
        fluid.addDensity(cx + i, cy + j, random((i+j)*(i+j)*500, (i+j)*(i+j)*1500));
         }
      }
    }

    for (int i = 0; i < 2; i++) {
      float angle = noise(t) * TWO_PI * 2;
      PVector v = PVector.fromAngle(angle);
      v.mult(0.2f);
      t += 0.01;
      fluid.addVelocity(cx, cy, v.x, v.y);
    }

    fluid.step();
    fluid.renderD();
  }
