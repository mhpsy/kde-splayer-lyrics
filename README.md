# SPlayer Lyrics - KDE Plasma Widget

A KDE Plasma 6 widget that displays current song lyrics from [SPlayer](https://github.com/imsyy/SPlayer) in your panel/taskbar.

![Plasma 6](https://img.shields.io/badge/Plasma-6.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Real-time lyrics display** in the panel — shows the current lyric line synced with playback
- **Smooth animations** — slide, fade, or slide+fade transitions when lyrics change
- **Fully customizable** — font size, color, family, bold/italic styles
- **Click to expand** — full lyrics view with playback controls
- **Auto-reconnect** — automatically reconnects to SPlayer WebSocket
- **Translation support** — option to prefer translated lyrics when available

## Requirements

- KDE Plasma 6.0+
- SPlayer with WebSocket API enabled (default port: 25885)
- Qt WebSockets module (`qt6-websockets`)

## Installation

### From Source

```bash
git clone https://github.com/mhpsy/kde-splayer-lyrics.git
cd kde-splayer-lyrics
chmod +x install.sh
./install.sh
```

### Manual

```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.mhpsy.splayer.lyrics
cp -r contents metadata.json ~/.local/share/plasma/plasmoids/org.mhpsy.splayer.lyrics/
```

After installation, right-click on your panel → **Add Widgets** → search for **SPlayer Lyrics**.

## Configuration

Right-click the widget → **Configure...** to customize:

| Setting | Description | Default |
|---------|-------------|---------|
| WebSocket Port | SPlayer WebSocket port | 25885 |
| Font Size | Lyrics font size in pixels | 13 |
| Font Family | Custom font family | System default |
| Bold / Italic | Font style options | Off |
| Custom Color | Use a custom text color | Off |
| Animation Type | none / fade / slide / slide+fade | slide |
| Animation Duration | Transition duration in ms | 300 |
| Max Width | Maximum widget width in pixels | 400 |
| Idle Text | Text shown when no lyrics | ♪ SPlayer Lyrics |
| Prefer Translation | Show translated lyrics | Off |

## How It Works

The widget connects to SPlayer's WebSocket API and listens for:
- `song-change` — updates song title/artist
- `progress-change` — tracks current playback time
- `lyric-change` — receives lyric data (LRC/YRC format)
- `status-change` — play/pause state

It finds the current lyric line based on timestamps and displays it with smooth animations.

## Panel View

Shows the current lyric line with configurable animation. Click to expand.

## Expanded View

Shows full lyrics list with:
- Current lyric highlighted and centered
- Progress bar
- Playback controls (prev / play-pause / next)

## Troubleshooting

- **"⚠ Disconnected"** — Make sure SPlayer is running with WebSocket enabled
- **No lyrics showing** — The current song may not have lyrics data
- **Widget not found** — Try restarting plasmashell: `kquitapp6 plasmashell && kstart plasmashell`

## License

MIT
