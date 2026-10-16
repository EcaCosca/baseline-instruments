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

### 7. Batería de reemplazo — NO comprar todavía
Hay que abrir el equipo y medir primero: conector, capacidad, y si la celda
tiene placa de protección. Comprar a ciegas es tirar plata.
Cuando sepamos: `bateria lipo 3.7v con placa de proteccion conector`

## Resumen

Si querés comprar una sola cosa: **el hub USB con fuente externa** (#1).
Si querés comprar tres: **hub alimentado + cable corto 24AWG + medidor USB**.
Eso te deja el equipo encendido y comunicándose con la Mac de forma estable,
que es el requisito para todo lo demás.

## Alternativa gratis, para probar hoy mismo
Enchufá el micro-USB **directo a un puerto USB-C de la MacBook** (no al dock).
Los puertos de la Mac anuncian hasta 1.5 A. Puede alcanzar y no gastás nada.
