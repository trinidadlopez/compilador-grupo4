%%
%class Lexico
%unicode
%line
%type String

%{
    // Nivel de anidado de comentarios (se usa en el estado COMENT)
    private int nivel = 0;
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
  "DECLARE.SECTION"      { return "DECLARE_SECTION"; }
  "ENDDECLARE.SECTION"   { return "ENDDECLARE_SECTION"; }
  "PROGRAM.SECTION"      { return "PROGRAM_SECTION"; }
  "ENDPROGRAM.SECTION"   { return "ENDPROGRAM_SECTION"; }
  "WHILE"|"while"        { return "WHILE"; }
  "ENDWHILE"|"endwhile"  { return "ENDWHILE"; }
  "WRITE"|"write"        { return "WRITE"; }
  "IF"|"if"              { return "IF"; }
  "ENDIF"|"endif"        { return "ENDIF"; }
  "INTEGER"|"INT"        { return "TIPO_INTEGER"; }
  "FLOAT"                { return "TIPO_FLOAT"; }
  "STRING"               { return "TIPO_STRING"; }
  "PROMR"                { return "PROMR"; }

  /* ---------- Operadores ---------- */
  "+"    { return "OP_SUMA: +"; }
  "-"    { return "OP_RESTA: -"; }
  "*"    { return "OP_MULT: *"; }
  "/"    { return "OP_DIV: /"; }
  "&&"   { return "OP_AND: &&"; }
  "AND"  { return "OP_AND: AND"; }
  "||"   { return "OP_OR: ||"; }
  "OR"   { return "OP_OR: OR"; }
  "=="   { return "OP_IGUAL: =="; }
  "!="   { return "OP_DIFERENTE: !="; }
  "<="   { return "OP_MENOR_IGUAL: <="; }
  ">="   { return "OP_MAYOR_IGUAL: >="; }
  "<"    { return "OP_MENOR: <"; }
  ">"    { return "OP_MAYOR: >"; }

  /* ---------- Delimitadores y asignaciones ---------- */
  "("    { return "PAREN_IZQ: ("; }
  ")"    { return "PAREN_DER: )"; }
  "{"    { return "LLAVE_IZQ: {"; }
  "}"    { return "LLAVE_DER: }"; }
  "["    { return "COR_IZQ: ["; }
  "]"    { return "COR_DER: ]"; }
  ";"    { return "PUNTO_COMA: ;"; }
  ","    { return "COMA: ,"; }
  "::="  { return "ASIGNAR: ::="; }
  ":="   { return "ASIG_TIPO: :="; }
  ":"    { return "DOS_PUNTOS: :"; }

  /* ---------- Identificadores y constantes ---------- */
  {ID}      { TablaSimbolos.agregar(yytext(), "ID", "", "_", "_");
              return "ID: " + yytext(); }

  {INT}     { if (Double.parseDouble(yytext()) > 65535)
                  return "ERROR (linea " + (yyline + 1) + "): entero fuera de rango (maximo 65535): " + yytext();
              TablaSimbolos.agregar("_" + yytext(), "CTE_E", "_", yytext(), "_");
              return "INT: " + yytext(); }

  {REAL}    { if (Double.parseDouble(yytext()) > Float.MAX_VALUE)
                  return "ERROR (linea " + (yyline + 1) + "): real fuera de rango: " + yytext();
              TablaSimbolos.agregar("_" + yytext(), "CTE_F", "_", yytext(), "_");
              return "REAL: " + yytext(); }

  {STRING}  { int largo = yytext().length() - 2;
              if (largo > 30)
                  return "ERROR (linea " + (yyline + 1) + "): string de mas de 30 caracteres: " + yytext();
              String contenido = yytext().substring(1, yytext().length() - 1);
              TablaSimbolos.agregar("_" + contenido, "CTE_STR", "_", contenido, String.valueOf(largo));
              return "STRING: " + yytext(); }

  {ESPACIO_BLANCO}  { }

  /* cualquier otro caracter es un error lexico */
  .         { return "ERROR (linea " + (yyline + 1) + "): caracter invalido: " + yytext(); }
}

<COMENT> {
  "//*"     { nivel++; }
  "*//"     { nivel--; if (nivel == 0) yybegin(YYINITIAL); }
  [^]       { }
  <<EOF>>   { yybegin(YYINITIAL);
              return "ERROR: comentario sin cerrar"; }
}
