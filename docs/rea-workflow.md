# Using REA (Reverse Engineer Anything) on this project

[`morluto/rea`](https://github.com/morluto/rea) — MIT, TypeScript, an MCP server
that gives a coding agent a reverse-engineering toolchain. Verified real via the
GitHub API: created 2026-04-14, ~283k stars, 71k forks, actively pushed, npm
package `rea-agents` (latest 6.5.0, maintainer `morluto`, repo link matches).

> **Impostors exist.** Searching turns up several repos with the identical
> description and copied README (`NabilRFG12/Reverse-Engineer-anything`,
> `Prompt-Motion/ReaReverse`, `terryfurqan/rea`, …). REA's own README warns
> about this. Only use **`morluto/rea`**, **npm `rea-agents`**, or
> **rea.tools**.

One honest note on the hype: 283k stars against only 972 watchers is a very
unusual ratio and suggests inflated stars. The 71k forks and the active
derivative ecosystem look genuine, and the tool's capability list is real and
verifiable — judge it on the tooling, not the star count.

## Why it fits this project

REA's Android and ADB tooling maps almost one-to-one onto our open questions.
The Airwave is an Android device, and our two hardest unknowns — what OS it
runs and how an app addresses the HUD — are exactly what these tools answer.

## Capability map

### Phase A — doable now, without the device

| Our task | REA capability |
|---|---|
| Learn the phone↔HUD protocol | **Android APKs** — decompile `com.reconinstruments.jetandroid` (Recon Engage). Manifest, classes, decompiled methods, references. |
| Find Recon's service names, UUIDs, intents | **Android resources** (Apktool) — decoded manifest, string tables |

This is the highest-value work available before the powered hub arrives. The
Engage APK is the companion app that actually talked to this HUD; its
Bluetooth code is the protocol spec we otherwise have to guess at.

### Phase B — once the Airwave is powered and `adb` responds

| Our open question | REA tool | What it returns |
|---|---|---|
| **What Android version?** | `inspect_adb_device` | getprop: build, **SDK level**, fingerprint, product, **ABIs**, debuggable |
| **How does an app address the display?** | `inspect_adb_display` | **screen dimensions and density** — confirms 428×240 and gives the density we need for layout |
| Is adb even alive? | `inspect_adb_client`, `list_adb_devices` | serial, state, transport, model |
| What does the platform expose? | `list_adb_features`, `list_adb_services` | hardware/software features, **GL version**, binder services |
| Get Recon's own HUD apps | `list_adb_packages` → `pull_adb_package` | package list with APK paths; pulls complete split sets with SHA-256 |
| **Learn the real display API** | pull Recon's launcher/HUD app, then decompile it | this is how we discover whether it is a plain Android Surface or a Recon overlay API |
| Iterate on our own UI | `capture_adb_screen` | **PNG screenshot of the HUD** — huge for development |
| Debug | `read_adb_logcat` | bounded logcat, optional PID filter |
| **Sideload our app** | `install_adb_package`, `start_adb_activity` | install and launch |

`pull_adb_package` + APK decompilation is the key combination: it turns Recon's
own HUD software into our documentation.

### Phase C — deeper, needs Linux (see constraints)

| Target | REA capability | Requirement |
|---|---|---|
| Snow2 / MOD Live firmware image | **Firmware** — regions, extraction, native handoff | Binwalk / Unblob, **Linux** |
| BLE sniffing (FlySight link, HUD link) | **Recorded packets** / **Packet summaries** | TShark 4.x + prlimit, **Linux** |
| UART / SPI on the board | **Recorded logic signals** — decoder annotations | sigrok-cli 0.7.2, **Linux** |
| ARM `.so` libs from pulled APKs | **Native binaries** — pseudocode, assembly, strings, xrefs | Ghidra / Hopper / IDA |

The logic-signal support pairs directly with the cheap 8-channel analyzer on
the shopping list, and the firmware tooling is what we would use on a dumped
image after rooting.

## This machine: prerequisites

Checked on 2026-10-16. Apple **M1 Pro (arm64)**, macOS.

| Requirement | Status |
|---|---|
| Node 22.x ≥22.19 / 24.x ≥24.11 / 26+ | **Fixed.** Global was v23.1.0, which REA does not support. Pinned **nodejs 24.19.0** via `.tool-versions` (already installed in asdf). Scoped to this directory — does not affect `baseline-app`. |
| npm | 10.9.0 ✓ |
| Full JDK (for JADX / Android APKs) | **Was broken** — only Java 1.8 x86_64 from the old applet plugin. Installing `openjdk@21`. |
| adb | ✓ installed earlier |
| JADX, Apktool | not installed — REA does not install providers; add when Phase A starts |
| Ghidra / Hopper / IDA | none installed; only needed for Phase C native work |
| binwalk, unblob, tshark, sigrok-cli | not installed, and **Linux-only** anyway |

### Constraints to plan around

1. **Firmware, packet captures, and logic-signal analysis are Linux-only.**
   macOS covers the Android half completely, which is most of this project. For
   Phase C, use an arm64 Linux VM (UTM / Lima / Docker) or a Raspberry Pi.
   Those three tools are not x64-gated, so arm64 Linux is fine.
2. **REA lists Android APK analysis as `Linux/macOS/Windows x64`.** We are
   arm64. JADX is Java so an arm64 JDK will probably work; if REA gates on
   architecture, fall back to Rosetta or the Linux VM. **Unverified.**
3. **The ADB guide notes testing on Android 14 (API 34).** Our target is from
   2013 and far older. Expect some tools to misbehave — `read_adb_setting`
   relies on the `settings` binary, which did not exist on early Android. Treat
   failures as version skew, not as a dead device.

## Setup — you need to run this

`npx rea-agents setup` is **interactive** (pick agents, review changes, approve)
and it **modifies this agent's configuration** — it registers REA's MCP server
and installs workflow instructions into Claude Code, with backups. That is a
change to your environment and an interactive prompt, so it is yours to run:

```bash
cd baseline-instruments      # picks up .tool-versions → node 24.19.0
node --version               # expect v24.19.0
npx rea-agents setup
```

Then restart the agent so the MCP server is picked up.

Worth knowing what you are approving: REA becomes a tool provider inside your
agent, and analysis runs locally on your machine with your permissions. That is
the normal MCP trust model, but it is a real supply-chain decision on a
six-month-old package.

## First job once it is installed

Phase A, in this order:

1. Obtain the **Recon Engage APK** (`com.reconinstruments.jetandroid`).
2. Have REA decompile it and report: Bluetooth service/characteristic UUIDs or
   RFCOMM SPP UUIDs, intent actions, any serialization of HUD data frames.
3. Write the findings into `docs/recon-protocol.md`.

That gives us Recon's own phone→HUD wire format, which is the single biggest
unknown in [architecture.md](architecture.md). We may be able to speak their
protocol instead of inventing ours — which would mean the stock HUD software
renders our data with no sideloading at all.
