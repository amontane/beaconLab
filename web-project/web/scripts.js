var canvasHeight = 800;
var canvasWidth = 800;
var gridHoriz = 10;
var gridVertic = 10;

var NORMALIZED_HEIGHT = 1200;
var NORMALIZED_WIDTH = 1200;
var REAL_HEIGHT = 6.0;
var REAL_WIDTH = 6.0;

var thingWidth = 50;
var thingHeight = 50;

var colorArray = ["#22ff22", "#ff2222", "#2222ff"];
var idArray = ["2100-17714", "4097-4182", "51914-61642"];
var imgArray = ["img/whitney.png", "img/cayetana.png", "img/margaret.png"];

var trilaterateMode = false;
var areaRangeMode = false;
var autoUpdate = false;

var autoUpdateTimeout;

function loading(show) {
	if (show) {
		$(".loader").css("display","block");
	} else {
		$(".loader").css("display","none");
	}
	
}

function getData (updateSliders, freeView) {
	if (!freeView) {
		loading(true);
	}
	$.get("http://192.168.1.110:8006/get.cgi", function(dataArray) {
		var index = 0;
		var trilaterateArray = [];
		for (index = 0; index < dataArray.beacons.length; index++) {
			var thisBeacon = dataArray.beacons[index];
			realIndex = idArray.indexOf(thisBeacon.id);
			if (realIndex >= 0) {
				internalId = realIndex + 1;
				if (updateSliders) {
					if (thisBeacon.image) {
						imgArray[realIndex] = thisBeacon.image;
					}
					var sliderXValue = parseInt((parseFloat(thisBeacon.posx) * NORMALIZED_WIDTH) / REAL_WIDTH);
					var sliderYValue = parseInt((parseFloat(thisBeacon.posy) * NORMALIZED_HEIGHT) / REAL_HEIGHT);
					var sliderAreaValue = parseInt((parseFloat(thisBeacon.area) * NORMALIZED_WIDTH) / REAL_WIDTH);
					$("#slider" + internalId + " .sli_x")[0].value = sliderXValue;
					$("#slider" + internalId + " .sli_y")[0].value = sliderYValue;
					$("#slider" + internalId + " .sli_area")[0].value = sliderAreaValue;
					updateThing(internalId, true);
				}

				if (trilaterateMode) {
					trilaterateArray.push({x:thisBeacon.posx, y:thisBeacon.posy, d:thisBeacon.dist});
				}

				if (areaRangeMode) {
					if (parseFloat(thisBeacon.area) < (parseFloat(thisBeacon.dist) * 2)) {
						$("#beacon" + internalId + " .areaCanvas").removeClass("found");
					} else {
						$("#beacon" + internalId + " .areaCanvas").addClass("found");
					}
					updateThing(internalId, true);
				}
			}
		}
		if (trilaterateMode) {
			var pair = trilaterate(trilaterateArray);
			var posx = pair[0];
			var posy = pair[1];
			// TODO: position sometihing

			var posxCanvas = parseInt((parseFloat(posx) * canvasWidth) / REAL_WIDTH);
			var posyCanvas = parseInt((parseFloat(posy) * canvasHeight) / REAL_HEIGHT);
			var tab = $("#tablet")[0];
			$(tab).css("left", posxCanvas - 25);
			$(tab).css("top", posyCanvas - 25);
			$(tab).css("display","block");
		} else {
			$("#tablet").css("display","none");
		}
	}).always(function(){
		loading(false);
		if (autoUpdate) {
			autoUpdateTimeoutStart();
		}
	});
}

function uploadChanges (number) {
	var id = idArray[parseInt(number) - 1];
	var sliderXValue = $("#slider" + number + " .sli_x")[0].value;
	var sliderYValue = $("#slider" + number + " .sli_y")[0].value;
	var sliderAreaValue = $("#slider" + number + " .sli_area")[0].value;
	var sliderXValue = parseFloat(parseInt(sliderXValue) * REAL_WIDTH) / NORMALIZED_WIDTH;
	var sliderYValue = parseFloat(parseInt(sliderYValue) * REAL_HEIGHT) / NORMALIZED_HEIGHT;
	var sliderAreaValue = parseFloat(parseInt(sliderAreaValue) * REAL_WIDTH) / NORMALIZED_WIDTH;
	var queryString = "id=" + id + "&posx=" + sliderXValue + "&posy=" + sliderYValue + "&area=" + sliderAreaValue;
	loading(true);
	$.get("http://192.168.1.110:8006/post.cgi?" + queryString, function(dataArray) {

	}).always(function() {
		loading(false);
	});
}

