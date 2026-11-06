from pathlib import Path
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]


def luminance(value):
    rgb = [int(value[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in rgb]
    return sum(a * b for a, b in zip(linear, (0.2126, 0.7152, 0.0722)))


class PaletteTests(unittest.TestCase):
    def test_terminal_text_contrast(self):
        palette = tomllib.loads((ROOT / "colors.toml").read_text())
        for key in ("foreground", "accent", "dark_foreground", "red", "yellow", "orange",
                    "green", "cyan", "blue", "magenta", "bright_red", "bright_yellow",
                    "bright_green", "bright_cyan", "bright_blue", "bright_magenta"):
            ratio = (luminance(palette["background"]) + 0.05) / (luminance(palette[key]) + 0.05)
            with self.subTest(color=key):
                self.assertGreaterEqual(ratio, 4.5)

    def test_selected_text_contrast(self):
        palette = tomllib.loads((ROOT / "colors.toml").read_text())
        ratio = (luminance(palette["selection"]) + 0.05) / (luminance(palette["selection_foreground"]) + 0.05)
        self.assertGreaterEqual(ratio, 4.5)

    def test_shell_toml_parses(self):
        tomllib.loads((ROOT / "shell.toml").read_text())


if __name__ == "__main__":
    unittest.main()
