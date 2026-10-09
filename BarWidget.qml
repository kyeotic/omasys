import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "omasys.task-manager"

  property real cpuPercent: 0
  property real memoryPercent: 0
  property real gpuPercent: -1
  property var previousCpu: null

  // shell.json entry settings: "display" is "stats" (default) or "icon";
  // "icon" overrides the glyph shown in icon mode (default: nf-md-clipboard_outline);
  // "collapse" hides the icon until the bar reveals its inactive indicators.
  readonly property bool iconMode: root.setting("display", "stats") === "icon"
  readonly property string iconGlyph: String(root.setting("icon", "\udb80\udd4c"))
  readonly property bool collapsed: iconMode && root.setting("collapse", false) === true
    && !(bar && bar.centerSectionRevealHeld === true && bar.centerHoverRevealSuppressed !== true)

  readonly property string pluginDir: Model.pluginDirFrom(Qt.resolvedUrl("."), Quickshell.env("HOME"), root.moduleName)
  readonly property string displayText: vertical
    ? "C " + Math.round(cpuPercent) + "%\nR " + Math.round(memoryPercent) + "%\nG "
      + (gpuPercent >= 0 ? Math.round(gpuPercent) + "%" : "--")
    : "CPU " + Math.round(cpuPercent) + "%  ·  RAM " + Math.round(memoryPercent) + "%  ·  GPU "
      + (gpuPercent >= 0 ? Math.round(gpuPercent) + "%" : "N/A")

  function refresh() {
    if (root.pluginDir !== "" && !statsProc.running) statsProc.running = true
  }

  function applyStats(raw) {
    var parsed = Model.parseSystem(raw, root.previousCpu, null)
    if (!parsed.valid) return
    root.previousCpu = parsed.cpuSnapshot
    root.cpuPercent = parsed.cpuPercent
    root.memoryPercent = parsed.memoryPercent
    root.gpuPercent = parsed.gpuPercent
  }

  function toggleTaskManager() {
    if (root.bar && root.bar.shell)
      root.bar.shell.toggle(root.moduleName, "{}")
  }

  implicitWidth: root.collapsed && !root.vertical ? 0 : button.implicitWidth
  implicitHeight: root.collapsed && root.vertical ? 0 : button.implicitHeight

  onPluginDirChanged: if (pluginDir !== "" && !iconMode) refresh()
  onIconModeChanged: if (!iconMode) refresh()
  Component.onCompleted: if (!iconMode) refresh()

  Timer {
    interval: 3000
    repeat: true
    running: root.visible && !root.iconMode
    onTriggered: root.refresh()
  }

  Process {
    id: statsProc
    command: root.pluginDir === "" ? [] : [root.pluginDir + "/scripts/collect-system.sh"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyStats(text)
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.iconMode ? root.iconGlyph : root.displayText
    fixedHeight: root.vertical && !root.iconMode ? Style.bar.iconSlot * 3 : -1
    horizontalMargin: root.iconMode ? 7.5 : 8.75
    verticalPadding: 7
    concealed: root.collapsed
    tooltipText: root.iconMode ? "OmaSys task manager" : "OmaSys task manager · right-click to refresh"
    active: !root.iconMode && (root.cpuPercent >= 90 || root.memoryPercent >= 90 || root.gpuPercent >= 90)
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) { if (!root.iconMode) root.refresh() }
      else root.toggleTaskManager()
    }
  }
}
