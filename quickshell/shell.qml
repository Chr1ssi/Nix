import Quickshell
import QtQuick

ShellRoot {
	id: root

	property string currentTime: Qt.formatDateTime(new Date(), "ddd, dd.MM. hh:mm")

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: root.currentTime = Qt.formatDateTime(new Date(), "ddd, dd.MM. hh.mm")
	}

	Variants {
		model: Quickshell.screens

		delegate: Component {
			PanelWindow {
				required property var modelData
				screen: modelData

				anchors {
					top: true
					left: true
					right: true
				}

				implicitHeight: 32
				exclusiveZone: 32

				Rectangle {
					anchors.fill: parent
					color: "#1e1e2e"

					Text {
						anchors {
							left:parent.left
							leftMargin: 12
							verticalCenter: parent.verticalCenter
						}

						color: "#cdd6f4"
						text: "NixOS"
					}

					Text {
						anchors.centerIn: parent
						color: "#cdd6f4"
						text: root.currentTime
					}

					Text {
						anchors {
							right: parent.right
							rightMargin: 12
							verticalCenter: parent.verticalCenter
						}

						color: "#89b4fa"
						text: "Quickshell"
					}
				}
			}
		}
	}
}
