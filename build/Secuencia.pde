class Secuencia {

  //.h
  PVector location;
  String estado;
  String posicion;
  // Animaciones
  PImage [] animacion; // Imagenes para la animación de entrada
  String srcFrame; // Parte fija de la ruta del archivo de imagen
  int cantidadFrames; // Cantidad de frames = cantidad de espacios
  int frameEsperando; // Frame de inicio de la secuencia
  int frameFade = 0; // Frame para la transición
  int vidas = 30; // Tiempo de memoria para cuando deja de traquear


  // Constructor
  Secuencia( int _cantidadFrames, String _srcFrame ) {
    location = new PVector( 0, 0 );
    estado = "esperando";
    posicion = "timeline";
    cantidadFrames = _cantidadFrames;
    srcFrame = _srcFrame;
    animacion = loadImages(srcFrame, ".png", cantidadFrames); // nombre, extención, cantidad de frames
    frameEsperando = 0;
  }

  // Esperando (si no hay nadie durante x tiempo)
  void esperar( float _x, float _y ) {

    // Si el frameEsperando actual está dentro de la secuencia corre, sino, vuelve a iniciarse
    if ( frameEsperando < esperando.cantidadFrames ) {
      esperando.dibujar(frameEsperando);
      frameEsperando ++;
    } else {
      frameEsperando = 0;
    }

    // Si detecta blob, enciende
    if ( _y > 10 && _y < height-10 ) {
      if ( _x > location.x ) {
        frameFade = 0;
        estado = "encendiendo";
      }
    }
  }

  // Encender (si está esperando y detacta movimiento)
  void encender() {
    frameActual = 0;
    frameFade = 0;
    estado = "prendido";
  }

  // Prendido (mientras hay movimiento)
  void prendido( float _x ) {  

    // Si hay blob
    if ( _x > location.x ) {

      // Calcular donde
      if ( posicion.equals( "timeline" ) ) {
        // Actualizar frame
        frameActual = int( map(_x, 0, width, 0, cantidadFrames) );
        // Si el frame es distinto al anterior, reproducir audio
        if ( frameActual != frameAnterior ) {
          audioEncendido.trigger();
          frameAnterior = frameActual;
        }
      } else if ( posicion.equals( "play" ) ) {
        // Reproducir loop
        if ( frameActual < cantidadFrames-1 ) {
          frameActual++;
        } else {
          frameActual = 0;
        }
        // Reproducir loop de audio
        if ( !audioLoop.isPlaying() ) { 
          audioLoop.rewind();
          audioLoop.play(); 
        }
      }
      // Actualizar vidas
      vidas = vidas;
    } else {
      // Si se le acaban las vidas, apaga
      if ( vidas <= 0 ) {
        frameFade = 0;
        estado = "apagando";
      } else {
        // Resta tiempo de vida
        vidas--;
      }
    }

    // Dibuja frame
    dibujar( frameActual );

    // Fade
    if ( frameFade < 20 ) {
      fill(0, map(frameFade, 0, 20, 255, 0) );
      rect(0, 0, width, height);
      frameFade++;
    }
  }

  // Apagar
  void apagar() {
    // Fade
    if ( frameFade < 20 ) {
      dibujar( frameActual );
      fill(0, map(frameFade, 0, 20, 0, 255) );
      rect(0, 0, width, height);
      frameFade++;
    } else {
      frameEsperando = 0; // Reiniciar placa de esperando
      estado = "esperando";
    }
  }

  // Dibujar
  void dibujar( int frameActual ) {
    image(animacion[frameActual], 0, 0, width, height);
  }
}

