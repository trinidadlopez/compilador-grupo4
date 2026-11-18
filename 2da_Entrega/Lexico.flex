import java_cup.runtime.Symbol;

%%
%class Lexico
%unicode
%line
%column
%cup

%{
    // Nivel de anidado de comentarios (se usa en el estado COMENT)
    private int nivel = 0;

    // Arma el Symbol de CUP: id del token, linea, columna y el texto reconocido
    private Symbol tok(int id) {
        return new Symbol(id, yyline + 1, yycolumn + 1, yytext());
    }
%}

%state COMENT

LETRA            = [a-zA-Z]
DIGITO           = [0-9]
ID               = {LETRA}({LETRA}|{DIGITO})*
INT              = {DIGITO}+
REAL             = {DIGITO}+ "." {DIGITO}+ | "." {DIGITO}+ | {DIGITO}+ "."
STRING           = \"[^\"\r\n]*\"
TERMINADOR_LINEA = \r|\n|\r\n
ESPACIO_BLANCO   = {TERMINADOR_LINEA} | [ \t\f]

%%

<YYINITIAL> {

  /* ---------- Comentarios: //* ... *// (se ignoran) ---------- */
  "//*"                  { nivel = 1; yybegin(COMENT); }

  /* ---------- Palabras reservadas ---------- */
  "DECLARE.SECTION"      { return tok(sym.DECLARE_SECTION); }
  "ENDDECLARE.SECTION"   { return tok(sym.ENDDECLARE_SECTION); }
  "PROGRAM.SECTION"      { return tok(sym.PROGRAM_SECTION); }
  "ENDPROGRAM.SECTION"   { return tok(sym.ENDPROGRAM_SECTION); }
  "WHILE"|"while"        { return tok(sym.WHILE); }
  "ENDWHILE"|"endwhile"  { return tok(sym.ENDWHILE); }
  "WRITE"|"write"        { return tok(sym.WRITE); }
  "IF"|"if"              { return tok(sym.IF); }
  "ENDIF"|"endif"        { return tok(sym.ENDIF); }
  "INTEGER"|"INT"        { return tok(sym.TIPO_INTEGER); }
  "FLOAT"                { return tok(sym.TIPO_FLOAT); }
  "STRING"               { return tok(sym.TIPO_STRING); }
  "PROMR"                { return tok(sym.PROMR); }

  /* ---------- Operadores ---------- */
  "+"         { return tok(sym.OP_SUMA); }
  "-"         { return tok(sym.OP_RESTA); }
  "*"         { return tok(sym.OP_MULT); }
  "/"         { return tok(sym.OP_DIV); }
  "&&"|"AND"  { return tok(sym.OP_AND); }
  "||"|"OR"   { return tok(sym.OP_OR); }
  "=="        { return tok(sym.OP_IGUAL); }
  "!="        { return tok(sym.OP_DIFERENTE); }
  "<="        { return tok(sym.OP_MENOR_IGUAL); }
  ">="        { return tok(sym.OP_MAYOR_IGUAL); }
  "<"         { return tok(sym.OP_MENOR); }
  ">"         { return tok(sym.OP_MAYOR); }

  /* ---------- Delimitadores y asignaciones ---------- */
  "("    { return tok(sym.PAREN_IZQ); }
  ")"    { return tok(sym.PAREN_DER); }
  "{"    { return tok(sym.LLAVE_IZQ); }
  "}"    { return tok(sym.LLAVE_DER); }
  "["    { return tok(sym.COR_IZQ); }
  "]"    { return tok(sym.COR_DER); }
  ";"    { return tok(sym.PUNTO_COMA); }
  ","    { return tok(sym.COMA); }
  "::="  { return tok(sym.ASIGNAR); }
  ":="   { return tok(sym.ASIG_TIPO); }
  ":"    { return tok(sym.DOS_PUNTOS); }

  /* ---------- Identificadores y constantes ---------- */
  {ID}      { TablaSimbolos.agregar(yytext(), "ID", "", "_", "_");
              return tok(sym.ID); }

  /* Si la constante esta fuera de rango se informa el error, no se agrega
     a la tabla de simbolos, pero se devuelve el token igual para que el
     parser no genere un error de sintaxis en cascada. */
  {INT}     { if (Double.parseDouble(yytext()) > 65535)
                  Salida.error("ERROR LEXICO (linea " + (yyline + 1) + "): entero fuera de rango (maximo 65535): " + yytext());
              else
                  TablaSimbolos.agregar("_" + yytext(), "CTE_E", "_", yytext(), "_");
              return tok(sym.INT); }

  {REAL}    { if (Double.parseDouble(yytext()) > Float.MAX_VALUE)
                  Salida.error("ERROR LEXICO (linea " + (yyline + 1) + "): real fuera de rango: " + yytext());
              else
                  TablaSimbolos.agregar("_" + yytext(), "CTE_F", "_", yytext(), "_");
              return tok(sym.REAL); }

  {STRING}  { int largo = yytext().length() - 2;
              if (largo > 30) {
                  Salida.error("ERROR LEXICO (linea " + (yyline + 1) + "): string de mas de 30 caracteres: " + yytext());
              } else {
                  String contenido = yytext().substring(1, yytext().length() - 1);
                  TablaSimbolos.agregar("_" + contenido, "CTE_STR", "_", contenido, String.valueOf(largo));
              }
              return tok(sym.STRING); }

  {ESPACIO_BLANCO}  { }

  /* cualquier otro caracter: error lexico, se informa y se sigue */
  .         { Salida.error("ERROR LEXICO (linea " + (yyline + 1) + "): caracter invalido: " + yytext()); }
}

<COMENT> {
  "//*"     { nivel++; }
  "*//"     { nivel--; if (nivel == 0) yybegin(YYINITIAL); }
  [^]       { }
  <<EOF>>   { yybegin(YYINITIAL);
              Salida.error("ERROR LEXICO: comentario sin cerrar");
              return new Symbol(sym.EOF); }
}
