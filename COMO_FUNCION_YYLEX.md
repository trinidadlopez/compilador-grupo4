# Cómo funciona el analizador léxico (Lexico + yylex)

Guía rápida para recordar cómo el analizador léxico generado por JFlex lee un texto y lo convierte en tokens.
Los ejemplos están probados con el `Lexico.flex` del TP (versión simple, sin validaciones de rango).

---

## 1. Las tres piezas

| Pieza | Qué es | Analogía |
|---|---|---|
| `StringReader` | Entrega el texto **carácter por carácter, sin modificarlo** (espacios y saltos de línea incluidos). | La cinta de papel con el texto |
| `Lexico` | Clase que **genera JFlex** a partir de `Lexico.flex`. Conoce todas las reglas. | La persona que lee la cinta |
| `yylex()` | Método de `Lexico`. Cada vez que se lo llama, devuelve **el próximo token**. | La orden "dame la próxima palabra" |

```java
Lexico lexer = new Lexico(new StringReader(texto));   // le damos la cinta al lector
String token;
while ((token = lexer.yylex()) != null) {             // pedimos tokens hasta que devuelva null
    System.out.println(token);
}
```

- `yylex()` **no está escrito en `Prueba.java` ni en `Ventana.java`**: está en `Lexico.java`, generado por JFlex. Ahí solo se lo llama.
- Cuando `yylex()` devuelve `null`, se acabó el texto y el `while` termina.
- El `Lexico` **recuerda en qué posición del texto quedó** (el "cursor"), así que cada llamada continúa donde terminó la anterior.

### De dónde sale `Lexico`

JFlex corre **una sola vez, por comando**, y termina. Hay que repetir los pasos cada vez que se cambia el `.flex`:

```
java -jar jflex-full-1.9.1.jar Lexico.flex     # escribe Lexico.java
javac Lexico.java Prueba.java                  # genera Lexico.class y Prueba.class
java Prueba 'x ::= 5'                          # ejecuta
```

JFlex copia el código de cada `{ ... }` del `.flex` **tal cual** adentro de `yylex()`. Por eso un `return "INT: " + yytext();` de una regla termina siendo el valor que recibe el `while`.

---

## 2. Qué hace `yylex()` en cada llamada

Versión simplificada de su lógica:

```
yylex():
   repetir:
      si no queda texto  → devolver null
      elegir la regla que reconoce MÁS caracteres desde el cursor
      mover el cursor hasta el final de lo reconocido
      ejecutar la acción de esa regla
      si la acción tiene return → salir de yylex() devolviendo ese valor
      si no tiene return        → volver a "repetir"
```

Puntos clave:

- **`yylex()` tiene su propio bucle interno ("repetir")**. Una vuelta del `while` de afuera puede consumir varias cosas, porque las reglas **sin `return`** (espacios, comentarios) se reconocen y se descartan sin salir de `yylex()`.
- **Carácter por carácter vs. cadena completa**: para decidir el token, lee carácter por carácter y sigue mientras alguna regla pueda continuar. Cuando decide, entrega el lexema **completo** en `yytext()` y ejecuta la acción.
- **Vuelve atrás si hace falta**: si leyó de más, retrocede hasta el último punto donde había un token válido (ver ejemplo 3).
- Las acciones están en el `.flex`. Ejemplos de las reglas usadas acá:

```
{ID}              { return "ID: " + yytext(); }
{INT}             { return "INT: " + yytext(); }
"<="              { return "OP_MENOR_IGUAL: <="; }
{COMENTARIO}      { }        // sin return: se descarta
{ESPACIO_BLANCO}  { }        // sin return: se descarta
```

---

## 3. Ejemplos

En las tablas, **llamada** = una ejecución de `yylex()` (una vuelta del `while`); **pasada** = una vuelta del bucle "repetir" de adentro.

### Ejemplo 1: `ab1 <= 5`

Salida:
```
ID: ab1
OP_MENOR_IGUAL: <=
INT: 5
```

| Llamada | Qué pasa por dentro | Devuelve |
|---|---|---|
| 1 | Lee `a`, `b`, `1` (sigue siendo ID). Lee el espacio: nada puede continuar. Se queda con `ab1`, regla `{ID}`, tiene `return`. | `"ID: ab1"` |
| 2 | Pasada 1: espacio → `{ESPACIO_BLANCO}`, sin `return`, **repite**. Pasada 2: lee `<` (válido como `"<"`), lee `=` (ahora válido como `"<="`, más largo), lee espacio: no puede seguir. Se queda con `<=`. | `"OP_MENOR_IGUAL: <="` |
| 3 | Pasada 1: espacio, **repite**. Pasada 2: lee `5` → `{INT}`; se acaba el texto. | `"INT: 5"` |
| 4 | No queda texto. | `null` → el `while` termina |

