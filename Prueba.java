import java.io.StringReader;

public class Prueba {
    public static void main(String[] args) throws Exception {
        Lexico lexer = new Lexico(new StringReader(args[0]));
        String token;
        while ((token = lexer.yylex()) != null) {
            System.out.println(token);
        }
    }
}
