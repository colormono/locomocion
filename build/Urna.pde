//--------------------------------------------------
// Desarollo por Emiliano Causa. http://biopus.com.ar
//--------------------------------------------------
class Urna {

  int cantidad;
  boolean urn[];
  int sacados;
  int cont;

  //-------------------------------------
  Urna( int cantidad_ ) {

    cantidad = cantidad_;
    urn = new boolean [cantidad];
    reset();
  }

  //-------------------------------------
  int sacar() {
    int resultado = -1;
    if ( ! vacia() ) {

      int tirada = int( random (cantidad));
      incrementar( tirada );    

      if ( !urn[ cont ] ) {

        urn[ cont ] = true;
        sacados ++;
        resultado = cont;
      } else {
        boolean encontro = false;

        for (int i=0; i<cantidad && !encontro; i++) {

          incrementar( 1 );
          if ( !urn[cont] ) {
            urn[cont] = true;
            sacados ++;
            resultado = cont;
            encontro = true;
          }
        }
      }
    }
    return resultado;
  }
  //----------------------------

  boolean vacia() {
    return sacados>=cantidad;
  }
  //----------------------------

  void incrementar( int valor ) {
    cont = (cont+valor) % cantidad;
  }

  //--------------------------------

  void reset() {
    for (int i=0; i < cantidad; i++) {
      urn [i] = false;
    }
    sacados = 0;
    cont = 0;
  }
}

