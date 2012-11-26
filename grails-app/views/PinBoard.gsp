<%--
  Created by IntelliJ IDEA.
  User: Yu
  Date: 11/25/12
  Time: 9:20 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html>
<head>
    <title>Drag and Drop Test</title>
    <style type="text/css">
    #work_area {
        width:1280px;
        height:800px;
        border:1px solid;
    }
    </style>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script>
        $(document).ready(function(){
            var canvas;
            canvas = document.getElementById("work_area");
            canvas.addEventListener("dragenter", OnDragEnter, false);
            canvas.addEventListener("dragover", OnDragOver, false);
            canvas.addEventListener("drop", OnDrop, false);

            function OnDragEnter(e) {
                e.stopPropagation();
                e.preventDefault();
            }

            function OnDragOver(e) {
                e.stopPropagation();
                e.preventDefault();
            }

            function OnDrop(e) {
                e.stopPropagation();
                e.preventDefault();
                selectedFiles = e.dataTransfer.files;
                var mousePos = getMousePos(canvas, e)
                var x = mousePos.x;
                var y = mousePos.y;
                var ctx = canvas.getContext('2d');
                var default_img = new Image();
                default_img.onload = function(){
                    ctx.drawImage(default_img,x,y,12,12);
                };
                default_img.src = 'file_default.png';
                /*
                  try{
                      $.ajax({
                          type: "POST",
                          url: "${g.createLink(controller: 'PinBoard', action: 'makeNewItem')}",
                          data: {xCoordinate: x, yCoordinate: y, file: selectedFiles[0]},
                          success: function(response) {
                              alert("Saved");
                          }
                      });
                  }
                  catch(err){
                      alert(err)
                  }
                */
            }

            function getMousePos(can, evt) {
                var rect = can.getBoundingClientRect();
                return {
                    x: (evt.clientX - rect.left)/(window.devicePixelRatio*window.devicePixelRatio),
                    y: (evt.clientY - rect.top)/(window.devicePixelRatio*window.devicePixelRatio)
                    //window.devicePixelRatio is used to correct the Retina screen
                    //x: evt.clientX,
                    //y: evt.clientY
                };
            }
        });
    </script>
</head>
<body>
<canvas id="work_area">
    Your browser does not support the HTML 5 canvas Tag
</canvas>
</body>
</html>
