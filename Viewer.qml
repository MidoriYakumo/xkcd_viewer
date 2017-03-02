import QtQuick 2.8
import QtQuick.Controls 2.1

Rectangle {
	id: viewer

	color: "#00101010"
	opacity: color.a * 2
	visible: opacity
	width: app.width
	height: app.height

	property bool active: false
	property alias source: large.source
	property int animeDuration: 500
	property int easingType: Easing.OutCubic

	property int startX
	property int startY

	property real zoomDelta: 1.05
	property real zoomHeight

	onActiveChanged: {
		if (active) {
			color = "#D0101010"
			large.x = startX
			large.y = startY
			large.height = 0
			startFlyIn()
		} else {
			color = "#00101010"
		}
	}

	function startFlyIn() {
		stopAnime()
		zoomHeight = height - 40
		zoomHeight = (zoomHeight>large.sourceSize.height)?large.sourceSize.height:zoomHeight
		xAnime.to = (viewer.width - viewer.zoomHeight
				   * large.sourceSize.width / large.sourceSize.height) / 2
		yAnime.to = (viewer.height - viewer.zoomHeight) / 2
		hAnime.to = viewer.zoomHeight
		startAnime()
	}

	function stopAnime(){
		xAnime.stop()
		yAnime.stop()
		hAnime.stop()
	}

	function startAnime(){
		xAnime.start()
		yAnime.start()
		hAnime.start()
	}

	Image {
		id: large
		fillMode: Image.Stretch
		width: height * sourceSize.width / sourceSize.height

		NumberAnimation on x{
			id: xAnime
			duration: viewer.animeDuration
			easing.type: viewer.easingType
		}

		NumberAnimation on y{
			id: yAnime
			duration: viewer.animeDuration
			easing.type: viewer.easingType
		}

		NumberAnimation on height{
			id: hAnime
			duration: viewer.animeDuration
			easing.type: viewer.easingType
		}

		Drag.active: wheel.drag.active
	}

	RoundButton {
		text: "\u2713"

		anchors.top: parent.top
		anchors.topMargin: height / 2
		anchors.right: parent.right
		anchors.rightMargin: width / 2
		smooth: true

		onClicked: {
			viewer.active = false
		}

		onHoveredChanged: {
			rotation = hovered ? 90 : 0
		}

		Behavior on rotation {
			NumberAnimation {
				duration: viewer.animeDuration
			}
		}
	}

	MouseArea {
		id: wheel
		anchors.fill: parent
		drag.target: large

		onWheel: {
			if (wheel.angleDelta.y > 0) {
//				if (viewer.zoomHeight + 40 < viewer.height)
					viewer.zoomHeight *= viewer.zoomDelta
			} else if (viewer.zoomHeight > 40)
				viewer.zoomHeight /= viewer.zoomDelta
			viewer.stopAnime()
			hAnime.to = viewer.zoomHeight
			xAnime.to = (viewer.width - viewer.zoomHeight
					   * large.sourceSize.width / large.sourceSize.height) / 2
			yAnime.to = (viewer.height - viewer.zoomHeight) / 2
			viewer.startAnime()
		}

		onClicked: viewer.active = false

		drag.onActiveChanged: {
			if (drag.active)
				stopAnime()
		}
	}

	Shortcut {
		sequence: "Esc"
		onActivated: viewer.active = false
	}

	Behavior on color {
		ColorAnimation {
			duration: viewer.animeDuration
		}
	}
}
