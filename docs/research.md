# Research log

## 2026-10-16 — initial survey

### Sources consulted

- Engadget, "Recon Instruments defrosts its Android SDK at Google I/O" (2012-06-28)
  https://www.engadget.com/2012-06-28-recon-instruments-delivers-android-sdk.html
  → Recon released a **public Android SDK** in June 2012, "fully compatible
    with MOD Live". This is the same HUD as the Airwave.

- MobileSportsReport, "Recon Instruments Seeks to Enlarge Heads-Up Display App
  Space with SDK" (2012)
  https://www.mobilesportsreport.com/2012/06/recon-instruments-seeks-to-enlarge-app-space-with-sdk/
  → MOD Live sensor list: altimeter, barometer, 3-axis accel, 3-axis gyro,
    3-axis magnetometer, temperature, GPS, Bluetooth Smart Ready.

- blog.fsck.com, "Recon MOD Live - a hackable $300 Android wearable (sort of)"
  (2013-05-28)
  https://blog.fsck.com/2013/05/28/recon-mod-live-a-hackable-300-android-wearable-sort-of/
  → **Android 2.3 Gingerbread**.
  → Display is a **Kopin** microdisplay (exact model not identified).
  → **No signature verification on update packages**: "if you can get it to
    install an update.zip, it won't check the signatures. Which means it's
    pretty easy to root."
  → Post is preliminary; author never published the follow-up details.

- Wikipedia, Recon Instruments
  https://en.wikipedia.org/wiki/Recon_Instruments
  → Company history, Intel acquisition.

### Leads not yet followed

- **recon-developers Google Group** — has a thread "Where do I find the Mod
  Live SDK?" https://groups.google.com/g/recon-developers/c/kzyryMRG5ZE
  Likely contains SDK mirrors and real developer Q&A. HIGH VALUE.

- **XDA thread "[Q] Recon MOD Live"** https://xdaforums.com/t/q-recon-mod-live.2052513/
  Returns HTTP 403 to automated fetch — needs manual read in a browser.

- **XDA "Recon Jet Basic Info"** https://xdaforums.com/t/recon-jet-basic-info.3086703/page-4
  Different device (Jet, later product) but same vendor and toolchain;
  mentions adb file transfers. Worth reading for method.

- **developers.reconinstruments.com** — dead. archive.org could not be fetched
  from this environment; retry manually via a browser:
  https://web.archive.org/web/*/developers.reconinstruments.com*

- **Recon Engage APK** is mirrored publicly
  https://apkpure.com/recon-engage/com.reconinstruments.jetandroid
  Package name `com.reconinstruments.jetandroid`. Decompiling this should
  reveal the device-side protocol (BT/WiFi pairing, data push). HIGH VALUE —
  this is the companion app that talked to the HUD.

- **MOD Live firmware 2.1.1** mirrored at https://mod-live.soft112.com/
  Unverified mirror; treat downloads from soft112 with suspicion, but a
  firmware image would be very useful if it checks out.

### Tooling decision

Adopted **REA** (`morluto/rea`) as the analysis toolchain on 2026-10-16.
Verified authentic via the GitHub API and npm registry; note that several
impostor repos with copied READMEs exist. Capability map, prerequisites and
caveats: [rea-workflow.md](rea-workflow.md).

### Open questions

- Does the Airwave run `adbd`, and is it on by default over USB?
- Display resolution and how an app addresses it (standard Android Surface, or
  a Recon-specific view/overlay API?).
- Is there a UART debug pad on the board?
- Which Recon board revision is in the Airwave vs. standalone MOD Live?
