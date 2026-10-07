# Cómo probar el analizador léxico

Guía paso a paso. Todos los comandos se corren desde una terminal, **parada en la carpeta del proyecto**.

## Requisitos

- Java 11 o superior (para solo ejecutar el JAR alcanza con el JRE; para compilar hace falta el JDK). Se verifica con:
  ```
  java -version
  javac -version
  ```
- Los archivos del repositorio en una misma carpeta (incluido `jflex-full-1.9.1.jar`).

---

## Opción A: ejecutar el JAR (lo más rápido)

```
java -jar TPCompilador.jar
```

Se abre la ventana. Hay dos áreas de texto: **arriba**, el código; **abajo**, la salida.

1. Apretar **Abrir archivo** y elegir `prueba.txt` (o escribir código directamente en el área de arriba).
2. Apretar **Compilar**.
3. En el área de abajo aparece **un token por línea** (o un `ERROR` si hay algo inválido).
4. Se crea (o se pisa) el archivo **`ts.txt`** en la carpeta desde la que se ejecutó el comando.

Para ver la tabla de símbolos:
```
cat ts.txt
```

> `ts.txt` se guarda en la carpeta **actual de la terminal**, no en la del JAR. Conviene ejecutar el JAR siempre desde la carpeta donde está.

---

## Opción B: compilar todo desde el código fuente

Hace falta cuando se modifica algo. **Después de cualquier cambio en `Lexico.flex` hay que regenerar y recompilar**, si no se sigue usando el analizador viejo.

```
java -jar jflex-full-1.9.1.jar Lexico.flex
javac --release 11 Ventana.java Lexico.java TablaSimbolos.java
java Ventana
```

1. La primera línea **genera `Lexico.java`** a partir de `Lexico.flex`.
2. La segunda **compila** todo (genera los `.class`).
3. La tercera **ejecuta** la ventana.

> `--release 11` hace que los `.class` funcionen en cualquier Java 11 o superior, aunque se hayan compilado con un JDK más nuevo. Sin esa opción, el JAR solo corre en la versión de Java con la que se compiló.

### Rearmar el JAR

```
jar cfe TPCompilador.jar Ventana Ventana*.class Lexico.class TablaSimbolos.class
```

---

## Prueba rápida por consola (sin ventana)

Con `Prueba.java` se puede probar un texto sin abrir la interfaz:

```
javac Prueba.java
java Prueba "x ::= 5 ; WHILE"
```

Muestra un token por línea.

---

## Qué esperar con `prueba.txt`

El archivo tiene dos partes.

**Parte 1: tokens válidos.** No tiene que aparecer ningún `ERROR`. Incluye:

- todas las palabras reservadas;
- identificadores (incluidos casos parecidos a reservadas, como `WHILEX`, `IF2`, `while`);
- enteros (`0`, `7`, `65535`), reales (`3.14`, `.5`, `99.`), strings (vacío y de 30 caracteres);
- operadores, delimitadores, comentarios (simples, multilínea, anidados);
- líneas del tema **PROMR**.

**Parte 2: errores a propósito.** Se espera ver:

| Caso | Resultado esperado |
|---|---|
| Caracteres inválidos `@ # $ % ?` (5) | `ERROR: @`, `ERROR: #`, etc. (uno por cada uno) |
| Enteros `65536`, `99999`, `99999999999` | `ERROR (linea N): entero fuera de rango (maximo 65535): ...` |
| Real de 40 dígitos | `ERROR (linea N): real fuera derango: ...` |
| String de 31 caracteres | `ERROR (linea N): string de mas de 30 caracteres: ...` |
| PROMR con `70000` y con `@` | error de rango y error de carácter |

En total, la parte 2 muestra **12 errores**.

### Chequeos sobre `ts.txt`

- Los identificadores aparecen **una sola vez**.
- Las constantes tienen el prefijo `_` (`_55`, `_30.5`, `_hola`).
- Los strings figuran **sin comillas** y con su longitud.
- **No** figuran las constantes que dieron error (`65536`, el string de 31 caracteres, etc.).

---

## Pruebas manuales sugeridas

Escribir esto en el área de código y apretar **Compilar**:

```
a1 ::= 55 ; b1 ::= 30.5 ; WRITE "hola" ; WRITE "mundo" ; a1
```

`ts.txt` tiene que quedar así (sin repetir `a1`):

```
NOMBRE   TOKEN    TIPO  VALOR   LONG
a1       ID             _       _
b1       ID             _       _
_55      CTE_E    _     55      _
_30.5    CTE_F    _     30.5    _
_hola    CTE_STR  _     hola    4
_mundo   CTE_STR  _     mundo   5
```

Otras para probar:

| Texto | Qué debería pasar |
|---|---|
| `65535` / `65536` | el primero es un entero válido; el segundo da error de rango |
| `WHILE WHILEX while` | `WHILE` es reservada; `WHILEX` y `while` son identificadores |
| `x ::= 5 //* comentario *// ;` | el comentario se ignora |
| `//* a //* b *// c *//` | comentario anidado, se ignora completo |
| `<= < >= >` | cuatro operadores distintos |

---

## Problemas frecuentes

| Síntoma | Causa probable | Solución |
|---|---|---|
| Un cambio en el `.flex` "no hace nada" | No se regeneró o no se recompiló | Correr de nuevo los comandos de la Opción B |
| `error: file not found` en `javac` | Terminal parada en otra carpeta o nombre mal escrito | `ls` para ver los archivos; respetar mayúsculas |
| `Could not find or load main class` al correr el JAR | JAR armado con clases desactualizadas o incompletas | Recompilar y rearmar el JAR |
| No aparece `ts.txt` | Se ejecutó desde otra carpeta | Buscarlo en la carpeta actual de la terminal |
