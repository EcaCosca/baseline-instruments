# Teardown & battery modification

Sources: iFixit answer "How do I change the battery in a recon HUD ski goggle"
(Smith I/O Recon — same Recon HUD module family), plus the Airwave 1.5 manual.
Not yet verified on our unit.

## Official position

The manual is explicit: never attempt to service the HUD yourself, including
removing or replacing the battery. Our unit is a discontinued 2013–2015 product
with a dead vendor, no warranty, and a dead battery, so this is a moot point —
but worth knowing the enclosure was not designed to be reopened.

The enclosure is rated **IP65**. Opening it will compromise that seal. If this
ends up on a helmet in the field, plan to re-seal.

## Getting in

1. **5 × Torx T-6 screws** to get into the HUD unit and reach the battery area.
2. The **battery pack itself is a separate glued case** — not screwed. Two
   reported methods:
   - Gently tap around the end of the case with a small hammer until it cracks
     along the glue line. (Reported as the less destructive option.)
   - Hot air at ~200 °C to soften the adhesive. Reported as "fairly
     destructive" — risks the cell and nearby plastics.
3. The battery connects through a **small circuit-protection board with solder
   points**.

## Battery replacement

| | |
|---|---|
| Original cell | **EVE 903041** |
| Chemistry | Lithium polymer |
| Voltage | 3.7 V nominal |
| Capacity | 1200 mAh |
| Dimensions | implied by part number: ~9.0 × 30 × 41 mm |

**Key technique:** keep the **original protection board** and solder a new
bare cell of matching voltage and capacity to it. Users report this working.
Do not discard that board.

### The low-voltage lockout trap

If a cell drops **below ~2 V**, the protection circuit latches and will refuse
to charge normally. Two ways around it:

- **Pre-charge the replacement cell to ~3 V or more before installing it.**
- Temporarily bypass the protection circuit to bring it up, then reconnect.

This is the single most common way people brick this repair. Measure before
you assemble.

### What this means for our unit

Ours charges but dies the instant it is unplugged. That is a cell with
essentially no remaining capacity, not a latched protection circuit — a latched
cell would refuse to charge at all. So the fix is cell replacement, and the
lockout note matters for the **new** cell, not the old one.

Worth measuring with a multimeter once open: resting cell voltage, and whether
it holds anything at all under load.

## Shopping (MercadoLibre)

- `bateria lipo 3.7v 1200mah`
- `bateria lipo 903041`
- `celda lipo 3.7v 1200mah sin placa`  (bare cell — we reuse the original board)

Match **dimensions first**, capacity second. A cell that is physically too
thick will not fit the goggle frame. 1200 mAh at 9 × 30 × 41 mm is a common
size, so this should be findable.

Also needed:
- `destornillador torx t6` — T-6 driver (likely in any precision bit kit)
- `multimetro` — to measure cell voltage before and after
- `cautin` / soldering iron + thin solder, for the protection board joints

## Internal photos

The FCC filing for **ZW5008** includes published **internal photos**
(document id `2026964`, ~1.5 MB PDF). Both fccid.io and apps.fcc.gov blocked
automated download from here (HTTP 403), so fetch manually in a browser:

- https://fccid.io/ZW5008/Internal-Photos/Int-2026964
- https://fccid.io/ZW5008  (index of all exhibits)

Worth having before opening the unit — it shows board layout, which is how we
find candidate **UART debug pads** without probing blind. Save it to
`hardware/fcc/` (gitignored, since it is a vendor document).

## Open questions

- Exact SoC part number (manual says 1 GHz dual-core Cortex-A9 + SGX540, which
  is OMAP4-class — likely a TI OMAP4430, to be confirmed from the board).
- Is there an exposed UART / JTAG pad set?
- Can the display module be driven independently of the Recon board? (Long
  shot, and almost certainly not worth it versus running an app on the device.)
