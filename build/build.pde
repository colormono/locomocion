// LOCOMOCIÓN 01
// by QUALE Studio
// http://www.quale.com.ar
// Thanks to Daniel Shiffman, Dan O'Sullivan
// Run in Processing 2.2.1

/**
 * Configuración:
 * --------------
 * d = Debug Info
 * c = DEPTH Camara
 * up / down = Umbral captura timeline
 * w / s = Umbral captura play
 * q / a = Umbral distancia entre play y timeline
 * 1-8 = Cambiar secuencia
 * m = Mute ambiente
 * space = Secuencia random
 **/

// Kinect
// http://shiffman.net/p5/kinect/
import org.openkinect.*;
import org.openkinect.processing.*;
KinectTracker tracker;
Kinect kinect;

// Audio
import ddf.minim.*;
Minim minim;

// Configuración
boolean debug = false; // Debug Info
boolean debugCamera = false; // Debug Camara
int threshold = 1000; // Threshold Timeline
int thresholdPlay = 960; // Threshold Play
int thresholdEspacio = 20; // Espacio entre el Threshold del Timeline y el Play
int tiempo = 300; // (30 segundos) Tiempo para cada secuencia (framerate sketch * segundos) 

// Secuencias
Secuencia secuencias[]; // Objetos para de secuencias
Secuencia esperando; // Secuencia de esperando
int secuenciaActual = 0; // Control para la secuencia
int frameActual = 0; // Control para la animación
int frameAnterior = 0; // Control para la animación
Urna u; // Urna para las secuencias random

// Audio
AudioSample audioEncendido;
AudioPlayer audioLoop, audioAmbiente;
boolean playingAmbiente = true;

//---------------------------------------------------------------

void setup() {

  // Lienzo
  size(1024, 768);
  frameRate(15);
  frame.setBackground( new java.awt.Color(0, 0, 0) );

  // Kinect
  kinect = new Kinect(this);
  tracker = new KinectTracker();

  // Audio
  minim = new Minim(this);
  audioEncendido = minim.loadSample("audio/loco_click1.wav", 512);
  audioLoop = minim.loadFile("audio/loco_reproduce1.wav");
  audioAmbiente = minim.loadFile("audio/loco_back_loop2.wav");
  audioAmbiente.play();

  // Secuencia Esperando
  esperando = new Secuencia( 149, "esperando/esperando1_" );

  // Arreglo de objetos Secuencia( _id, _cantidadFrames, _srcFrames );
  secuencias = new Secuencia[0];  

  // Secuencia 1
  Secuencia s1 = new Secuencia( 12, "loco1/loco1_" );
  secuencias = (Secuencia[]) append(secuencias, s1);

  // Secuencia 2
  Secuencia s2 = new Secuencia( 12, "loco2/loco2_" );
  secuencias = (Secuencia[]) append(secuencias, s2);

  // Secuencia 3
  Secuencia s3 = new Secuencia( 12, "loco3/loco3_" );
  secuencias = (Secuencia[]) append(secuencias, s3);

  // Secuencia 4
  Secuencia s4 = new Secuencia( 7, "loco4/loco4_" );
  secuencias = (Secuencia[]) append(secuencias, s4);

  // Secuencia 5
  Secuencia s5 = new Secuencia( 12, "loco5/loco5_" );
  secuencias = (Secuencia[]) append(secuencias, s5);

  // Secuencia 6
  Secuencia s6 = new Secuencia( 11, "loco6/loco6_" );
  secuencias = (Secuencia[]) append(secuencias, s6);
  
  // Secuencia 7
  Secuencia s7 = new Secuencia( 11, "loco7/loco7_" );
  secuencias = (Secuencia[]) append(secuencias, s7);
  
  // Secuencia 8
  Secuencia s8 = new Secuencia( 19, "loco8/loco8_" );
  secuencias = (Secuencia[]) append(secuencias, s8);
  
  // Urna para las secuencias
  u = new Urna( secuencias.length );
}

//---------------------------------------------------------------

