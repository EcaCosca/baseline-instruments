# Architecture

## The vision

Phone as the brain. Airwave as the glass. Earbuds as the voice. FlySight as the
sensor. Conceptually similar to the Deep and Steep **Insight** + ENGO glasses
combo, but with a far richer display and a phone-class computer behind it.

## The one constraint that shapes everything

**The Airwave has no video input.** Its micro-USB is "Device Charging/Power &
Data Transfer" only — there is no HDMI, no DisplayLink, no USB video sink. You
cannot treat it as an external monitor and push pixels at it.

So "phone as brain, Airwave as display" has to mean:

> A **client app runs on the Airwave** that receives already-computed data over
> a wireless link and renders it. The phone does all sensing, fusion, and
> decision logic; the Airwave is a networked thin client whose only job is to
> draw.

This is not a workaround — it is exactly how Recon's own ecosystem worked
(Engage pushed music metadata and notifications from phone to HUD over
Bluetooth), and the manual documents a third-party app ecosystem with apps
installed onto the device. We are using the device the way it was designed to
be used; we are just replacing the dead vendor cloud with our own.

## Target hardware (from the official Airwave 1.5 manual)

| | |
|---|---|
| Internal name | **Recon Snow2** (FCC ID `ZW5008`) |
| SoC | 1 GHz dual-core ARM Cortex-A9 + PowerVR SGX540 (OMAP4-class) |
| Memory | 1 GB DDR2 / 2 GB flash |
| Display | **428×240, 16:9 WQVGA LCD microdisplay** |
| Color depth | **16-bit high color (RGB 5:6:5)** |
| Virtual image | 14" at 5 ft, upper-right of FOV |
| Radios | **Bluetooth 4.0 (Smart/BLE)** + Apple MFi, WiFi 802.11 a/b/g/n |
| GPS | with INS Kalman filtering fusion |
| Sensors | 3D accel + 3D gyro + 3D mag, pressure (alt/baro) |
| Battery | **3.7 V LiPo, 1200 mAh**, 3 h charge, 6 h+ runtime |
| Port | micro-USB 2.0 (5-pin), charge + data |
| Enclosure | IP65, 65 g |
| Input | BLE 6-button remote (FCC ID `ZW5001`) |

428×240 at 16-bit color is a genuine framebuffer. Compared to ENGO's 3-field
readout this is a large upgrade — gauges, arcs, a horizon, a glide ratio tape,
color-coded state are all realistic.

## System design

```
  FlySight (BLE, if v2) ──┐
                          │
  Phone GPS / baro ───────┼──►  PHONE  ("the brain")
                          │     ├─ sensor fusion
  (optional: audible      │     ├─ flare / glide / progression logic
   altimeter, logs)       │     ├─ session logging  ──► BASEline
                          │     │
                          │     ├──►  BT or WiFi  ──►  AIRWAVE APP ──► HUD
                          │     │                       (renders 428×240)
                          │     │
                          │     └──►  audio  ──►  IN-EAR  (TTS + tones)
```

Three deliverables, and they are independently useful:

1. **Airwave client app** — receives a data frame, draws the HUD. Dumb by
   design: no logic, no sensors, just render what it is told. If the link
   drops it shows a stale-data warning.
2. **Phone-side engine** — owns all logic. Talks to FlySight, computes cues,
   drives audio, pushes frames to the HUD, logs to BASEline.
3. **Audible engine** — phone-side. Ground speed, flare cues, altitude
   callouts, progression feedback.

The audible engine is worth building **first**: it has zero dependency on the
Airwave, works today with just a phone and earbuds, and is independently
valuable. The HUD is the riskier half of the project.

## Link choice: phone → Airwave

| Option | Pros | Cons |
|---|---|---|
| **Bluetooth SPP/RFCOMM** | low power, auto-reconnect, proven by Engage | lower bandwidth, pairing friction |
| **BLE GATT** | modern, low power, hardware supports BT 4.0 | needs BLE peripheral/central roles sorted; Android version on device may gate the API |
| **WiFi TCP socket** | easy to build and debug, plenty of bandwidth | power hungry, needs an AP or hotspot, worst option in the air |

Recommendation: **Bluetooth** for flight, with a **WiFi TCP socket for
development** because it is far easier to iterate against. Design the wire
format transport-agnostic so either works.

Wire format: small fixed-schema frames at 4–10 Hz. Keep it versioned from day
one. Something like a compact JSON or CBOR frame — altitude AGL, vertical
speed, ground speed, glide ratio, heading, distance/bearing to LZ, cue state.
Render-ready values only; the HUD does no math.

## Open questions (blocking, in order)

1. **Which FlySight?** FlySight 2 has BLE and can stream live. FlySight 1 is
   USB-only with no radio — live integration is impossible with a v1, which
   would reduce it to post-flight log import. This determines whether live
   FlySight data is even on the table.
2. **What Android version does Snow2 actually run?** Gates the whole app
   toolchain. The MOD Live was Gingerbread (2.3); Snow2 is later silicon and
   probably newer. Must be read off the device.
3. **Is `adbd` on, and can we sideload?** Without this, there is no app on the
   HUD. Fallback is the unsigned `update.zip` path.
4. **How does an app address the display?** Standard Android Surface at
   428×240, or a Recon-specific overlay API from their SDK?
5. **Is the BLE remote usable as an input device** for menu navigation in our
   own app?

## Audio latency note

Bluetooth earbuds add roughly 150–250 ms of latency. For altitude callouts
that is irrelevant. For **flare timing cues it is not** — a quarter second
matters. Prefer **wired in-ear** for anything timing-critical, or calibrate a
fixed offset into the cue scheduling and verify it empirically.

## Safety

This is a data and training aid, not an instrument. It should never be the
primary altitude reference: keep an analog altimeter and a dedicated,
purpose-built audible. Phone OSes deschedule background apps, BT links drop,
and batteries die — and this unit's battery is already dead. Design every cue
to fail silent-and-obvious rather than silent-and-wrong, and treat a stale
link as a loud visible error on the HUD.
