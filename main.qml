import QtQuick 2.4

Item {
	id: app
	anchors.fill:parent

	property alias viewer: viewer

	CascadeFlow {
		anchors.fill: app
	}

	Viewer {
		id: viewer
		anchors.fill: parent
	}
}
