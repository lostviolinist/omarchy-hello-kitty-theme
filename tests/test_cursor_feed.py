import importlib.util
from pathlib import Path
import unittest
from unittest.mock import MagicMock, patch

SOURCE = Path(__file__).resolve().parents[1] / "extras/sparkles/cursor-feed.py"
spec = importlib.util.spec_from_file_location("cursor_feed", SOURCE)
feed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(feed)


class CursorTests(unittest.TestCase):
    def monitor(self, **changes):
        result = dict(name="DP-1", x=0, y=0, width=1920, height=1080, scale=1, transform=0)
        result.update(changes)
        return result

    def test_fractional_scale_and_negative_origin(self):
        m = self.monitor(x=-1920, width=2880, height=1620, scale=1.5)
        p = feed.locate(dict(x=-1720, y=100), [m])
        self.assertEqual((p["x"], p["y"], p["width"], p["height"]), (200, 100, 1920, 1080))

    def test_rotated_monitor(self):
        m = self.monitor(transform=1)
        p = feed.locate(dict(x=500, y=1500), [m])
        self.assertEqual((p["width"], p["height"]), (1080, 1920))

    def test_shared_edge_belongs_to_right_monitor(self):
        monitors = [self.monitor(), self.monitor(name="DP-2", x=1920)]
        p = feed.locate(dict(x=1920, y=10), monitors)
        self.assertEqual((p["screen"], p["x"]), ("DP-2", 0))

    def test_disabled_monitor_and_gaps(self):
        self.assertIsNone(feed.locate(dict(x=50, y=50), [self.monitor(dpmsStatus=False)]))
        self.assertIsNone(feed.locate(dict(x=2500, y=50), [self.monitor()]))
        self.assertIsNone(feed.locate(dict(x=50, y=50), [self.monitor(scale=0)]))

    def test_nonfinite_cursor_rejected(self):
        with self.assertRaises(ValueError):
            feed.locate(dict(x=float("nan"), y=10), [self.monitor()])

    def test_ipc_fragmented_response(self):
        client = MagicMock()
        client.__enter__.return_value = client
        client.recv.side_effect = [b'{"x":12,', b'"y":34}', b'']
        with patch.object(feed.socket, "socket", return_value=client):
            self.assertEqual(feed.query("/example/.socket.sock", "cursorpos"), dict(x=12, y=34))
        client.connect.assert_called_once_with("/example/.socket.sock")
        client.sendall.assert_called_once_with(b"j/cursorpos")
        client.settimeout.assert_called_once_with(0.25)

    def test_bad_ipc_json_raises(self):
        client = MagicMock()
        client.__enter__.return_value = client
        client.recv.side_effect = [b'error', b'']
        with patch.object(feed.socket, "socket", return_value=client), self.assertRaises(ValueError):
            feed.query("/example/.socket.sock", "cursorpos")


if __name__ == "__main__":
    unittest.main()
