<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html>
  <head>
    <title>Drag and Drop Test</title>
    <style type="text/css">
      #pinboard_canvas {
          // Beware: The CSS width and height of the canvas are NOT equivalent
          // to the "width" and "height" attributes of the canvas.
          width: 1280px;
          height: 800px;

          border: 1px black solid;
      }
    </style>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script>
        $(document).ready(function(){

            // The HTML5 canvas for a pinboard, and its 2-dimensional rendering
            // context.
            var canvas = document.getElementById("pinboard_canvas");
            var ctx = canvas.getContext("2d");

            // Both dragenter and dragover must be cancelled for drop to work
            // correctly???

            canvas.addEventListener("dragenter", StopEvent, false);
            canvas.addEventListener("dragover", StopEvent, false);
            canvas.addEventListener("drop", OnDrop, false);

            function StopEvent(e) {
                e.stopPropagation();
                e.preventDefault();
            }

            // Called when an item is dropped onto the pinboard.
            function OnDrop(e) {
                StopEvent(e);

                files = e.dataTransfer.files;

                var mousePos = getMousePos(canvas, e)
                var x = mousePos.x;
                var y = mousePos.y;

                // If a file was dropped, put a default file icon on the
                // pinboard, then upload the file using an AJAX call (POST)
                if (files.length == 1) {

                    var default_img = new Image();
                    default_img.onload = function() {
                        ctx.drawImage(default_img, x, y, 90, 60);
                    };
                    default_img.src = 'file_default.png';

                    // The FormData object simulates submitting a form using the
                    // form-data/multipart enctype (as would be used for an
                    // <input> of type "file")
                    var data = new FormData();
                    data.append("file", files[0]);
                    $.ajax({
                        url: "${g.createLink(controller: 'PinBoard', action: 'makeNewItem')}",
                        data: data,
                        cache: false,
                        contentType: false, // Must be false when using FormData
                        processData: false, // Must be false when using FormData
                        type: 'POST',
                        success: function(data) {
                            alert(data);
                        }
                    });
                }
            }

            // Return the canvas coordinates of an event e.  *** only works
            // correctly if the canvas width and height are the same as the css
            // width and height. ***
            function getMousePos(canvas, e) {
                var rect = canvas.getBoundingClientRect();
                return {
                    // window.devicePixelRatio is used to correct the Retina screen
                    x: (e.clientX - rect.left) /(window.devicePixelRatio*window.devicePixelRatio),
                    y: (e.clientY - rect.top) /(window.devicePixelRatio*window.devicePixelRatio),
                };
            }
        });
    </script>
  </head>
  <body>
    <canvas id="pinboard_canvas" width="1280" height="800">
      Your browser does not support the HTML 5 canvas tag
    </canvas>
  </body>
</html>
