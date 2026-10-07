import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;

public class TablaSimbolos {

    private static Map<String, String[]> tabla = new LinkedHashMap<>();

    public static void agregar(String nombre, String token, String tipo, String valor, String longitud) {
        String clave = nombre + "|" + token;
        if (!tabla.containsKey(clave)) {
            tabla.put(clave, new String[] { nombre, token, tipo, valor, longitud });
        }
    }

    public static void limpiar() {
        tabla.clear();
    }

    public static void guardar(String archivo) throws IOException {
        StringBuilder sb = new StringBuilder();
        sb.append(String.format("%-35s%-10s%-6s%-35s%-6s%n", "NOMBRE", "TOKEN", "TIPO", "VALOR", "LONG"));
        for (String[] fila : tabla.values()) {
            sb.append(String.format("%-35s%-10s%-6s%-35s%-6s%n", fila[0], fila[1], fila[2], fila[3], fila[4]));
        }
        Files.write(Paths.get(archivo), sb.toString().getBytes(StandardCharsets.UTF_8));
    }
}