function paintPolygon (vertices, lineColor, canvasId) {
	if (vertices.length < 4) {
		return;
	}

	var firstX = vertices[0];
	var firstY = vertices[1];
	var mineCanvas = document.getElementById(canvasId);
	var ctx = mineCanvas.getContext("2d");
	ctx.strokeStyle = lineColor;
	ctx.lineWidth = 3;
	ctx.beginPath();
	ctx.moveTo(firstX,firstY);

	for (var i = 2; i < vertices.length; i+=2) {
		var x1 = vertices[i];
		var y1 = vertices[i+1];
		
		ctx.lineTo(x1,y1);
		ctx.stroke();
	}

	ctx.lineTo(firstX, firstY);
	ctx.stroke();

}

function paintGrid (lineColor, canvasId) {
	var horSpace = canvasWidth / gridHoriz;
	var verSpace = canvasHeight / gridVertic;
	var canvas = document.getElementById(canvasId);
	var ctx = canvas.getContext("2d");
	ctx.strokeStyle = lineColor;
	ctx.lineWidth = 1;
	var index;
	for (index = 0; index < canvasHeight; index += horSpace) {
		ctx.beginPath();
		ctx.moveTo(0,index);
		ctx.lineTo(canvasWidth, index);
		ctx.stroke();
	}
	for (index = 0; index < canvasWidth; index += verSpace) {
		ctx.beginPath();
		ctx.moveTo(index, 0);
		ctx.lineTo(index, canvasHeight);
		ctx.stroke();
	}
}

function paintRoom (canvasId) {
	getData(true);
	roomArray = [69,171,112,171,112,98,1029,98,1029,171,1095,171,1095,470,644,1162,112,1162,112,1096,69,1096]; 
	normArray = adjustCoordArrayToNormalized(roomArray);
	paintGrid("#c0c0c0", canvasId);
	paintPolygon(normArray, "#333333", canvasId);
}

function adjustCoordArrayToNormalized(array) {
	if (array.length % 2) {
		return true;
	}
	var newArray = [];
	newArray.length = array.length;
	for (var i = 0; i < array.length; i+=2) {
		newArray[i] = array[i] * canvasWidth / NORMALIZED_WIDTH;
		newArray[i+1] = array[i+1] * canvasHeight / NORMALIZED_HEIGHT;
	}
	return newArray;
}

function updateThing(number, modifyArea) {
	var circle = $("#beacon" + number + " .areaCanvas")[0];
	if (modifyArea) {
		var sliArea = $("#slider" + number + " .sli_area")[0];
		var w = ((parseInt(sliArea.value) * canvasWidth) / NORMALIZED_WIDTH);
		var h = ((parseInt(sliArea.value) * canvasHeight) / NORMALIZED_HEIGHT);
		circle.width = w;
		circle.height = h;
		circle.style.width = w
		circle.style.height = h
		circle.style.left = (50-w) / 2;
		circle.style.top = (50-h) / 2;
		var ctx = circle.getContext("2d");

		var color = colorArray[number-1];

		ctx.beginPath();

		ctx.arc(w/2,h/2,w/2,0,2*Math.PI);

		if ($(circle).hasClass("found")) {
			ctx.fillStyle = color;
			ctx.fill();
		} else {
			ctx.strokeStyle = color;
			ctx.stroke();
		}
	}

	var sliX = $("#slider" + number + " .sli_x")[0];
	var sliY = $("#slider" + number + " .sli_y")[0];
	
	var div = $("#beacon" + number)[0];

	div.style.left = (((parseInt(sliX.value) * canvasWidth) / NORMALIZED_WIDTH) - (thingWidth/2));
	div.style.top = (((parseInt(sliY.value) * canvasHeight) / NORMALIZED_HEIGHT) - (thingHeight/2));

	// TODO: unlock this
	$("#beacon"+ number + " img")[0].src = imgArray[parseInt(number) - 1];
	$("#slider"+ number + " img")[0].src = imgArray[parseInt(number) - 1];
}

