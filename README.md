# Compilador – 1ª entrega (Analizador Léxico)

**Materia:** Teoría de la Computación I – UNLu – 2026
**Grupo:** 4
**Tema especial asignado:** PROMR (más los temas comunes)

## ¿De qué trata el trabajo?

El TP Integrador consiste en construir, por etapas, un compilador para un lenguaje chico definido por la cátedra. Esta es la **primera entrega**, que cubre la primera etapa de todo compilador: el **análisis léxico**.

El analizador léxico lee el código fuente como una cadena de caracteres y lo parte en **tokens** (palabras reservadas, identificadores, constantes, operadores, delimitadores). Mientras lo hace:

- ignora lo que no importa (espacios, tabuladores, saltos de línea y comentarios);
- avisa los **errores léxicos** (caracteres inválidos, enteros o reales fuera de rango, strings demasiado largos);
- va armando la **tabla de símbolos** con los identificadores y las constantes que encuentra.

El analizador está generado con **JFlex** a partir de una descripción de expresiones regulares (`Lexico.flex`), y se usa desde una **interfaz gráfica en Swing**.

## Qué hay en este repositorio

| Archivo | Para qué sirve |
|---|---|
| `Lexico.flex` | **Es el corazón del trabajo.** Define las expresiones regulares y la acción de cada token. JFlex lo convierte en `Lexico.java`. Es el archivo que se edita si hay que cambiar el analizador. |
| `Lexico.java` | Analizador léxico **generado automáticamente** por JFlex a partir de `Lexico.flex`. No se edita a mano. |
| `Ventana.java` | Interfaz gráfica (Swing). Tiene dos áreas de texto (código y salida) y los botones **Abrir archivo** y **Compilar**. Al compilar, recorre el código con el analizador, muestra los tokens y guarda `ts.txt`. |
| `TablaSimbolos.java` | Clase que guarda los identificadores y constantes, sin repetidos, y los escribe en `ts.txt`. El analizador la llama cada vez que reconoce un ID o una constante. |
| `Prueba.java` | Pequeño programa de consola para probar el analizador sin la ventana. Se le pasa un texto por línea de comandos y muestra los tokens. |
| `TPCompilador.jar` | **Ejecutable** con todo lo necesario para correr el programa (`java -jar TPCompilador.jar`). Requiere Java 11 o superior. |
| `jflex-full-1.9.1.jar` | Herramienta JFlex 1.9.1, necesaria para regenerar `Lexico.java`. |
| `prueba.txt` | Archivo de prueba general: tokens válidos (incluido PROMR) y errores a propósito. |
| `ts.txt` | Tabla de símbolos generada al compilar `prueba.txt` (se vuelve a crear cada vez que se aprieta **Compilar**). |
| `COMO_PROBAR.md` | Guía paso a paso para compilar y probar todo. |
| `COMO_FUNCION_YYLEX.md` | Explicación de cómo el analizador reconoce tokens con `yylex()` (criterios de coincidencia y ejemplos). |

## Qué reconoce el analizador

- **Palabras reservadas:** `DECLARE.SECTION`, `ENDDECLARE.SECTION`, `PROGRAM.SECTION`, `ENDPROGRAM.SECTION`, `WHILE`, `ENDWHILE`, `WRITE`, `IF`, `ENDIF`, `INTEGER`, `FLOAT`, `STRING`, `PROMR`.
- **Identificadores:** una letra seguida de letras o dígitos.
- **Constantes:**
  - enteros (hasta 65535, es decir 16 bits sin signo);
  - reales (formas `3.14`, `.5`, `99.`; hasta el máximo de un `float`);
  - strings entre comillas dobles (hasta 30 caracteres de contenido).
- **Operadores:** `+ - * / && || == != <= >= < >`
- **Delimitadores y asignación:** `( ) { } [ ] ; , : ::=`
- **Comentarios:** `//* ... *//` (se ignoran; admite comentarios en bloque anidados).
- **Se descartan:** espacios, tabuladores, saltos de línea.

## La tabla de símbolos (`ts.txt`)

Columnas: `NOMBRE | TOKEN | TIPO | VALOR | LONG`

| Qué es | NOMBRE | TOKEN | TIPO | VALOR | LONG |
|---|---|---|---|---|---|
| Identificador | `a1` | `ID` | (vacío) | `_` | `_` |
| Entero | `_55` | `CTE_E` | `_` | `55` | `_` |
| Real | `_30.5` | `CTE_F` | `_` | `30.5` | `_` |
| String | `_hola` | `CTE_STR` | `_` | `hola` (sin comillas) | `4` |

- No hay filas repetidas.
- Las constantes con error (fuera de rango, string demasiado largo) **no** se agregan.
- Todavía no se asignan tipos a las variables (corresponde a una entrega posterior).

## Limitaciones conocidas de esta entrega

- Un **comentario sin cerrar** no genera un error específico.
- Un **string sin comilla de cierre** genera un error genérico sobre la comilla.
- Dentro de un string solo se aceptan letras (incluida la ñ), dígitos, espacios, los operadores y signos básicos, `.`, `!`, `¡`, `,`, `:` y `;`.
- Las palabras reservadas distinguen mayúsculas y minúsculas (`while` es un identificador, `WHILE` es la palabra reservada).
- Este analizador solo reconoce tokens: **no valida la sintaxis** (eso es la etapa siguiente).

## Cómo probarlo

Ver [`COMO_PROBAR.md`](COMO_PROBAR.md).
