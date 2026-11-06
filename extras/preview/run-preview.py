#!/usr/bin/env python3
"""Optional cross-desktop renderer preview; requires PySide6-Essentials.

This is not a Wayland overlay test and does not install or change your theme.
"""
from pathlib import Path
import sys
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.load(QUrl.fromLocalFile(str(Path(__file__).with_name("Preview.qml"))))
if not engine.rootObjects():
    raise SystemExit(1)
raise SystemExit(app.exec())
