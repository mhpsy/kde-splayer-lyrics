# SPlayer Lyrics - KDE Plasma 桌面歌词组件

[English](README.md)

一个 KDE Plasma 6 面板小组件，在任务栏中实时显示 [SPlayer](https://github.com/imsyy/SPlayer) 当前播放的歌词。

![Plasma 6](https://img.shields.io/badge/Plasma-6.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 功能特性

- **面板实时歌词** — 同步显示当前播放的歌词行
- **平滑动画** — 歌词切换时支持滑动、淡入淡出、滑动+淡入淡出三种过渡效果
- **自定义样式** — 字体大小、颜色、字体、粗体/斜体均可调节，内置 12 种预设颜色
- **点击展开** — 完整歌词列表、专辑封面、播放控制
- **自动重连** — 断开后自动重新连接 SPlayer WebSocket
- **翻译支持** — 可选择优先显示翻译歌词
- **宽度控制** — 可配置最小/最大宽度，歌词居中显示

## 环境要求

- KDE Plasma 6.0+
- SPlayer 并开启 WebSocket API（默认端口：25885）
- Qt WebSockets 模块（`qt6-websockets`）

## 安装

### 从源码安装

```bash
git clone https://github.com/mhpsy/kde-splayer-lyrics.git
cd kde-splayer-lyrics
chmod +x install.sh
./install.sh
```

### 手动安装

```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.mhpsy.splayer.lyrics
cp -r contents metadata.json ~/.local/share/plasma/plasmoids/org.mhpsy.splayer.lyrics/
```

安装后，右键面板 → **添加小部件** → 搜索 **SPlayer Lyrics**。

> **提示：** 安装或更新后需要重启 plasmashell 才能加载：
>
> ```bash
> kquitapp6 plasmashell && kstart plasmashell
> ```

## 配置说明

右键组件 → **配置...** 进行设置：

| 设置项 | 说明 | 默认值 |
|--------|------|--------|
| WebSocket 端口 | SPlayer WebSocket 端口 | 25885 |
| 字体大小 | 歌词字体大小（像素） | 13 |
| 字体 | 自定义字体 | 系统默认 |
| 粗体 / 斜体 | 字体样式 | 关闭 |
| 自定义颜色 | 使用自定义文字颜色 | 关闭 |
| 预设颜色 | 12 种内置颜色快捷选择 | — |
| 动画类型 | 无 / 淡入淡出 / 滑动 / 滑动+淡入淡出 | 滑动 |
| 动画时长 | 过渡动画时长（毫秒） | 300 |
| 最小宽度 | 组件最小宽度（像素） | 150 |
| 最大宽度 | 组件最大宽度（像素） | 400 |
| 空闲文字 | 没有歌词时显示的文字 | ♪ SPlayer Lyrics |
| 优先翻译 | 有翻译歌词时优先显示翻译 | 关闭 |

## 工作原理

组件通过 WebSocket 连接 SPlayer，监听以下事件：
- `song-change` — 歌曲切换，更新歌名/歌手
- `progress-change` — 播放进度更新
- `lyric-change` — 歌词数据（LRC/YRC 格式）
- `status-change` — 播放/暂停状态

根据时间戳匹配当前歌词行，配合动画显示在面板中。

## 面板视图

在面板中显示单行当前歌词，支持动画切换。歌词居中显示，超宽时省略。点击展开详情。

## 展开视图

展开后显示：
- 专辑封面 + 歌曲信息
- 完整歌词列表（当前歌词高亮居中）
- 播放进度条
- 播放控制按钮（上一曲 / 播放暂停 / 下一曲）

## 常见问题

- **显示 "⚠ Disconnected"** — 确认 SPlayer 已运行并开启了 WebSocket
- **不显示歌词** — 当前歌曲可能没有歌词数据
- **找不到组件** — 重启 plasmashell：`kquitapp6 plasmashell && kstart plasmashell`
- **组件被挤压** — 在配置中调大「最小宽度」

## 许可证

MIT
