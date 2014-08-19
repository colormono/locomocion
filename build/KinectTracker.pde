class KinectTracker {

  //.h
  int kw = 640; // Kinect width
  int kh = 480; // Kinect height

  PVector loc; // Raw location
  int[] depth; // Depth data
  PImage display; // Kinect image

  // Constructor
  KinectTracker() {
    kinect.start();
    kinect.enableDepth(true);
    kinect.processDepthImage(true);
    display = createImage(kw, kh, PConstants.RGB);
    loc = new PVector(0, 0);
  }

  // Tracker
  void track() {

    // Conseguir la información de profundidad como un array de números enteros
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    float sumXPlay = 0;
    float sumYPlay = 0;
    float countPlay = 0;

    for (int x = 0; x < kw; x++) {
      for (int y = 0; y < kh; y++) {

        // Espejar la imagen
        int offset = kw-x-1+y*kw;

        // Agarrar la información de profundidad en crudo
        int rawDepth = depth[offset];

        // Comparar contra el threshold
        if ( rawDepth < thresholdPlay ) {
          sumXPlay += x;
          sumYPlay += y;
          countPlay++;
        }
        if ( rawDepth < threshold && rawDepth > thresholdPlay+thresholdEspacio ) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }

    // Si encuentra algo en el timeline usa el timeline
    if ( count != 0 ) {
      // Actualizar la posición del blob
      loc = new PVector( map(sumX/count, 0, 640, 0, width), map(sumY/count, 0, 480, 0, height) );
      secuencias[secuenciaActual].posicion = "timeline";
    }
    // Sino verifica que no haya nadie en el play 
    else if ( countPlay != 0 ) {
      loc = new PVector( map(sumXPlay/countPlay, 0, 640, 0, width), map(sumYPlay/countPlay, 0, 480, 0, height) );
      secuencias[secuenciaActual].posicion = "play";
    }
    // Sino lo tira a un costado 
    else {
      // Estado esperando
      loc = new PVector( 0, 0 );
      secuencias[secuenciaActual].posicion = "timeline";
    }
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kw; x++) {
      for (int y = 0; y < kh; y++) {

        // Espejar imagen
        int offset = kw-x-1+y*kw;

        // Capturar data en crudo del punto
        int rawDepth = depth[offset];
        int pix = x+y*display.width;

        if ( rawDepth < thresholdPlay ) {
          // Azul
          display.pixels[pix] = color(0, 0, 255);
        } else if ( rawDepth < threshold && rawDepth > thresholdPlay+thresholdEspacio) {
          // Rojo
          display.pixels[pix] = color(255, 0, 0);
        } else {
          // El valor de gris que le corresponda
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Dibujar la imagen
    image(display, 0, 0);
  }

  // Terminar
  void quit() {
    kinect.quit();
  }

  // Cargar Threshold
  int getThreshold() {
    return threshold;
  }

  // Guardar Threshold
  void setThreshold(int t) {
    threshold = t;
  }
}

