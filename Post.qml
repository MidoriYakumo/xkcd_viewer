import QtQuick 2.0

Item {
	id: root
	width: 200
	height: 0
	opacity: 0

	property int seed: Math.random()*1700 + 1
	property Viewer viewer

	//http://xkcd.com/1750/

	function getAbsolutePosition(node) {
		var returnPos = ({})
		returnPos.x = x
		returnPos.y = y
		if (node !== undefined && node !== null) {
			var parentValue = getAbsolutePosition(node.parent)
			returnPos.x = parentValue.x + node.x
			returnPos.y = parentValue.y + node.y
		}
		return returnPos
	}

	Image {
		id: img
		anchors.fill: parent
		asynchronous: true
		onSourceSizeChanged: {
			root.height = sourceSize.height*root.width/sourceSize.width
			root.opacity = 1
		}

		onStatusChanged: {
			if (status == Image.Ready)
				console.log("<- %1".arg(img.source))
		}
	}

	MouseArea {
		anchors.fill: parent

		onClicked: {
			if (!viewer)
				return

			var pos = getAbsolutePosition(this)
			viewer.source = img.source
			viewer.startX = pos.x + mouseX
			viewer.startY = pos.y + mouseY
			console.log("absolute pos=", viewer.startX,
						viewer.startY)
			viewer.active = true
		}
	}

	Behavior on opacity {
		NumberAnimation {
			duration: 400
		}
	}

	Component.onCompleted: {
		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
				console.log("<- http://xkcd.com/%1/".arg(root.seed))
				var t = xhr.responseText
				var p = t.search("<div id=\"comic\">")
				t = t.slice(p)
				p = t.search("src=")
				t = t.slice(p+5)
				p = t.search('"')
				t = t.slice(0, p)
				console.log("-> http:%1".arg(t))
				img.source = "http:"+t
			}
		}

		console.log("-> http://xkcd.com/%1/".arg(root.seed))
		xhr.open("GET", "http://xkcd.com/%1/".arg(root.seed))
		xhr.send()
	}
}
