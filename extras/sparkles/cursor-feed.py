#!/usr/bin/env python3
"""Read Hyprland cursor coordinates and emit monitor-local logical positions.

Uses the local IPC socket only. No root, input-device access, packages, or network.
One long-running helper; no subprocess is started per sample.
"""
import json
import math
import os
from pathlib import Path
import socket
import sys
import time


def query(path, command):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(0.25)
        client.connect(str(path))
        client.sendall(("j/" + command).encode("ascii"))
        data = bytearray()
        while True:
            part = client.recv(65536)
            if not part:
                break
            data.extend(part)
            if len(data) > 1024 * 1024:
                raise ValueError("Oversized compositor response")
        return json.loads(data)


def locate(cursor, monitors):
    x, y = float(cursor["x"]), float(cursor["y"])
    if not math.isfinite(x) or not math.isfinite(y):
        raise ValueError("Invalid cursor coordinates")
    for monitor in monitors:
        if monitor.get("disabled") or monitor.get("dpmsStatus") is False:
            continue
        scale = float(monitor.get("scale", 1))
        if not math.isfinite(scale) or scale <= 0:
            continue
        width, height = float(monitor["width"]), float(monitor["height"])
        if int(monitor.get("transform", 0)) % 2:
            width, height = height, width
        width, height = width / scale, height / scale
        local_x, local_y = x - float(monitor["x"]), y - float(monitor["y"])
        if 0 <= local_x < width and 0 <= local_y < height:
            return {"screen": monitor["name"], "x": local_x, "y": local_y,
                    "width": width, "height": height}
    return None


def main():
    signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not signature or not runtime:
        print("Run inside an active Hyprland session.", file=sys.stderr)
        return 1
    path = Path(runtime) / "hypr" / signature / ".socket.sock"
    monitors, last_position = [], None
    refresh_at, last_move, failures = 0.0, time.monotonic(), 0
    while True:
        started = time.monotonic()
        try:
            if started >= refresh_at:
                monitors = query(path, "monitors")
                refresh_at = started + 2.0
            point = locate(query(path, "cursorpos"), monitors)
            if point is not None and point != last_position:
                print(json.dumps(point, separators=(",", ":")), flush=True)
                last_position, last_move = point, started
            elif point is None:
                last_position = None
            failures = 0
        except BrokenPipeError:
            return 0
        except (OSError, ValueError, KeyError, TypeError):
            failures += 1
            if failures == 1:
                print("Waiting for Hyprland cursor IPC.", file=sys.stderr)
            if failures >= 5:
                return 1
            time.sleep(1)
            continue
        # 30 Hz while moving, 5 Hz after one second idle.
        interval = 1 / 30 if started - last_move < 1 else 0.2
        time.sleep(max(0, interval - (time.monotonic() - started)))


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        pass
