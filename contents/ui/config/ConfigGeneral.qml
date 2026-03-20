import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage

    property alias cfg_wsPort: wsPortField.value
    property alias cfg_fontSize: fontSizeField.value
    property alias cfg_fontFamily: fontFamilyField.text
    property alias cfg_fontBold: fontBoldCheck.checked
    property alias cfg_fontItalic: fontItalicCheck.checked
    property alias cfg_useCustomColor: useCustomColorCheck.checked
    property alias cfg_fontColor: fontColorField.text
    property alias cfg_animationType: animationTypeCombo.currentValue
    property alias cfg_animationDuration: animationDurationField.value
    property alias cfg_maxWidth: maxWidthField.value
    property alias cfg_idleText: idleTextField.text
    property alias cfg_preferTranslation: preferTranslationCheck.checked

    Kirigami.FormLayout {
        anchors.fill: parent

        // Connection section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Connection")
        }

        SpinBox {
            id: wsPortField
            Kirigami.FormData.label: i18n("WebSocket Port:")
            from: 1024
            to: 65535
        }

        // Font section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Font")
        }

        SpinBox {
            id: fontSizeField
            Kirigami.FormData.label: i18n("Font Size (px):")
            from: 8
            to: 48
        }

        TextField {
            id: fontFamilyField
            Kirigami.FormData.label: i18n("Font Family:")
            placeholderText: i18n("Leave empty for default")
        }

        CheckBox {
            id: fontBoldCheck
            Kirigami.FormData.label: i18n("Bold:")
        }

        CheckBox {
            id: fontItalicCheck
            Kirigami.FormData.label: i18n("Italic:")
        }

        // Color section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Color")
        }

        CheckBox {
            id: useCustomColorCheck
            Kirigami.FormData.label: i18n("Use Custom Color:")
        }

        // Preset color buttons
        Flow {
            Kirigami.FormData.label: i18n("Preset Colors:")
            enabled: useCustomColorCheck.checked
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            Repeater {
                model: [
                    { name: "Snow",       color: "#FFFFFF" },
                    { name: "Sakura",     color: "#FF9CAD" },
                    { name: "Coral",      color: "#FF6B6B" },
                    { name: "Sunset",     color: "#FF8C42" },
                    { name: "Amber",      color: "#FFB627" },
                    { name: "Lime",       color: "#A8E06C" },
                    { name: "Mint",       color: "#6CEABC" },
                    { name: "Cyan",       color: "#5BCEFA" },
                    { name: "Sky",        color: "#74B9FF" },
                    { name: "Lavender",   color: "#B19CD9" },
                    { name: "Orchid",     color: "#E88CED" },
                    { name: "Silver",     color: "#BDC3C7" }
                ]

                delegate: AbstractButton {
                    width: Kirigami.Units.gridUnit * 2.5
                    height: Kirigami.Units.gridUnit * 2.5
                    hoverEnabled: true

                    ToolTip.visible: hovered
                    ToolTip.text: modelData.name
                    ToolTip.delay: 300

                    onClicked: fontColorField.text = modelData.color

                    contentItem: Rectangle {
                        radius: width / 2
                        color: modelData.color
                        border.color: fontColorField.text === modelData.color
                            ? Kirigami.Theme.highlightColor
                            : (parent.hovered ? Kirigami.Theme.textColor : Qt.rgba(0,0,0,0.3))
                        border.width: fontColorField.text === modelData.color ? 3 : 1

                        Behavior on border.width {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Custom Color:")
            enabled: useCustomColorCheck.checked

            TextField {
                id: fontColorField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 7
                placeholderText: "#ffffff"
            }

            Rectangle {
                width: Kirigami.Units.gridUnit * 2
                height: Kirigami.Units.gridUnit * 2
                color: fontColorField.text
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
                radius: 3
            }
        }

        // Animation section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Animation")
        }

        ComboBox {
            id: animationTypeCombo
            Kirigami.FormData.label: i18n("Animation Type:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("None"), value: "none" },
                { text: i18n("Fade"), value: "fade" },
                { text: i18n("Slide"), value: "slide" },
                { text: i18n("Slide + Fade"), value: "slideFade" }
            ]
            Component.onCompleted: {
                currentIndex = indexOfValue(plasmoid.configuration.animationType)
            }
        }

        SpinBox {
            id: animationDurationField
            Kirigami.FormData.label: i18n("Animation Duration (ms):")
            from: 50
            to: 1000
            stepSize: 50
        }

        // Layout section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Layout")
        }

        SpinBox {
            id: maxWidthField
            Kirigami.FormData.label: i18n("Max Width (px):")
            from: 100
            to: 1200
            stepSize: 50
        }

        TextField {
            id: idleTextField
            Kirigami.FormData.label: i18n("Idle Text:")
            placeholderText: "♪ SPlayer Lyrics"
        }

        // Lyrics section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Lyrics")
        }

        CheckBox {
            id: preferTranslationCheck
            Kirigami.FormData.label: i18n("Prefer Translation:")
            text: i18n("Show translated lyrics when available")
        }

        // Preview section
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Preview")
        }

        Rectangle {
            Layout.fillWidth: true
            height: Kirigami.Units.gridUnit * 2
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            radius: 3

            Text {
                anchors.centerIn: parent
                text: "♪ 这是一行预览歌词 Preview Lyrics"
                font.pixelSize: fontSizeField.value
                font.family: fontFamilyField.text.length > 0 ? fontFamilyField.text : Kirigami.Theme.defaultFont.family
                font.bold: fontBoldCheck.checked
                font.italic: fontItalicCheck.checked
                color: useCustomColorCheck.checked ? fontColorField.text : Kirigami.Theme.textColor
            }
        }
    }
}
