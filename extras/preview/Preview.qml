import QtQuick
import QtQuick.Window
import "../sparkles" as Kitty
import "../sparkles/Particles.js" as Particles

Window {
    id: window
    width: 1100
    height: 700
    visible: true
    title: "Hello Kitty — sparkle rendering preview"
    color: "#FFF0F6"
    property bool sparklesEnabled: true
    property bool demo: false
    property real phase: 0
    property var previous: null
    property int liveParticles: 0
    property int emitted: 0

    function sprinkle(x, y) {
        if (!sparklesEnabled) return;
        var point = {screen: "preview", x: x, y: y, width: width, height: height};
        var samples = Particles.pointsBetween(previous, point, 12, 5);
        if (samples.length) previous = point;
        for (var i = 0; i < samples.length && liveParticles < 72; ++i) {
            var size = 9 + Math.random() * 9;
            var particle = star.createObject(effect, {
                originX: samples[i].x - size / 2,
                originY: samples[i].y - size / 2,
                width: size, height: size,
                source: Qt.resolvedUrl(Math.random() < 0.7 ? "../sparkles/star-pink.svg" : "../sparkles/star-gold.svg"),
                drift: (Math.random() - 0.5) * 26,
                lifetime: 420 + Math.random() * 240
            });
            if (particle) { liveParticles++; emitted++; }
        }
    }

    Image {
        anchors.fill: parent
        source: "../../backgrounds/01-hello-kitty.webp"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        x: 45; y: 105; width: 570; height: 430
        radius: 16
        color: "#FFF0F6"
        border.color: "#B52C66"
        border.width: 2
        Text {
            x: 30; y: 28
            text: "kitty@omarchy ~"
            font.family: "monospace"; font.pixelSize: 23
            color: "#B52C66"
        }
        Text {
            x: 30; y: 90
            text: "❯ hello, kitty\n\nA little pink. A little sparkle.\n\nMove your mouse to try the trail."
            font.family: "monospace"; font.pixelSize: 18
            lineHeight: 1.4
            color: "#493442"
        }
        Row {
            x: 30; y: 340; spacing: 10
            Repeater {
                model: ["#B52C66", "#E66B9F", "#F4C7DA", "#493442", "#356C53", "#876000", "#5165A0"]
                Rectangle { required property var modelData; width: 42; height: 30; radius: 5; color: modelData }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: mouse => { if (!window.demo) window.sprinkle(mouse.x, mouse.y); }
    }

    Item { id: effect; anchors.fill: parent }
    Component {
        id: star
        Kitty.Sparkle {
            Component.onDestruction: window.liveParticles = Math.max(0, window.liveParticles - 1)
        }
    }

    Rectangle {
        anchors.top: parent.top
        width: parent.width; height: 58
        color: "#F9E1EC"
        Text { x: 24; anchors.verticalCenter: parent.verticalCenter; text: "HELLO KITTY  /  SPARKLE PREVIEW"; color: "#493442"; font.pixelSize: 15 }
        Row {
            anchors.right: parent.right; anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter; spacing: 12
            Rectangle {
                width: 125; height: 34; radius: 8; color: "#FFF0F6"
                Text { anchors.centerIn: parent; text: window.demo ? "Stop demo" : "Play demo"; color: "#B52C66" }
                MouseArea { anchors.fill: parent; onClicked: { window.demo = !window.demo; window.previous = null; } }
            }
            Rectangle {
                width: 130; height: 34; radius: 8; color: "#B52C66"
                Text { anchors.centerIn: parent; text: window.sparklesEnabled ? "Sparkles on" : "Sparkles off"; color: "#FFF0F6" }
                MouseArea { anchors.fill: parent; onClicked: { window.sparklesEnabled = !window.sparklesEnabled; window.previous = null; } }
            }
        }
    }

    Text {
        x: 24; anchors.bottom: parent.bottom; anchors.bottomMargin: 18
        text: "Live particles: " + window.liveParticles + "  ·  Same animation component as the Omarchy plugin"
        color: "#79566B"; font.pixelSize: 13
    }
    Timer {
        interval: 33; repeat: true; running: window.demo
        onTriggered: {
            window.phase += 0.07;
            window.sprinkle(window.width * 0.5 + Math.cos(window.phase) * window.width * 0.32,
                            window.height * 0.52 + Math.sin(window.phase * 1.7) * window.height * 0.26);
        }
    }
}
