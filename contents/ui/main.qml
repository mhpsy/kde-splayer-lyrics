import QtQuick
import QtWebSockets
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Configuration bindings
    property int wsPort: plasmoid.configuration.wsPort
    property int fontSize: plasmoid.configuration.fontSize
    property string fontFamily: plasmoid.configuration.fontFamily
    property bool fontBold: plasmoid.configuration.fontBold
    property bool fontItalic: plasmoid.configuration.fontItalic
    property bool useCustomColor: plasmoid.configuration.useCustomColor
    property string fontColor: plasmoid.configuration.fontColor
    property string animationType: plasmoid.configuration.animationType
    property int animationDuration: plasmoid.configuration.animationDuration
    property int maxWidth: plasmoid.configuration.maxWidth
    property string idleText: plasmoid.configuration.idleText
    property bool preferTranslation: plasmoid.configuration.preferTranslation

    // Lyrics state
    property var lrcData: []
    property var yrcData: []
    property string currentLyric: ""
    property real currentTimeMs: 0
    property real durationMs: 0
    property bool isPlaying: false
    property string songTitle: ""
    property string songArtist: ""
    property string coverUrl: ""
    property bool wsConnected: false

    preferredRepresentation: compactRepresentation

    compactRepresentation: CompactRepresentation {
        currentLyric: root.currentLyric
        isPlaying: root.isPlaying
        wsConnected: root.wsConnected
        idleText: root.idleText
        fontSize: root.fontSize
        fontFamily: root.fontFamily
        fontBold: root.fontBold
        fontItalic: root.fontItalic
        useCustomColor: root.useCustomColor
        fontColor: root.fontColor
        animationType: root.animationType
        animationDuration: root.animationDuration
        maxWidth: root.maxWidth
        songTitle: root.songTitle
        songArtist: root.songArtist
    }

    fullRepresentation: FullRepresentation {
        currentLyric: root.currentLyric
        isPlaying: root.isPlaying
        wsConnected: root.wsConnected
        songTitle: root.songTitle
        songArtist: root.songArtist
        coverUrl: root.coverUrl
        currentTimeMs: root.currentTimeMs
        durationMs: root.durationMs
        lrcData: root.lrcData

        onControlCommand: function(cmd) {
            sendControl(cmd)
        }
    }

    WebSocket {
        id: ws
        url: "ws://127.0.0.1:" + wsPort
        active: true

        onStatusChanged: {
            if (status === WebSocket.Open) {
                root.wsConnected = true
                // Request current song info
                ws.sendTextMessage(JSON.stringify({ type: "get-song-info" }))
            } else if (status === WebSocket.Closed || status === WebSocket.Error) {
                root.wsConnected = false
                reconnectTimer.start()
            }
        }

        onTextMessageReceived: function(message) {
            handleMessage(message)
        }
    }

    Timer {
        id: reconnectTimer
        interval: 3000
        repeat: false
        onTriggered: {
            ws.active = false
            ws.active = true
        }
    }

    Timer {
        id: requestSongInfoTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (ws.status === WebSocket.Open) {
                ws.sendTextMessage(JSON.stringify({ type: "get-song-info" }))
            }
        }
    }

    Timer {
        id: heartbeatTimer
        interval: 30000
        repeat: true
        running: ws.status === WebSocket.Open
        onTriggered: {
            if (ws.status === WebSocket.Open) {
                ws.sendTextMessage("PING")
            }
        }
    }

    function handleMessage(raw) {
        // Handle PONG
        if (raw === "PONG") return

        var msg
        try {
            msg = JSON.parse(raw)
        } catch (e) {
            return
        }

        switch (msg.type) {
        case "welcome":
            break

        case "song-info":
            if (msg.data) {
                songTitle = msg.data.playName || msg.data.name || ""
                songArtist = msg.data.artistName || msg.data.artists || ""
                coverUrl = msg.data.cover || ""
                currentTimeMs = (msg.data.currentTime || 0)
                durationMs = (msg.data.duration || 0)
                if (msg.data.lrcData && msg.data.lrcData.length > 0) lrcData = msg.data.lrcData
                if (msg.data.yrcData && msg.data.yrcData.length > 0) yrcData = msg.data.yrcData
                isPlaying = (msg.data.playStatus === "play")
                updateCurrentLyric()
            }
            break

        case "status-change":
            if (msg.data) {
                isPlaying = msg.data.status === true
            }
            break

        case "song-change":
            if (msg.data) {
                songTitle = msg.data.name || ""
                songArtist = msg.data.artist || ""
                durationMs = msg.data.duration || 0
                coverUrl = ""
                currentLyric = ""
                lrcData = []
                yrcData = []
                // Request full song info to get lyrics & cover
                requestSongInfoTimer.restart()
            }
            break

        case "progress-change":
            if (msg.data) {
                currentTimeMs = msg.data.currentTime || 0
                durationMs = msg.data.duration || 0
                updateCurrentLyric()
            }
            break

        case "lyric-change":
            if (msg.data) {
                if (msg.data.lrcData && msg.data.lrcData.length > 0) lrcData = msg.data.lrcData
                if (msg.data.yrcData && msg.data.yrcData.length > 0) yrcData = msg.data.yrcData
                updateCurrentLyric()
            }
            break

        case "error":
            console.log("SPlayer WS error:", msg.data ? msg.data.message : "unknown")
            break
        }
    }

    function updateCurrentLyric() {
        var lyrics = getLyricsArray()
        if (!lyrics || lyrics.length === 0) {
            currentLyric = ""
            return
        }

        var timeMs = currentTimeMs
        var found = ""

        for (var i = lyrics.length - 1; i >= 0; i--) {
            var item = lyrics[i]
            var startTime = item.time !== undefined ? item.time : (item.startTime !== undefined ? item.startTime : -1)
            if (startTime < 0) continue

            if (timeMs >= startTime) {
                found = extractLyricText(item)
                break
            }
        }

        if (found !== currentLyric) {
            currentLyric = found
        }
    }

    function getLyricsArray() {
        // Prefer yrcData (word-by-word) if available, else lrcData
        if (yrcData && yrcData.length > 0) return yrcData
        if (lrcData && lrcData.length > 0) return lrcData
        return []
    }

    function extractLyricText(item) {
        // Handle different lyric formats
        // yrcData items may have words array
        if (item.words && Array.isArray(item.words)) {
            var text = ""
            for (var i = 0; i < item.words.length; i++) {
                text += item.words[i].word || item.words[i].text || ""
            }
            return text.trim()
        }

        // lrcData items
        if (preferTranslation && item.tran && item.tran.length > 0) {
            return item.tran
        }
        if (item.content !== undefined) return item.content
        if (item.text !== undefined) return item.text
        if (item.lyric !== undefined) return item.lyric

        // If item has both original and translation
        if (item.originalLyric) return item.originalLyric

        return ""
    }

    function sendControl(command) {
        if (ws.status === WebSocket.Open) {
            ws.sendTextMessage(JSON.stringify({
                type: "control",
                data: { command: command }
            }))
        }
    }

    onWsPortChanged: {
        ws.active = false
        ws.active = true
    }
}
