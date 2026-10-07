import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

public class Ventana {
    public static void main(String[] args) {
        JFrame ventana = new JFrame("Compilador - Grupo 4");
        ventana.setSize(800, 600);
        ventana.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JTextArea codigo = new JTextArea();
        JTextArea salida = new JTextArea();
        salida.setEditable(false);
        JButton abrir = new JButton("Abrir archivo");
        JButton compilar = new JButton("Compilar");

        abrir.addActionListener(e -> {
            JFileChooser selector = new JFileChooser(new File("."));
            if (selector.showOpenDialog(ventana) == JFileChooser.APPROVE_OPTION) {
                File archivo = selector.getSelectedFile();
                try {
                    codigo.setText(Files.readString(archivo.toPath(), StandardCharsets.UTF_8));
                } catch (IOException ex) {
                    salida.setText("No se pudo abrir el archivo: " + ex.getMessage());
                }
            }
        });

        compilar.addActionListener(e -> {
            salida.setText("");
            TablaSimbolos.limpiar(); 
            try {
                Lexico lexer = new Lexico(new StringReader(codigo.getText()));
                String token;
                while ((token = lexer.yylex()) != null) {
                    salida.append(token + "\n");
                }
                TablaSimbolos.guardar("ts.txt");  
            } catch (Exception ex) {
                salida.append("Error: " + ex.getMessage() + "\n");
            }
        });

        JPanel botones = new JPanel();
        botones.add(abrir);
        botones.add(compilar);

        JSplitPane centro = new JSplitPane(JSplitPane.VERTICAL_SPLIT,
                new JScrollPane(codigo), new JScrollPane(salida));
        centro.setDividerLocation(280);

        ventana.setLayout(new BorderLayout());
        ventana.add(botones, BorderLayout.NORTH);
        ventana.add(centro, BorderLayout.CENTER);

        ventana.setVisible(true);
    }
}