function abs(number) {
	var num = parseFloat(number);
	if (num < 0) {
		num = 0-num;
	}
	return num;
}
function exp2(number) {
	var num = parseFloat(number);
	return num*num;
}

function trilaterate(data) {
	var calcdX = 0.0;
	var calcdY = 0.0;
	var p1 = 0;
	var p2 = 1;
	var p3 = 2;
	var min_distance = abs(data[0].y - data[1].y);
	var min_distance_candidate = abs(data[0].y - data[2].y);
			
	if (min_distance > min_distance_candidate) {
		p1 = 0;
		p2 = 2;
		p3 = 1;
		min_distance = min_distance_candidate;
	}
	
	min_distance_candidate = abs(data[1].y - data[2].y);
	if (min_distance > min_distance_candidate) {
		p1 = 1;
		p2 = 2;
		p3 = 0;
		min_distance = min_distance_candidate;
	}

	var z = [
		[0, 0, data[p1].d],
		[data[p2].x-data[p1].x, data[p2].y-data[p1].y, data[p2].d],
		[data[p3].x-data[p1].x, data[p3].y- data[p1].y, data[p3].d]
	];
		
	calcdX = ((exp2(z[0][2]) - exp2(z[1][2]) + exp2(z[1][0])) / (2 * z[1][0])) + data[p1].x;
	calcdY = ((exp2(z[0][2]) - exp2(z[2][2]) + exp2(z[2][0]) + exp2(z[2][1])) / ((2*z[2][1]) - ((z[2][0] - z[2][1]) * calcdY ))) + data[p1].y;

	return [calcdX, calcdY];
}

function autoUpdateTimeoutStart() {
	autoUpdateTimeoutCancel();
	autoUpdateTimeout = setTimeout(function(){
		getData(false,true);
	}, 1000);
}

function autoUpdateTimeoutCancel() {
	if (autoUpdateTimeout) {
		clearTimeout(autoUpdateTimeout);
	}
	autoUpdateTimeout = null;
}

function setUp() {
	$(".canvasHolder").css("height", canvasHeight);
	$(".canvasHolder").css("width", canvasWidth);
	var mX = thingWidth / 2;
	var mY = thingHeight / 2;
	$(".canvas_holder").css("margin", mY + "px " + mX + "px " + mY + "px " + mX + "px");
}

function toggleScanMode() {
	var button = $($(".togglebut#scanMode")[0]);
	var isOn = button.hasClass("on");
	if (isOn) {
		button.removeClass("on");
		autoUpdate = false;
		
	} else {
		button.addClass("on");
		autoUpdate = true;
		
	}

	if (autoUpdate) {
		autoUpdateTimeoutStart();
	} else {
		autoUpdateTimeoutCancel();
	}
}

function toggleAreaMode() {
	var button = $($(".togglebut#areaMode")[0]);
	var isOn = button.hasClass("on");
	if (isOn) {
		button.removeClass("on");
		areaRangeMode = false;
		$(".beaconHolder .areaCanvas").css("visibility","hidden");
		$(".sliderGroup .slider.area").css("visibility","hidden");
	} else {
		button.addClass("on");
		areaRangeMode = true;
		$(".beaconHolder .areaCanvas").css("visibility","visible");
		$(".sliderGroup .slider.area").css("visibility","visible");
	}


}

function toggleTriangleMode() {
	var button = $($(".togglebut#triangleMode")[0]);
	var isOn = button.hasClass("on");
	if (isOn) {
		button.removeClass("on");
		trilaterateMode = false;
		$("#tablet").css("display","none");
	} else {
		button.addClass("on");
		trilaterateMode = true;
		$("#tablet").css("display","block");
	}

}

$(document).ready(function() {
	setUp();
});