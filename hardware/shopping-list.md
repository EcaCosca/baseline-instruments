# Compras — MercadoLibre

Objetivo: alimentar el Oakley Airwave de forma estable desde la Mac (sin batería),
y tener las herramientas básicas para explorar el dispositivo.

## Prioridad 1 — resolver la alimentación (sin esto no hay USB)

### 1. Hub USB con alimentación externa  ← LA compra clave
El Airwave no tiene batería útil, así que necesita una fuente que le dé
1–2 A *mientras* pasa datos a la Mac. Un hub alimentado hace exactamente eso.

- Buscar: `hub usb con alimentacion externa fuente`
- Buscar: `hub usb 3.0 alimentado 5v 3a`
- Buscar: `hub usb powered con transformador`

**Requisito no negociable:** tiene que venir con **fuente/adaptador externo propio**
(5 V, 3 A o más). Si dice "alimentado por USB" / "bus-powered", NO sirve — es el
mismo problema que tenés ahora. Buscá en las fotos que tenga un conector tipo
jack para la fuente.

### 2. Cable micro-USB corto y de buena sección
Los cables finos y largos caen 0.5 V o más, y con un equipo sin batería eso es
la diferencia entre bootear y no bootear.

- Buscar: `cable micro usb corto 30cm carga rapida`
- Buscar: `cable micro usb 24awg datos`

Que diga **24 AWG** (o "carga rápida" + corto). Evitar cables de 1.5 m finitos.
Comprá 2 y que al menos uno sea **de datos**, no solo de carga — muchos cables
baratos tienen D+/D− sin conectar y nunca vas a ver el dispositivo.

### 3. Adaptador USB-C → USB-A (para saltear el dock)
Todo lo que tenés enchufado pasa por el dock Dell, que reparte poca corriente
entre 4 dispositivos. Enchufar directo a la Mac ya mejora bastante.

- Buscar: `adaptador usb c a usb a hembra`
- Buscar: `cable usb c a micro usb`

## Prioridad 2 — instrumentación (muy recomendado para este proyecto)

### 4. Medidor USB de voltaje y corriente  (~USD 10)
Se enchufa entre la fuente y el Airwave y te dice exactamente cuántos mA pide
y si la tensión se cae al bootear. Deja de ser adivinanza.

- Buscar: `medidor usb voltaje corriente tester`
- Buscar: `probador usb amperimetro voltimetro`
- Modelos buenos si aparecen: **UM24C**, **AT34**, **KWS-MX18**

### 5. Adaptador USB-TTL serial 3.3 V
Si en algún momento abrimos el equipo, estas placas casi siempre tienen pads de
UART de debug. Es la vía más directa a una consola.

- Buscar: `adaptador usb ttl serial cp2102`
- Buscar: `conversor usb serial ftdi ft232 3.3v`

**Importante:** que soporte **3.3 V** (o tenga jumper 3.3/5 V). 5 V puro puede
dañar la placa.

## Prioridad 3 — más adelante, si hace falta

### 6. Analizador lógico 8 canales (~USD 8)
Para mirar buses internos (SPI/I2C) si llegamos a ese nivel.
- Buscar: `analizador logico 8 canales 24mhz saleae`

### 7. Batería de reemplazo — AHORA SÍ sabemos qué comprar
La celda original es una **EVE 903041**: LiPo **3.7 V, 1200 mAh**, aprox.
**9.0 × 30 × 41 mm**. Se reutiliza la **placa de protección original** y se
suelda una celda nueva.

- Buscar: `bateria lipo 3.7v 1200mah`
- Buscar: `bateria lipo 903041`
- Buscar: `celda lipo 3.7v 1200mah` (sin placa — reusamos la original)

Priorizá que las **medidas** coincidan; la capacidad es lo segundo. Si es más
gruesa que 9 mm no entra.

**Trampa importante:** si una celda LiPo baja de ~2 V, el circuito de
protección se traba y no carga más. Cargá la celda nueva a **3 V o más antes
de instalarla**. Es la forma más común de arruinar esta reparación.

### 8. Herramientas para abrir el equipo
Son **5 tornillos Torx T-6**, y la carcasa de la batería está **pegada** (no
atornillada).

- Buscar: `destornillador torx t6` o `kit destornilladores precision torx`
- Buscar: `multimetro digital` — para medir la celda antes y después
- Buscar: `cautin 60w estacion de soldar` + `estaño 0.6mm` — para la placa de protección

## Resumen

Si querés comprar una sola cosa: **el hub USB con fuente externa** (#1).
Si querés comprar tres: **hub alimentado + cable corto 24AWG + medidor USB**.
Si vas a abrirlo igual: sumá **Torx T-6 + multímetro + celda LiPo 1200 mAh**.
Eso te deja el equipo encendido y comunicándose con la Mac de forma estable,
que es el requisito para todo lo demás.

## Alternativa gratis, para probar hoy mismo
Enchufá el micro-USB **directo a un puerto USB-C de la MacBook** (no al dock).
Los puertos de la Mac anuncian hasta 1.5 A. Puede alcanzar y no gastás nada.

## Audio — para los audibles
El audible (velocidad de suelo, flare, altitud) lo maneja el teléfono, no el
Airwave. Para timing de flare, **auriculares con cable** son mejores: los
Bluetooth agregan 150–250 ms de latencia, que en un flare importa.

- Buscar: `auriculares in ear con cable microfono`
- Si el teléfono no tiene jack: `adaptador usb c a jack 3.5mm`