void draw() {

  // Limpiar fondo
  background( 0 );

  // Actualizar posición del blob
  tracker.track();
  PVector v1 = tracker.getPos();

  // Disparar secuencia random
  if ( frameCount == 1 || frameCount % tiempo == 0 ) {
    if ( u.vacia() ) {
      u.reset();
    }
    int valor = u.sacar();
    secuenciaActual = valor;
  }

  // Secuencia: Esperando
  if ( secuencias[secuenciaActual].estado.equals( "esperando" ) ) {
    secuencias[secuenciaActual].esperar( v1.y, v1.x );
  }

  // Secuencia: Encendiendo
  if ( secuencias[secuenciaActual].estado.equals( "encendiendo" ) ) {
    secuencias[secuenciaActual].encender();
  }

  // Secuencia: Prendido
  if ( secuencias[secuenciaActual].estado.equals( "prendido" ) ) {
    secuencias[secuenciaActual].prendido( v1.x );
  }

  // Secuencia: Apagando
  if ( secuencias[secuenciaActual].estado.equals( "apagando" ) ) {
    secuencias[secuenciaActual].apagar();
  }

  // Revisar que no quede sonando el loop
  if ( secuencias[secuenciaActual].posicion.equals( "play" ) == false && audioLoop.isPlaying() ) { 
    audioLoop.pause();
  }
  if ( playingAmbiente == false ) {
    audioAmbiente.pause();
  } else {
      if ( !audioAmbiente.isPlaying() ) { 
        audioAmbiente.rewind();
        audioAmbiente.play(); 
      }
  }

  // Mostrar Depth Camara
  if ( debugCamera ) { 
    tracker.display();
  }

  // Mostrar información para debug
  if ( debug ) { 

    // Dibujar puntero con la posición del traker
    fill(50, 100, 250, 200);
    noStroke();
    ellipse(v1.x, v1.y, 20, 20);

    // Información relativa
    fill( 255 );
    text("Secuencia "+secuenciaActual + " - Estado: " + secuencias[secuenciaActual].estado + " - Espacio: " + thresholdEspacio + " - Imagen: " + frameActual + " - Tiempo: " + frameCount%tiempo + " - Vidas restantes:" + secuencias[secuenciaActual].vidas, 10, height-40 );
    text("Threshold: " + threshold + " - Threshold Play: " + thresholdPlay + " - Framerate: " + (int)frameRate + "    " + "UP aumentaa, DOWN reduce", 10, height-20 );
  }
}

//---------------------------------------------------------------

void keyPressed() {

  // Umbral captura
  if (key == CODED) {
    if (keyCode == UP) {
      threshold+=5;
      tracker.setThreshold(threshold);
    } else if (keyCode == DOWN) {
      threshold-=5;
      tracker.setThreshold(threshold);
    }
  }
  if (key == 'w' || key == 'W') thresholdPlay+=5;
  if (key == 's' || key == 'S') thresholdPlay-=5;
  if (key == 'q' || key == 'Q') thresholdEspacio+=5;
  if (key == 'a' || key == 'A') thresholdEspacio-=5;

  // Debug
  if (key == 'd' || key == 'D') debug = !debug;
  if (key == 'c' || key == 'C') debugCamera = !debugCamera;

  // Controlar secuencias
  if (key == ' ') {
    secuenciaActual = int( random(0, secuencias.length) );
  }
  if (key == '1') secuenciaActual = 0;
  if (key == '2') secuenciaActual = 1;
  if (key == '3') secuenciaActual = 2;
  if (key == '4') secuenciaActual = 3;
  if (key == '5') secuenciaActual = 4;
  if (key == '6') secuenciaActual = 5;
  if (key == '7') secuenciaActual = 6;
  if (key == '8') secuenciaActual = 7;

  // Controlar audio
  if (key == 'm' || key == 'M') playingAmbiente = !playingAmbiente;
}

//---------------------------------------------------------------

void stop() {
  // Terminar traker
  tracker.quit();

  // Terminar minim
  audioEncendido.stop();
  audioLoop.close();
  audioAmbiente.close();
  minim.stop(); 

  // Terminar todo!
  super.stop();
}

