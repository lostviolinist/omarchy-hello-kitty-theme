import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import "Particles.js" as Particles

Item {
    id: root
    property var shell: null
    property var manifest: null
    property var pluginRegistry: null
    property var barWidgetRegistry: null
    property string omarchyPath: ""
    property bool suspended: false
    readonly property bool active: !suspended && !Style.reduceMotion
    property var previous: null
    property int liveParticles: 0
    property int maxParticles: 72
    property real spacing: 12
    signal scatter(var sample)
    signal clearParticles()

    function sample(line) {
        var point;
        try { point = JSON.parse(line); } catch (error) { return; }
        if (!root.active || !point.screen || !isFinite(point.x) || !isFinite(point.y)
                || !(point.width > 0) || !(point.height > 0)) return;
        var points = Particles.pointsBetween(previous, point, spacing, 5);
        // Keep the last emitted point, so slow motion accumulates enough distance.
        if (points.length > 0) {
            previous = point;
            for (var i = 0; i < points.length; ++i) scatter(points[i]);
        }
    }

    onActiveChanged: {
        previous = null;
        feed.running = active;
        if (!active) clearParticles();
    }

    Process {
        id: feed
        command: ["python3", "-u", decodeURIComponent(Qt.resolvedUrl("cursor-feed.py").toString().replace(/^file:\/\//, ""))]
        running: root.active
        stdout: SplitParser { onRead: data => root.sample(data) }
        stderr: SplitParser { onRead: data => console.warn("Hello Kitty sparkles: " + data) }
    }

    // Recover from a compositor restart without a busy restart loop.
    Timer {
        interval: 3000
        repeat: true
        running: root.active
        onTriggered: { if (!feed.running) feed.running = true; }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: overlay
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            visible: root.active
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "hello-kitty-sparkles"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            // An empty input region passes every click through to the desktop.
            mask: Region {}

            Item {
                id: field
                anchors.fill: parent
                Connections {
                    target: root
                    function onScatter(point) {
                        if (point.screen !== overlay.screen.name || root.liveParticles >= root.maxParticles) return;
                        var size = 9 + Math.random() * 9;
                        var particle = star.createObject(field, {
                            originX: point.x / point.width * field.width - size / 2 + (Math.random() - 0.5) * 10,
                            originY: point.y / point.height * field.height - size / 2 + (Math.random() - 0.5) * 10,
                            width: size, height: size,
                            source: Qt.resolvedUrl(Math.random() < 0.7 ? "star-pink.svg" : "star-gold.svg"),
                            drift: (Math.random() - 0.5) * 26,
                            lifetime: 420 + Math.random() * 240
                        });
                        if (particle) root.liveParticles++;
                    }
                    function onClearParticles() {
                        for (var i = field.children.length - 1; i >= 0; --i) {
                            var child = field.children[i];
                            if (child.isSparkle) child.destroy();
                        }
                    }
                }
            }
        }
    }

    Component {
        id: star
        Sparkle {
            Component.onDestruction: root.liveParticles = Math.max(0, root.liveParticles - 1)
        }
    }
}
