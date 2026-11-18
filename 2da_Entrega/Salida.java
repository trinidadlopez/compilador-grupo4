/**
 * Salida compartida entre el lexico, el parser y la ventana.
 * Acumula las reglas reconocidas y los errores para mostrarlos en el area de salida.
 */
public class Salida {

    private static final StringBuilder sb = new StringBuilder();
    private static int errores = 0;

    public static void limpiar() {
        sb.setLength(0);
        errores = 0;
    }

    public static void println(String linea) {
        sb.append(linea).append("\n");
    }

    public static void error(String linea) {
        errores++;
        println(linea);
    }

    public static int cantidadErrores() {
        return errores;
    }

    public static String texto() {
        return sb.toString();
    }
}
