import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot

    property string currentLyric: ""
    property bool isPlaying: false
    property bool wsConnected: false
    property string idleText: "♪ SPlayer Lyrics"
    property int fontSize: 13
    property string fontFamily: ""
    property bool fontBold: false
    property bool fontItalic: false
    property bool useCustomColor: false
    property string fontColor: "#ffffff"
    property string animationType: "slide"
    property int animationDuration: 300
    property int maxWidth: 400
    property int minWidth: 150
    property string songTitle: ""
    property string songArtist: ""

    property string displayText: {
        if (!wsConnected) return "⚠ Disconnected"
        if (currentLyric.length > 0) return currentLyric
        if (songTitle.length > 0) return "♪ " + songTitle
        return idleText
    }

    // Track previous text for animation
    property string previousText: ""
    property bool animating: false

    Layout.fillHeight: true
    Layout.preferredWidth: Math.min(Math.max(lyricLabel.implicitWidth + Kirigami.Units.smallSpacing * 2, minWidth), maxWidth)
    Layout.minimumWidth: minWidth

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: function(mouse) {
        if (mouse.button === Qt.MiddleButton) {
            // Toggle play/pause on middle click
            var mainItem = compactRoot
            while (mainItem.parent) mainItem = mainItem.parent
        } else {
            root.expanded = !root.expanded
        }
    }

    // Tooltip
    hoverEnabled: true
    ToolTip.visible: containsMouse && songTitle.length > 0
    ToolTip.text: songTitle + (songArtist.length > 0 ? " - " + songArtist : "")
    ToolTip.delay: 500

    // Background container
    Item {
        id: container
        anchors.fill: parent
        clip: true

        // Current lyric text
        Text {
            id: lyricLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.smallSpacing
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.smallSpacing

            text: displayText
            elide: Text.ElideRight
            maximumLineCount: 1
            horizontalAlignment: implicitWidth < parent.width - Kirigami.Units.smallSpacing * 2 ? Text.AlignHCenter : Text.AlignLeft

            font.pixelSize: fontSize
            font.family: fontFamily.length > 0 ? fontFamily : Kirigami.Theme.defaultFont.family
            font.bold: fontBold
            font.italic: fontItalic
            color: useCustomColor ? fontColor : Kirigami.Theme.textColor

            // Animation states
            opacity: 1
            y: 0

            Behavior on opacity {
                enabled: animationType === "fade" || animationType === "slideFade"
                NumberAnimation {
                    duration: animationDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Hidden text for measuring
        Text {
            id: hiddenLabel
            visible: false
            text: displayText
            font: lyricLabel.font
        }
    }

    // Animation handling when lyrics change
    onDisplayTextChanged: {
        if (animationType === "none") {
            return
        }

        if (animationType === "fade") {
            fadeAnimation.restart()
        } else if (animationType === "slide") {
            slideAnimation.restart()
        } else if (animationType === "slideFade") {
            slideFadeAnimation.restart()
        }
    }

    // Fade animation
    SequentialAnimation {
        id: fadeAnimation
        PropertyAnimation {
            target: lyricLabel
            property: "opacity"
            from: 1; to: 0
            duration: animationDuration / 2
            easing.type: Easing.InQuad
        }
        PropertyAnimation {
            target: lyricLabel
            property: "opacity"
            from: 0; to: 1
            duration: animationDuration / 2
            easing.type: Easing.OutQuad
        }
    }

    // Slide animation
    SequentialAnimation {
        id: slideAnimation
        PropertyAnimation {
            target: lyricLabel
            property: "anchors.verticalCenterOffset"
            from: 0; to: -lyricLabel.height
            duration: animationDuration / 2
            easing.type: Easing.InQuad
        }
        PropertyAction {
            target: lyricLabel
            property: "anchors.verticalCenterOffset"
            value: lyricLabel.height
        }
        PropertyAnimation {
            target: lyricLabel
            property: "anchors.verticalCenterOffset"
            from: lyricLabel.height; to: 0
            duration: animationDuration / 2
            easing.type: Easing.OutQuad
        }
    }

    // Slide + Fade combined animation
    SequentialAnimation {
        id: slideFadeAnimation
        ParallelAnimation {
            PropertyAnimation {
                target: lyricLabel
                property: "opacity"
                from: 1; to: 0
                duration: animationDuration / 2
                easing.type: Easing.InQuad
            }
            PropertyAnimation {
                target: lyricLabel
                property: "anchors.verticalCenterOffset"
                from: 0; to: -lyricLabel.height
                duration: animationDuration / 2
                easing.type: Easing.InQuad
            }
        }
        PropertyAction {
            target: lyricLabel
            property: "anchors.verticalCenterOffset"
            value: lyricLabel.height
        }
        ParallelAnimation {
            PropertyAnimation {
                target: lyricLabel
                property: "opacity"
                from: 0; to: 1
                duration: animationDuration / 2
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: lyricLabel
                property: "anchors.verticalCenterOffset"
                from: lyricLabel.height; to: 0
                duration: animationDuration / 2
                easing.type: Easing.OutQuad
            }
        }
    }
}
