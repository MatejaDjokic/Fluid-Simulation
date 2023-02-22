/*
    Function of diffuse
    - b : int
    - x : float[]
    - x0 : float[]
    - diff : float
    - dt : float
*/
void diffuse(int b, float[] x, float[] x0, float diff, float dt) {
    float a = dt * diff * (N - 2) * (N - 2);
    lin_solve(b, x, x0, a, 1 + 6 * a);
}

/*
    Function of solving linear differential equation
    - b : int
    - x : float[]
    - x0 : float[]
    - a : float
    - c : float
*/
void lin_solve(int b, float[] x, float[] x0, float a, float c) {
    float cRecip = 1.0 / c;
    for (int t = 0; t < iter; t++) {
        for (int j = 1; j < N - 1; j++) {
            for (int i = 1; i < N - 1; i++) {
                x[IX(i, j)] = (x0[IX(i, j)] + a * (x[IX(i + 1, j)] + x[IX(i - 1, j)] + x[IX(i, j + 1)] + x[IX(i, j - 1)])) * cRecip;
            }
        }
        set_bnd(b, x);
    }
}

/*
    Function of project : This operation runs through all the cells and fixes them up so everything is in equilibrium.
    - velocX : float[]
    - velocY : float[]
    = p : float[]
    - div : float[]
*/
void project(float[] velocX, float[] velocY, float[] p, float[] div) {
    for (int j = 1; j < N - 1; j++) {
        for (int i = 1; i < N - 1; i++) {
            div[IX(i, j)] = (-0.5 * (velocX[IX(i + 1, j)] - velocX[IX(i - 1, j)] + velocY[IX(i, j + 1)] - velocY[IX(i, j - 1)])) / N;
            p[IX(i, j)] = 0;
        }
    }
    set_bnd(0, div);
    set_bnd(0, p);
    lin_solve(0, p, div, 1, 6);

    for (int j = 1; j < N - 1; j++) {
        for (int i = 1; i < N - 1; i++) {
            velocX[IX(i, j)] -= 0.5 * (p[IX(i + 1, j)] - p[IX(i - 1, j)]) * N;
            velocY[IX(i, j)] -= 0.5 * (p[IX(i, j + 1)] - p[IX(i, j - 1)]) * N;
        }
    }
    set_bnd(1, velocX);
    set_bnd(2, velocY);
}
/*
    Function of advect: responsible for actually moving things around
    - b : int
    - d : float[]
    - d0 : float[]
    - velocX : float[]
    - velocY : float[]
    - dt : float[]
*/
void advect(int b, float[] d, float[] d0, float[] velocX, float[] velocY, float dt) {
    int i0, i1, j0, j1;

    float dtx = dt * (N - 2);
    float dty = dt * (N - 2);

    float s0, s1, t0, t1;
    float tmp1, tmp2, x, y;

    float Nfloat = N - 2;
    float ifloat, jfloat;
    int i, j;

    for (j = 1, jfloat = 1; j < N - 1; j++, jfloat++) {
        for (i = 1, ifloat = 1; i < N - 1; i++, ifloat++) {
            tmp1 = dtx * velocX[IX(i, j)];
            tmp2 = dty * velocY[IX(i, j)];
            x = ifloat - tmp1;
            y = jfloat - tmp2;

            if (x < 0.5) x = 0.5f;
            if (x > Nfloat + 0.5) x = Nfloat + 0.5f;
            i0 = (int)Math.floor(x);
            i1 = i0 + 1;
            if (y < 0.5) y = 0.5f;
            if (y > Nfloat + 0.5) y = Nfloat + 0.5f;
            j0 = (int)Math.floor(y);
            j1 = j0 + 1;

            s1 = x - i0;
            s0 = 1 - s1;
            t1 = y - j0;
            t0 = 1 - t1;

            int i0i = (int)i0;
            int i1i = (int)i1;
            int j0i = (int)j0;
            int j1i = (int)j1;

            d[IX(i, j)] =
                s0 * (t0 * d0[IX(i0i, j0i)] + t1 * d0[IX(i0i, j1i)]) +
                s1 * (t0 * d0[IX(i1i, j0i)] + t1 * d0[IX(i1i, j1i)]);
        }
    }

    set_bnd(b, d);
}

/*
    Function of dealing with situation with boundary cells.
    - b : int
    - x : float[]
*/
void set_bnd(int b, float[] x) {
  for (int i = 1; i < N - 1; i++) {
    x[IX(i, 0)] = b == 2 ? -x[IX(i, 1)] : x[IX(i, 1)];
    x[IX(i, N - 1)] = b == 2 ? -x[IX(i, N - 2)] : x[IX(i, N - 2)];
  }
  for (int j = 1; j < N - 1; j++) {
    x[IX(0, j)] = b == 1 ? -x[IX(1, j)] : x[IX(1, j)];
    x[IX(N - 1, j)] = b == 1 ? -x[IX(N - 2, j)] : x[IX(N - 2, j)];
  }

  x[IX(0, 0)] = 0.5f * (x[IX(1, 0)] + x[IX(0, 1)]);
  x[IX(0, N - 1)] = 0.5f * (x[IX(1, N - 1)] + x[IX(0, N - 2)]);
  x[IX(N - 1, 0)] = 0.5f * (x[IX(N - 2, 0)] + x[IX(N - 1, 1)]);
  x[IX(N - 1, N - 1)] = 0.5f * (x[IX(N - 2, N - 1)] + x[IX(N - 1, N - 2)]);
}
