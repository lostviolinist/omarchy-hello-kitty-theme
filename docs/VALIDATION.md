# Validation

Checked on 6 November 2026. This is a first release with the full Omarchy
integration still awaiting an on-device check.

## Completed

- Ran the actual shared `Sparkle.qml` animation in a native Qt window on Xfce.
  Pink and gold stars appeared, drifted, shrank, and faded. The off switch
  stopped new particles and the live count reached zero; switching on resumed.
- Rendered 36 animation frames using Qt Quick's software renderer, with no QML
  warnings. The automated run emitted 41 particles, peaked at 12 concurrently,
  and confirmed zero particles 800 ms after switching off. The GIF in this
  folder records those rendered frames; it is a preview window, not Omarchy.
- Ten Python tests cover palette contrast, monitor transforms, negative monitor
  origins, scaling, disabled outputs, gaps, and mocked fragmented IPC responses.
- Nine JavaScript checks cover interpolation, short movements, cursor warps,
  monitor changes, and emission limits.
- Parsed all three QML files with Qt's `qmlformat`.
- Validated the manifest with the current upstream `omarchy-plugin-validate`.
- Resolved the palette with upstream `omarchy-theme-color` (58 keys).
  Foreground contrast is about 10.3:1 against the pink background; normal and
  bright named ANSI colors are at least 4.5:1.

## Still needs Omarchy

This environment runs Xfce and has no Hyprland, Quickshell, or Omarchy session.
The preview verifies the shared renderer, not compositor integration.

After installing on Omarchy 4.x, check:

1. Theme installation and refreshed terminal colors.
2. Plugin loading with no shell errors and sparkles following the pointer.
3. Click-through and typing in windows beneath the overlay.
4. Alignment across your monitor scales, rotations, and boundaries.
5. Disabling, enabling, reduced motion, and login persistence.

The IPC tests use a mock socket; no real Hyprland socket was available here.
Performance and power consumption have not been measured on physical hardware.
If the overlay causes trouble, disable it with:

```bash
omarchy plugin disable lostviolinist.hello-kitty-sparkles
```

The pink theme can remain installed independently.
