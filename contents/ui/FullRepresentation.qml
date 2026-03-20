import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: fullRoot

    property string currentLyric: ""
    property bool isPlaying: false
    property bool wsConnected: false
    property string songTitle: ""
    property string songArtist: ""
    property string coverUrl: ""
    property real currentTimeMs: 0
    property real durationMs: 0
    property var lrcData: []

    signal controlCommand(string cmd)

    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 20
    Layout.minimumWidth: Kirigami.Units.gridUnit * 16

    spacing: Kirigami.Units.smallSpacing

    // Header: cover + song info
    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        // Album cover
        Rectangle {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            Layout.preferredHeight: Kirigami.Units.gridUnit * 5
            radius: 6
            color: Kirigami.Theme.backgroundColor
            border.color: coverImage.status === Image.Ready ? "transparent" : Kirigami.Theme.disabledTextColor
            border.width: 1
            clip: true

            Image {
                id: coverImage
                anchors.fill: parent
                source: coverUrl
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
                sourceSize.width: parent.width * 2
                sourceSize.height: parent.height * 2
            }

            // Placeholder icon when no cover
            Label {
                anchors.centerIn: parent
                text: "♪"
                font.pixelSize: Kirigami.Units.gridUnit * 2
                color: Kirigami.Theme.disabledTextColor
                visible: coverImage.status !== Image.Ready
            }
        }

        // Song info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: songTitle.length > 0 ? songTitle : "No song playing"
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.3
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
                color: Kirigami.Theme.textColor
            }

            Label {
                text: songArtist.length > 0 ? songArtist : ""
                visible: songArtist.length > 0
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                elide: Text.ElideRight
                Layout.fillWidth: true
                color: Kirigami.Theme.disabledTextColor
            }

            // Current lyric highlight
            Label {
                text: currentLyric.length > 0 ? currentLyric : ""
                visible: currentLyric.length > 0
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
                font.italic: true
                elide: Text.ElideRight
                Layout.fillWidth: true
                color: Kirigami.Theme.highlightColor
            }
        }
    }

    // Connection status
    Label {
        visible: !wsConnected
        text: "⚠ Not connected to SPlayer"
        color: Kirigami.Theme.negativeTextColor
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }

    // Lyrics list - no scrollbar
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
        clip: true

        ListView {
            id: lyricsListView
            anchors.fill: parent
            model: lrcData
            spacing: 6
            currentIndex: findCurrentLyricIndex()
            highlightMoveDuration: 300
            preferredHighlightBegin: height / 2 - Kirigami.Units.gridUnit
            preferredHighlightEnd: height / 2 + Kirigami.Units.gridUnit
            highlightRangeMode: ListView.ApplyRange

            delegate: Label {
                width: lyricsListView.width
                text: {
                    var item = modelData
                    if (item.content !== undefined) return item.content
                    if (item.text !== undefined) return item.text
                    if (item.lyric !== undefined) return item.lyric
                    if (item.words && Array.isArray(item.words)) {
                        var t = ""
                        for (var i = 0; i < item.words.length; i++) {
                            t += item.words[i].word || item.words[i].text || ""
                        }
                        return t.trim()
                    }
                    return ""
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: index === lyricsListView.currentIndex
                    ? Kirigami.Theme.defaultFont.pixelSize * 1.2
                    : Kirigami.Theme.defaultFont.pixelSize
                font.bold: index === lyricsListView.currentIndex
                color: index === lyricsListView.currentIndex
                    ? Kirigami.Theme.highlightColor
                    : Kirigami.Theme.textColor
                opacity: index === lyricsListView.currentIndex ? 1.0 : 0.5
                padding: 2

                Behavior on font.pixelSize {
                    NumberAnimation { duration: 200 }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            // Empty state
            Label {
                anchors.centerIn: parent
                visible: lrcData.length === 0
                text: wsConnected ? "暂无歌词" : "未连接"
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
            }

            function findCurrentLyricIndex() {
                if (!lrcData || lrcData.length === 0) return -1
                var timeMs = currentTimeMs
                for (var i = lrcData.length - 1; i >= 0; i--) {
                    var item = lrcData[i]
                    var t = item.time !== undefined ? item.time : (item.startTime !== undefined ? item.startTime : -1)
                    if (t >= 0 && timeMs >= t) return i
                }
                return -1
            }
        }
    }

    // Progress bar
    ProgressBar {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        from: 0
        to: durationMs > 0 ? durationMs : 1
        value: currentTimeMs
    }

    // Time display
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing

        Label {
            text: formatTime(currentTimeMs)
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
        }
        Item { Layout.fillWidth: true }
        Label {
            text: formatTime(durationMs)
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
        }
    }

    // Playback controls
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        ToolButton {
            icon.name: "media-skip-backward"
            onClicked: controlCommand("prev")
            enabled: wsConnected
        }
        ToolButton {
            icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
            onClicked: controlCommand("toggle")
            enabled: wsConnected
            implicitWidth: Kirigami.Units.gridUnit * 3
            implicitHeight: Kirigami.Units.gridUnit * 3
        }
        ToolButton {
            icon.name: "media-skip-forward"
            onClicked: controlCommand("next")
            enabled: wsConnected
        }
    }

    function formatTime(ms) {
        var totalSec = Math.floor(ms / 1000)
        var min = Math.floor(totalSec / 60)
        var sec = totalSec % 60
        return min + ":" + (sec < 10 ? "0" : "") + sec
    }
}
