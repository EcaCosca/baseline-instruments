# baseline-instruments

Reverse engineering the **Oakley Airwave** to use its heads-up display as an
output device for BASEline flight data.

Status: **exploration**. Nothing built yet.

## The device

The Oakley Airwave is the Recon Instruments **MOD Live** HUD built into an
Oakley goggle. Recon was acquired by Intel in 2015; the product was
discontinued and Recon's cloud services (Recon Engage) are long dead. There is
no vendor path left — hence this project.

Confirmed from public sources (see docs/research.md):

| Property | Value |
|---|---|
| Platform | Android **2.3 Gingerbread** |
| Display | Kopin microdisplay |
| Sensors | GPS, altimeter, barometer, 3-axis accel/gyro/mag, temperature |
| Radios | WiFi, Bluetooth (Smart Ready) |
| Host port | micro-USB |
| Update signing | **Not verified** — `update.zip` signatures are not checked |

Two facts make this project very tractable:

1. **It's an Android device.** If `adb` is reachable, we can sideload an APK
   that renders whatever we want on the HUD.
2. **Recon shipped a public Android SDK** for this exact HUD (Google I/O 2012).
   The site is dead but the SDK is likely recoverable from archives.
3. **Update packages aren't signature-checked**, which is the documented root
   path if we need deeper access.

## Hardware state (this unit)

The **battery is dead** — it charges, but the device dies the instant it's
unplugged. Boots and runs fine on a wall charger.

Consequence: with no battery to buffer the boot-current spike, the unit runs
straight off the supply. A wall charger (Dedicated Charging Port, D+/D−
shorted, 1–2 A available) works. A computer port (Standard Downstream Port,
capped at 500 mA) browns out — worse through a dock sharing current with four
other devices.

This is a **power delivery problem, not a fault**, and for a bench display on
permanent USB power it mostly doesn't matter. See hardware/shopping-list.md.

## Goal

Phone as the brain, Airwave as the glass, earbuds as the voice, FlySight 2 as
the sensor. See [docs/architecture.md](docs/architecture.md).

Comparable in spirit to the Deep and Steep **Insight** + ENGO glasses combo,
but with a 428x240 16-bit colour framebuffer instead of a 3-field readout, and
a phone-class computer doing the thinking.

## Plan

1. **Get it powered and enumerating** — powered USB hub so it has current
   *and* a data path. Blocked on hardware purchase.
2. **Enumerate** — does it appear as ADB / MTP / mass storage / RNDIS?
   `adb devices` is the single most informative command available.
3. **If no USB** — it has WiFi. Put it on the LAN off wall power and look for
   `adbd` on 5555, plus whatever else it exposes.
4. **Recover the SDK** — archive.org for developers.reconinstruments.com.
5. **Decompile Recon Engage** — the companion app knows the device protocol.
6. **Hello world on the HUD** — smallest possible APK that draws to the
   display. This is the real milestone.
7. **BASEline data path** — phone-side engine consuming FlySight 2 live BLE
   telemetry (protocol already documented, see
   [docs/flysight-integration.md](docs/flysight-integration.md)), fanning out
   to HUD frames and audio cues.

Independent of all of the above, and the recommended **starting point**: the
**audible engine** (ground speed, flare cues, altitude callouts) is entirely
phone-side, needs no Airwave progress at all, and is useful on its own.

## Layout

- `docs/` — research notes, protocol findings
- `hardware/` — shopping list, teardown notes, measurements
- `captures/` — USB/network captures
- `tools/` — scripts
- `notes/` — scratch

## Tooling installed

`adb` 1.0.41, `fastboot`, `lsusb`, `nmap`, `tcpdump` (system).
