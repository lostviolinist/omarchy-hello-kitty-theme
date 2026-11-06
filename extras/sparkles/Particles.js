// Pure geometry; shared by the QML effect and the unit checks.
function pointsBetween(previous, current, spacing, limit) {
    if (!previous || previous.screen !== current.screen) return [current];
    var dx = current.x - previous.x;
    var dy = current.y - previous.y;
    var distance = Math.sqrt(dx * dx + dy * dy);
    if (distance < spacing) return [];
    // Do not draw a line across the desktop after a pointer warp or resume.
    if (distance > 350) return [current];
    var count = Math.min(limit, Math.floor(distance / spacing));
    var result = [];
    for (var i = 1; i <= count; ++i) {
        var t = i / count;
        result.push({screen: current.screen, x: previous.x + dx * t,
                     y: previous.y + dy * t, width: current.width, height: current.height});
    }
    return result;
}
