# FlySight 2 integration

**Resolved: live telemetry over BLE is officially supported.** Confirmed by
reading FlySight's own iOS client source, `flysight/flysight-ios-core`
(`LiveGNSSData.swift`, `GNSSLiveMask.swift`, `BluetoothManager.swift`).

This is the sensor source for the whole system. No reverse engineering needed —
it is a documented-in-source, first-party protocol.

## Device capability

FlySight 2 logs GNSS up to 25 Hz, pressure to 200 Hz, accel/gyro to 6 kHz.
BLE + USB-C, IP67. The *live* BLE stream is a subset of that, rate TBD
empirically.

## GATT services

Base UUID `0000000X-cc7a-482a-984a-7f2ed5b3e58f`:

| Service | UUID | Use |
|---|---|---|
| File Transfer | `00000000-cc7a-…` | log download |
| **Sensor Data** | `00000001-cc7a-…` | **live telemetry — what we want** |
| Starter Pistol | `00000002-cc7a-…` | timing / start detection |
| Device State | `00000003-cc7a-…` | mode control |
| Device Information | `180A` | standard |
| Battery | `180F` | planned, per source comment |

## Characteristics

Base UUID `0000000X-8e22-4541-9d4c-21edae82ed19`:

| Name | UUID | Properties |
|---|---|---|
| **SD_GNSS_MEASUREMENT** | `00000000-8e22-…` | **Read, Notify** ← subscribe here |
| SD_CONTROL_POINT | `00000006-8e22-…` | Write, Indicate (get/set mask) |
| FT_PACKET_OUT | `00000001-8e22-…` | Notify |
| FT_PACKET_IN | `00000002-8e22-…` | WriteWithoutResponse, Read (**pairing trigger**) |
| SP_CONTROL_POINT | `00000003-8e22-…` | Write, Indicate |
| SP_RESULT | `00000004-8e22-…` | Read, Indicate |
| DS_MODE | `00000005-8e22-…` | Read, Indicate |
| DS_CONTROL_POINT | `00000007-8e22-…` | Write, Indicate |
| Firmware Revision | `2A26` | Read |

**All characteristics require encryption** — the device must be paired/bonded.
A *read* of `FT_PACKET_IN` is used as the pairing trigger. Advertising carries
manufacturer data with company ID `0x09DB`.

## Live GNSS packet format

Notifications on `SD_GNSS_MEASUREMENT` are:

```
[mask: u8][present fields, in fixed order]
```

The mask's bits say which fields follow. Fields appear in this order, each
present only if its bit is set:

| Bit | Mask | Field(s) | Type | Scale → unit |
|---|---|---|---|---|
| TOW | `0x80` | timeOfWeek | `u32` | ms |
| WEEK | `0x40` | weekNumber | `u16` | **not sent by current firmware** |
| POSITION | `0x20` | longitude | `i32` | ÷ 1e7 → degrees |
| | | latitude | `i32` | ÷ 1e7 → degrees |
| | | heightMSL | `i32` | ÷ 1000 → metres |
| VELOCITY | `0x10` | velocityNorth | `i32` | ÷ 1000 → m/s |
| | | velocityEast | `i32` | ÷ 1000 → m/s |
| | | velocityDown | `i32` | ÷ 1000 → m/s |
| ACCURACY | `0x08` | horizontalAccuracy | `u32` | ÷ 1000 → m |
| | | verticalAccuracy | `u32` | ÷ 1000 → m |
| | | speedAccuracy | `u32` | ÷ 1000 → m/s |
| NUM_SV | `0x04` | numSV | `u8` | count |

Firmware-side these constants live in `gnss_ble.h`.

### Mask configuration

Default mask in the iOS client is `TOW | POSITION | VELOCITY` = **`0xB0`**.

Change it by writing to `SD_CONTROL_POINT`:
- `[getMask_opcode]` — read current mask
- `[setMask_opcode][newMask]` — set it

For our use we want **`0xBC`** (`TOW | POSITION | VELOCITY | NUM_SV`) or
**`0xBD`**-style with accuracy added if we want to gate cues on fix quality.
Recommendation: include **ACCURACY** (`0x08`) — suppressing a flare cue on a
degraded fix is exactly the kind of safety behaviour we want. So **`0xB8`**
plus NUM_SV = **`0xBC`**… precisely: `0x80|0x20|0x10|0x08|0x04` = **`0xBC`**.

## Everything the cue engine needs derives from this

- **Vertical speed** = `velocityDown` directly.
- **Ground speed** = `hypot(velocityNorth, velocityEast)`.
- **Glide ratio** = ground speed / vertical speed.
- **Altitude** = `heightMSL`, minus a ground reference set at the LZ.
  (Note: *MSL*, not AGL — AGL is our job to compute.)
- **Track/heading** = `atan2(velocityEast, velocityNorth)`.
- **Distance / bearing to LZ** = from lat/lon against a stored LZ.
- **Fix quality gate** = accuracy fields + `numSV`.

## Reference implementations

| Repo | Why it matters |
|---|---|
| `flysight/flysight-ios-core` | **First-party BLE client. The authority.** |
| `flysight/flysight-2-firmware` | Device side; `STM32_WPAN/App/custom_stm.c` has the GATT table |
| `flysight/flysight-ios-app` | First-party app using the above |
| `RomanTheLegend/FlySight-Android` | Native Android FlySight 2 manager — closest prior art if the phone brain is Android |
| `HozakaN/FlySight-Companion` | Another companion app |

Note: two repos that search engines commonly surface for this
(`oryjkov/flysight-viewer`, `envizio/flysight-altitude`) **do not exist**.
Don't chase them.

## Implications for our architecture

The phone is now unambiguously the right brain: it bonds to the FlySight over
BLE, consumes this stream, computes every cue, then fans out to (a) earbuds as
audio and (b) the Airwave as a render frame. The Airwave never talks to the
FlySight — it could not anyway, and should not.

Open: BLE central role on the phone must hold **two** links at once if the HUD
link is also BLE (FlySight + Airwave). Android and iOS both manage this fine,
but it argues for the HUD link being **Bluetooth Classic SPP or WiFi** to keep
the BLE central free for the FlySight.
