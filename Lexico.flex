%%
%class Lexico
%unicode
%line
%type String

LETRA            = [a-zA-Z]
DIGITO           = [0-9]
SIGNOS           = (\+|-|\/|\*|>|<|\!=|<=|>=|=){1}
OPERADORES       = ,|:|;
PERADORES       = [+\-*/=<>!&|]
ID               = {LETRA}({LETRA}|{DIGITO})*
INT              = {DIGITO}+
REAL             = {DIGITO}+ "." {DIGITO}+ | "." {DIGITO}+ | {DIGITO}+ "." 
STRING           = \"({ESPACIO_BLANCO}|{SIGNOS}|{OPERADORES}|{LETRA}|{DIGITO}|\.|\!|\¡|ñ|Ñ)*\"
COMENTARIO       = "//*" ~ "*//"
COMENTARIO_BLOQUE = "//*" [^*] {COMENTARIO} [^*] ~"*//"
TERMINADOR_LINEA = \r|\n|\r\n
ESPACIO_BLANCO   = {TERMINADOR_LINEA} | [ \t\f]

%%
"DECLARE.SECTION"      { return "DECLARE_SECTION"; }
"ENDDECLARE.SECTION"   { return "ENDDECLARE_SECTION"; }
"PROGRAM.SECTION"      { return "PROGRAM_SECTION"; }
"ENDPROGRAM.SECTION"   { return "ENDPROGRAM_SECTION"; }
"WHILE"      { return "WHILE"; }
"ENDWHILE"   { return "ENDWHILE"; }
"WRITE"      { return "WRITE"; }
"IF"         { return "IF"; }
"ENDIF"      { return "ENDIF"; }
"INTEGER"    { return "TIPO_INTEGER"; }
"FLOAT"      { return "TIPO_FLOAT"; }
"STRING"     { return "TIPO_STRING"; }
"PROMR"      { return "PROMR"; }

"+"    { return "OP_SUMA: +"; }
"-"    { return "OP_RESTA: -"; }
"*"    { return "OP_MULT: *"; }
"/"    { return "OP_DIV: /"; }
"&&"   { return "OP_AND: &&"; }
"||"   { return "OP_OR: ||"; }
"=="   { return "OP_IGUAL: =="; }
"!="   { return "OP_DIFERENTE: !="; }
"<="   { return "OP_MENOR_IGUAL: <="; }
">="   { return "OP_MAYOR_IGUAL: >="; }
"<"    { return "OP_MENOR: <"; }
">"    { return "OP_MAYOR: >"; }

"("    { return "PAREN_IZQ: ("; }
")"    { return "PAREN_DER: )"; }
"{"    { return "LLAVE_IZQ: {"; }
"}"    { return "LLAVE_DER: }"; }
"["    { return "COR_IZQ: ["; }
"]"    { return "COR_DER: ]"; }
";"    { return "PUNTO_COMA: ;"; }
","    { return "COMA: ,"; }
"::="  { return "ASIGNAR: ::="; }
":"    { return "DOS_PUNTOS: :"; }

{ID}          { TablaSimbolos.agregar(yytext(), "ID", "", "_", "_");
                return "ID: " + yytext(); }
{INT}         { if (Double.parseDouble(yytext()) > 65535)
                      return "ERROR (linea " + (yyline + 1) + "): entero fuera de rango (maximo 65535): " + yytext();
                TablaSimbolos.agregar("_" + yytext(), "CTE_E", "_", yytext(), "_");
                return "INT: " + yytext(); }
{REAL}        { if (Double.parseDouble(yytext()) > Float.MAX_VALUE)
                      return "ERROR (linea " + (yyline + 1) + "): real fuera derango: " + yytext();
                TablaSimbolos.agregar("_" + yytext(), "CTE_F", "_", yytext(), "_");
                return "REAL: " + yytext(); }
{STRING}      { int largo = yytext().length() - 2;
                if (largo > 30)
                     return "ERROR (linea " + (yyline + 1) + "): string de mas de 30 caracteres: " + yytext();
                String contenido = yytext().substring(1, yytext().length() - 1);
                TablaSimbolos.agregar("_" + contenido, "CTE_STR", "_", contenido, String.valueOf(largo));
                return "STRING: " + yytext(); }
{ESPACIO_BLANCO}  { }
.             { return "ERROR: " + yytext(); }
{COMENTARIO}      { }
{COMENTARIO_BLOQUE}     { }