### Ejemplo 2: `x ::= 5 //* hola *// ;` (espacios y comentario no llegan al `while`)

Salida (4 líneas, aunque el texto tiene más "cosas"):
```
ID: x
ASIGNAR: ::=
INT: 5
PUNTO_COMA: ;
```

| Llamada | Qué pasa por dentro | Devuelve |
|---|---|---|
| 1 | Lee `x` → `{ID}`. | `"ID: x"` |
| 2 | Espacio (sin `return`, repite). Lee `::=`: gana `"::="` (3 caracteres) contra `":"` (1). | `"ASIGNAR: ::="` |
| 3 | Espacio (repite). Lee `5` → `{INT}`. | `"INT: 5"` |
| 4 | Espacio (repite). Lee `//* hola *//` → `{COMENTARIO}` (12 caracteres, mucho más que `"/"`), **sin `return`**, repite. Espacio (repite). Lee `;`. | `"PUNTO_COMA: ;"` |
| 5 | No queda texto. | `null` |

### Ejemplo 3: `99.x` (lee de más y vuelve atrás)

Salida:
```
INT: 99
ERROR: .
ID: x
```

| Llamada | Qué pasa por dentro | Devuelve |
|---|---|---|
| 1 | Lee `9`, `9` (INT válido). Lee `.`: podría ser el inicio de un REAL (`99.5`), así que sigue, pero todavía **no es un token válido** (el REAL exige dígitos después del punto). Lee `x`: nada puede continuar. **Retrocede** hasta el último punto válido, `99`. El cursor queda justo después del `99`. | `"INT: 99"` |
| 2 | Lee `.` solo: no puede ser REAL, cae en la regla `.` (error). | `"ERROR: ."` |
| 3 | Lee `x` → `{ID}`. | `"ID: x"` |

Con `99.5` en cambio sigue leyendo el `5` y devuelve `REAL: 99.5`.

---

## 4. Cuando un texto coincide con más de una regla

Es normal que varias reglas reconozcan el mismo texto desde el mismo lugar (por ejemplo, `WHILE` es una palabra reservada, pero también cumple la regla de `ID`). JFlex decide siempre con **dos criterios, en este orden**:

1. **Gana la regla que reconoce más caracteres** (coincidencia más larga).
2. **Si empatan en cantidad de caracteres, gana la que está primero en el archivo `.flex`.**

Por eso en el `.flex` las **palabras reservadas van antes que `{ID}`**.

### Ejemplo 4: palabra reservada vs. ID — `WHILE WHILEX while`

Salida:
```
WHILE
ID: WHILEX
ID: while
```

| Llamada | Texto | Qué pasa | Resultado |
|---|---|---|---|
| 1 | `WHILE` | Dos reglas reconocen exactamente las mismas 5 letras: la reservada `"WHILE"` y también `{ID}`. **Empate en largo** → criterio 2: la reservada está arriba de `{ID}` en el archivo. | `WHILE` (reservada) |
| 2 | `WHILEX` | La reservada ya no puede seguir en la `X`, pero `{ID}` sí. `{ID}` reconoce 6 caracteres contra 5 → **criterio 1**. | `ID: WHILEX` |
| 3 | `while` | La reservada está escrita en mayúsculas: con `w` minúscula ni siquiera arranca. Solo `{ID}` reconoce. | `ID: while` |

Otros casos del mismo tipo: `ENDWHILE` sale como reservada; `IF2` sale como `ID: IF2`.

**Si se invierte el orden** (`{ID}` arriba de las reservadas), en la llamada 1 el empate lo ganaría `{ID}` y ninguna palabra reservada se detectaría nunca.

**Mayúsculas y minúsculas:** JFlex distingue ambas. Si el grupo quiere que `while` también sea reservada, hay que decidirlo y agregar esa variante al `.flex`.

---

## 5. Resumen en cuatro líneas

1. `StringReader` entrega los caracteres sin tocarlos; `Lexico` los interpreta; `yylex()` pide el próximo token.
2. Cada llamada a `yylex()` repite: elegir la regla más larga → avanzar el cursor → ejecutar la acción → si hay `return`, salir; si no, seguir.
3. Espacios y comentarios no tienen `return`: se reconocen pero no llegan al `while`.
4. Si hay empate entre reglas: gana la más larga; si sigue el empate, gana la primera del `.flex`.
