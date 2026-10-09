# SysMon

SysMon is a native task manager for the Omarchy Quattro shell. It adds a compact CPU, RAM, and GPU readout to the bar and opens a full system dashboard with live resource usage, searchable processes, sorting, and confirmed process controls.

![Release: 1.0.0](https://img.shields.io/badge/release-1.0.0-brightgreen)
![Omarchy: Quattro](https://img.shields.io/badge/Omarchy-Quattro-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

SysMon is a fork of [OmaSys](https://github.com/rookepoole/omasys) by Rooke Poole, which is no longer actively maintained. See [Origin](#origin) for what changed and how to migrate.

## Highlights

- Live CPU, memory, GPU, swap, root-disk, network, temperature, load, and uptime metrics.
- Bar widget with CPU, RAM, and GPU utilization; left-click opens SysMon and right-click refreshes it.
- Up to 600 processes sampled every two seconds.
- Instant filtering by PID, user, executable name, or full command line.
- Sorting by CPU, memory, name, or PID.
- Resident-memory, state, age, parent PID, owner, nice value, and command-line details.
- Confirmed actions for clean end (`SIGTERM`), force end (`SIGKILL`), suspend (`SIGSTOP`), and resume (`SIGCONT`).
- Theme-native Omarchy UI with keyboard and pointer controls.
- No daemon, database, network access, telemetry, package hook, install hook, or privilege escalation.

## Requirements

- Omarchy 4.x with the Quattro shell plugin runtime.
- Bash, procps-ng (`ps`), coreutils, and Linux `/proc`/`/sys` interfaces. These are present on a normal Omarchy installation.
- Optional: `nvidia-smi` for NVIDIA GPU utilization. AMD and compatible DRM drivers are detected through `gpu_busy_percent`. Unsupported drivers display `GPU N/A` without failing the plugin.

## Review before installation

Omarchy plugins run unsandboxed inside the long-lived shell process. Review at least these files before enabling SysMon:

- `manifest.json` — plugin identity, kinds, and entry points.
- `SysMon.qml` — full overlay and process-control UI.
- `BarWidget.qml` — compact resource sampler and launcher.
- `scripts/collect-system.sh` — read-only system metrics.
- `scripts/list-processes.sh` — read-only process sampling.
- `scripts/process-action.sh` — current-user ownership check and signal allowlist.

The process-action helper accepts only `term`, `kill`, `stop`, or `cont`; rejects PID 1; verifies that `/proc/<pid>` belongs to the current UID; and never invokes `sudo`, `pkexec`, or another elevation mechanism.

## Validate this checkout

From the repository root:

```bash
omarchy plugin validate .
./tests/run.sh
```

Validation is read-only. The test suite creates one temporary `sleep` process owned by the current user and ends that test process through the same helper used by the UI.

## Install

Install the public release and enable its bar widget:

```bash
omarchy plugin add https://github.com/kyeotic/sysmon.git --enable
```

SysMon declares `right` as its default bar section. Move it later if desired:

```bash
omarchy bar move kyeotic.sysmon --section right
```

To review a local checkout before enabling it:

```bash
git clone https://github.com/kyeotic/sysmon.git
cd sysmon
omarchy plugin validate .
./tests/run.sh
omarchy plugin add "$PWD"
omarchy plugin enable kyeotic.sysmon --section right
```

## Bar widget settings

Settings go on the widget's entry in `~/.config/omarchy/shell.json`:

```json
{ "id": "kyeotic.sysmon", "display": "icon", "icon": "󰅌" }
```

| Setting | Values | Default |
| --- | --- | --- |
| `display` | `"stats"` shows live CPU, RAM, and GPU usage; `"icon"` shows a single static glyph and stops bar sampling | `"stats"` |
| `icon` | Any glyph available in the bar font; used only when `display` is `"icon"` | `󰅌` (clipboard) |
| `collapse` | `true` hides the icon until hovering the bar's center section reveals the inactive indicators; used only when `display` is `"icon"` | `false` |

Left-click opens SysMon in either mode. Right-click refreshes only in `stats` mode.

## Open and control SysMon

Click the bar readout, or summon it directly:

```bash
omarchy-shell shell toggle kyeotic.sysmon '{}'
```

Keyboard controls:

| Key | Action |
| --- | --- |
| Type | Filter processes |
| Escape | Clear the filter; close when the filter is empty |
| Up / Down | Move the selected process |
| Page Up / Page Down | Move by ten processes |
| Home / End | Jump to the first / last process |
| F5 | Refresh system and process data |
| Space | Pause / resume automatic updates |
| Delete | Confirm a clean end (`SIGTERM`) |
| Shift+Delete | Confirm a force end (`SIGKILL`) |
| Alt+S | Confirm suspend (`SIGSTOP`) |
| Alt+R | Confirm resume (`SIGCONT`) |

Right-clicking or double-clicking a process row opens the clean-end confirmation. Every signal path displays the exact process name and PID before acting.

## Safe removal

```bash
omarchy plugin remove kyeotic.sysmon
```

Removal deletes only the plugin checkout managed by Omarchy and its bar/config reference. SysMon creates no services, hooks, caches, credentials, logs, or state files, so there is no secondary cleanup step.

## Data and privacy

SysMon reads local kernel and process information only while its UI or bar widget is active. It does not transmit data, persist process lists, record command lines, or contact the network. See [SECURITY.md](SECURITY.md) for the detailed trust boundary.

## Origin

SysMon started as a fork of [rookepoole/omasys](https://github.com/rookepoole/omasys) at OmaSys 1.0.1, used under the MIT license. The last commit before the rename is tagged `pre-split` so that changes can still be offered back upstream. See [CHANGELOG.md](CHANGELOG.md) for what changed after the fork.

SysMon uses a new plugin ID, `kyeotic.sysmon`. To migrate from OmaSys, remove the old plugin, install SysMon, and change `omasys.task-manager` to `kyeotic.sysmon` in any widget entry in `~/.config/omarchy/shell.json`:

```bash
omarchy plugin remove omasys.task-manager
omarchy plugin add https://github.com/kyeotic/sysmon.git --enable
```

For Omarchy plugin development, see the [official Omarchy shell plugin reference](https://github.com/basecamp/omarchy/blob/quattro/shell/README.md).

## License

MIT. See [LICENSE](LICENSE).
