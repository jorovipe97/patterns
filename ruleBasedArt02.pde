/*
 * Creative Coding
 * Spinning top: curved motion with sin() and cos()
 * by Indae Hwang and Jon McCormack
 * Updated 2016
 * Copyright (c) 2014-2016 Monash University
 *
 * This sketch is the first cut at translating the motion of a spinning top
 * to trace a drawing path. This sketch traces a path using sin() and cos()
 *
 */

float[] x, y;      // current drawing position
float[] dx, dy;    // change in position at each frame
float rad;       // for updating the angle of rotation each frame
final int numberOfPoints = 2;

float max = 1;   // setting a boundary for spinning top to draw within
float min = 0.5;
float[] _t; // Tiempo para configurar el ruido de perlin

/*
  TODO:
 1. Utilizar arreglos para generar mas de un trompo
 4. Reglas de variacion de color, que los tonos varien de acuerdo a la posicion del mouse | listo
 Si el mouse se pone cerca del borde inferior el dibujo tendera a ser negro
 */

void setup() {
  size(500, 500);
  // Codigo espaguetti para instanciar las propiedades importantes de cada punto
  x = new float[numberOfPoints];
  y = new float[numberOfPoints];
  dx = new float[numberOfPoints];
  dy = new float[numberOfPoints];
  _t = new float[numberOfPoints];


  // initial position in the centre of the screen
  for (int i = 0; i < numberOfPoints; i++) {
    // Inicializa la posicion de todos los puntos en el centro
    x[i] = width/2;
    y[i] = height/2;
  }

  for (int i = 0; i < numberOfPoints; i++) {
    // Inicializa la direccion en la que se debe mover cada punto
    // dx and dy are the small change in position each frame
    dx[i] = random(-1, 1);
    dy[i] = random(-1, 1);
  }

  background(0);
}


void draw() {
  // blend the old frames into the background
  //background(0);
  blendMode(ADD);
  fill(0, 5);
  rect(0, 0, width, height);
  rad = radians(frameCount);

  // Itera por todos los puntos
  for (int i = 0; i < numberOfPoints; i++) {

    if (mousePressed == true) {
      // calculate new position
      // En este caso el mouseX determina la velocidad
      x[i] += dx[i]*floor(map(mouseX, 0, width, 1, 4)); // integrador de euler: x_new = x + dx*v_x;
      y[i] += dy[i]*floor(map(mouseY, 0, height, 1, 4));
      // la velocidad es determinada por la posicion del mouse cuando se da click
    } else {
      // calculate new position
      x[i] += dx[i]; // integrador de euler: x_new = x + dx*v_x;
      y[i] += dy[i];
      // la velocidad es constante e igual a 1px/frame
    }

    //When the shape hits the edge of the window, it reverses its direction and changes velocity
    if (x[i] > width-100 || x[i] < 100) {
      // si el step es positivo pongalo negativo, si es negativo pongalo positivo
      dx[i] = dx[i] > 0 ? -random(min, max) : random(min, max);
    }

    // Si se acerca por arriba o por abajo al borde de la pantall
    if (y[i] > height-100 || y[i] < 100) {
      // cambia la dirección del paso
      dy[i] = dy[i] > 0 ? -random(min, max) : random(min, max);
    }

    // Si hay un punto en el siguiente indice
    if (i < numberOfPoints - 1) {
      float distance = dist(x[i], y[i], x[i+1], y[i+1]);
      // Si la distancia  al siguiente punto del indice es menor a 200px 
      if (distance < 200) {
        // Entonces quiero que este punto cambie de direccion
        dx[i] = dx[i] > 0 ? -random(min, max) : random(min, max);
        dy[i] = dy[i] > 0 ? -random(min, max) : random(min, max);
      }
    }

    float bx, by;
    // Usa operadores bitwise para determinar si el indice del punto es par o impar
    // 3 equivale a 11 en binario
    if ((i & 1) == 1) {
      // Es impar
      //offset hand from the centre
      bx = x[i] + 100 * sin(rad);  
      //float by = y + 100 * cos(rad);
      by = sin(rad) + random(40)*cos(rad)%40 + (height/2);
    } else {
      // Es par
      //offset hand from the centre
      by = x[i] + 100 * sin(rad);  
      //float by = y + 100 * cos(rad);
      bx = sin(rad) + random(40)*cos(rad)%40 + (height/2);
    }

    fill(180);

    float radius = 100 * sin(rad*0.1);
    float handX = bx + radius * sin(rad*3);
    float handY = by + radius * cos(rad*3);

    int _noise1 = (int) map(noise(_t[i]), 0, 1, 0, map(mouseX, 0, width, 0, 125));
    int _noise2 = (int) map(noise(_t[i]+55), 0, 1, 52, map(mouseY, 0, height, 0, 255));
    int _noise3 = (int) map(noise(_t[i]+333), 0, 1, 0, 255);
    stroke(_noise1, _noise2, _noise3, 255);
    _t[i] += 0.01;

    //stroke(255,150);
    line(bx, by, handX, handY);
    //ellipse(handX, handY, 2, 2);
    ellipse(bx, by, 2, 2);
  }
}