import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Window 2.2 as Window
import QtQuick.Controls 2.1

ApplicationWindow {
	id: app
	visibility: Window.Window.Maximized
	title: "Gallery"

	property alias viewer: viewer

	CascadeFlow {
//		anchors.fill: app
		width: app.width
		height: app.height
	}

	RoundButton {
		text: "\u274c"

		anchors.bottom: parent.bottom
		anchors.bottomMargin: height / 2
		anchors.right: parent.right
		anchors.rightMargin: width / 2

		onClicked: {
			Qt.quit()
		}
	}

	Viewer {
		id: viewer
		anchors.fill: parent
	}
}
