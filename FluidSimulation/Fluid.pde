  int N = 256; //<>//
  int iter = 16;
  int SCALE = 4;
  // function to use 1D array and fake the extra two dimensions --> 3D
  int IX(int x, int y) {
    return x + y * N;
  }

class Fluid {
   float dt, diff, visc;
   int size;
   float[] s, density, Vx, Vy, Vx0, Vy0;

  Fluid(float dt, float diffusion, float viscosity) {
    this.dt = dt;
    this.diff = diffusion;
    this.visc = viscosity;

    this.size = N;
    this.s = new float[N * N];
    this.density = new float[N * N];
    this.Vx = new float[N * N];
    this.Vy = new float[N * N];
    this.Vx0 = new float[N * N];
    this.Vy0 = new float[N * N];
  }

  // step method
   void step() {
    float visc = this.visc;
    float diff = this.diff;
    float dt = this.dt;
    float[] Vx = this.Vx;
    float[] Vy = this.Vy;
    float[] Vx0 = this.Vx0;
    float[] Vy0 = this.Vy0;
    float[] s = this.s;
    float[] density = this.density;

    diffuse(1, Vx0, Vx, visc, dt);
    diffuse(2, Vy0, Vy, visc, dt);

    project(Vx0, Vy0, Vx, Vy);

    advect(1, Vx, Vx0, Vx0, Vy0, dt);
    advect(2, Vy, Vy0, Vx0, Vy0, dt);

    project(Vx, Vy, Vx0, Vy0);
    diffuse(0, s, density, diff, dt);
    advect(0, density, s, Vx, Vy, dt);
  }

  // method to add density
   void addDensity(int x, int y, float amount) {
    int index = IX(x, y);
    this.density[index] += amount;
  }

  // method to add velocity
   void addVelocity(int x, int y, float amountX, float amountY) {
    int index = IX(x, y);
    this.Vx[index] += amountX;
    this.Vy[index] += amountY;
  }

  // function to render density
   void renderD() {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        int x = i * SCALE;
        int y = j * SCALE;
        float d = this.density[IX(i, j)];
        fill(((d + 50)), 200,  d);
        noStroke();
        square(x, y, SCALE);
      }
    }
  }
  
  void renderV() {
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        int x = i * SCALE;
        int y = j * SCALE;
        float vx = this.Vx[IX(i, j)];
        float vy = this.Vy[IX(i, j)];
        stroke(0);
        //stroke(255);
        if (!(Math.abs(vx) < 0.1 && Math.abs(vy) <= 0.1)) {
          line((float)x, (float)y, (float)(x + vx * SCALE), (float)(y + vy * SCALE));
        }
      }
    }
  }

  void fadeD() {
    for (int i = 0; i < this.density.length; i++) {
      //float d = density[i];
      this.density[i] = constrain(this.density[i] - 0.2f, 0, 255);
    }
  }

}
