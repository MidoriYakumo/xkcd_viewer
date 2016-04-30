import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Window 2.2 as Window

ApplicationWindow {
	id: app
// 	width: 600
// 	height: 600
	visibility: Window.Window.Maximized
	title: "Gallery"
	
	property url base:"http://kotori.us/qml/"
	property var list:["./cross.svg"]

	Flickable{
		anchors.fill:parent
		contentHeight:grid.height
		contentWidth:grid.width
		flickableDirection: Flickable.VerticalFlick

	Grid{
		id:grid
		x:(app.width-360*columns)/2
		columns:app.width/360
		Repeater{
			model: app.list
			delegate: Rectangle{
				color: "#80"+ (~~((1+Math.random())*(1<<24))).toString(16).substr(1)
				width: 360
				height: 240
				Image {
					id: small
					anchors.fill: parent
					anchors.margins: 4
					fillMode: Image.PreserveAspectCrop
					source: app.base+app.list[index]

					MouseArea {
						anchors.fill: parent
						onClicked: {
							var pos = getAbsolutePosition(this)
							fullscreen.source = small.source
							fullscreen.startX = pos.x + mouseX
							fullscreen.startY = pos.y + mouseY
							console.log("absolute pos=", fullscreen.startX,
										fullscreen.startY)
							fullscreen.visibility = Window.Window.FullScreen
						}
					}
					
				}
			}

		}
	}
	}


	ApplicationWindow {
		id: fullscreen

		title: "Fullscreen Image Viewer"
		visibility: Window.Window.Hidden
		color: "#00101010"

		property alias source:large.source
		property int animeDuration: 500
		property int easingType: Easing.OutCubic

		property int startX
		property int startY

		property real zoomDelta: 1.05
		property real zoomHeight
		property int state: 0
		height: 0

		onHeightChanged: {
			state |= 1
			if (state == 3)
				startFlyIn()
		}

		onActiveChanged: {
			if (active) {
				color = "#D0101010"
				large.x = startX
				large.y = startY
				large.height = 0
				state |= 2
				if (state == 3)
					startFlyIn()
			} else {
				color = "#00101010"
			}
		}

		function startFlyIn() {
			stopAnime()
			zoomHeight = height - 40
			zoomHeight = (zoomHeight>large.sourceSize.height)?large.sourceSize.height:zoomHeight
			xAnime.to = (fullscreen.width - fullscreen.zoomHeight
					   * large.sourceSize.width / large.sourceSize.height) / 2
			yAnime.to = (fullscreen.height - fullscreen.zoomHeight) / 2
			hAnime.to = fullscreen.zoomHeight
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
			fillMode: Image.PreserveAspectFit

			NumberAnimation on x{
				id: xAnime
				duration: fullscreen.animeDuration
				easing.type: fullscreen.easingType
			}

			NumberAnimation on y{
				id: yAnime
				duration: fullscreen.animeDuration
				easing.type: fullscreen.easingType
			}

			NumberAnimation on height{
				id: hAnime
				duration: fullscreen.animeDuration
				easing.type: fullscreen.easingType
			}

		}

		ToolButton {
			width: 32
			height: 32
			iconSource: base+"cross.svg"
			anchors.top: parent.top
			anchors.topMargin: 6
			anchors.right: parent.right
			anchors.rightMargin: 6
			smooth: true

			onClicked: {
				fullscreen.close()
			}

			onHoveredChanged: {
				rotation = hovered ? 90 : 0
			}

			Behavior on rotation {
				NumberAnimation {
					duration: fullscreen.animeDuration
				}
			}
		}

		MouseArea {
			id: wheel
			anchors.fill: parent

			onWheel: {
				if (wheel.angleDelta.y > 0) {
					if (fullscreen.zoomHeight + 40 < fullscreen.height)
						fullscreen.zoomHeight *= fullscreen.zoomDelta
				} else if (fullscreen.zoomHeight > 40)
					fullscreen.zoomHeight /= fullscreen.zoomDelta
				fullscreen.stopAnime()
				hAnime.to = fullscreen.zoomHeight
				xAnime.to = (fullscreen.width - fullscreen.zoomHeight
						   * large.sourceSize.width / large.sourceSize.height) / 2
				yAnime.to = (fullscreen.height - fullscreen.zoomHeight) / 2
				fullscreen.startAnime()
			}

			onClicked: fullscreen.close()
		}

		Shortcut {
			sequence: "Esc"
			onActivated: fullscreen.close()
		}

		Behavior on color {
			ColorAnimation {
				duration: fullscreen.animeDuration
			}
		}
	}

	function getAbsolutePosition(node) {
		var returnPos = {

		}
		returnPos.x = x
		returnPos.y = y
		if (node !== undefined && node !== null) {
			var parentValue = getAbsolutePosition(node.parent)
			returnPos.x = parentValue.x + node.x
			returnPos.y = parentValue.y + node.y
		}
		return returnPos
	}
	
	function loadImageList(){
		var xmlhttp = new XMLHttpRequest();
        var url = app.base + "images.json";

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
                var list = JSON.parse(xmlhttp.responseText)
// 				for (var i in list){
// 					console.log(list[i])
// 				}
				console.log("Total %1 files.".arg(list.length))
				app.list = list;
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
	}
	
	Component.onCompleted: loadImageList()
}
