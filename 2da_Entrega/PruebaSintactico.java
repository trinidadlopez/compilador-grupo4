import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

/** Prueba por consola: java -cp ".:java-cup-11b-runtime.jar" PruebaSintactico prueba.txt */
public class PruebaSintactico {
    public static void main(String[] args) throws Exception {
        String codigo = Files.readString(Paths.get(args[0]), StandardCharsets.UTF_8);

        Salida.limpiar();
        TablaSimbolos.limpiar();

        Parser parser = new Parser(new Lexico(new StringReader(codigo)));
        try {
            parser.parse();
        } catch (Exception e) {
            Salida.error("Error: " + e.getMessage());
        }

        System.out.print(Salida.texto());
        TablaSimbolos.guardar("ts.txt");
    }
}
