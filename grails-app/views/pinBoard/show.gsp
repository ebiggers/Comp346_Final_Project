<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
  <head>
    <title>Drag and Drop Test</title>
    <meta name="layout" content="main">
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'show.css')}" type="text/css">
    <style>
      #pinboard_canvas {
        /* Beware: The CSS width and height of the canvas are NOT equivalent
         * to the "width" and "height" attributes of the canvas. */
          width: ${pinboard.width}px;
          height: ${pinboard.height}px;
          border: 1px black solid;
      }
    </style>
    <r:require module="jquery"/>
    <r:script>
        $(document).ready(function(){

            // The HTML5 canvas for a pinboard, and its 2-dimensional rendering
            // context.
            var canvas = document.getElementById("pinboard_canvas");
            var ctx = canvas.getContext("2d");

            var icon_size_x = 20;
            var icon_size_y = 20;
            var items = [];
            var mousePressed = false;
            var selectedItem = null;

            function StopEvent(e) {
                e.stopPropagation();
                e.preventDefault();
            }

            function item (x,y,w,h){
                this.x = x || 0;
                this.y = y || 0;
                this.w = w || icon_size_x;
                this.h = h || icon_size_y;
            }

            // Return the canvas coordinates of an event e.  *** only works
            // correctly if the canvas width and height are the same as the css
            // width and height. ***
            function getMousePos(canvas, e) {
                var rect = canvas.getBoundingClientRect();
                return {
                    // window.devicePixelRatio is used to correct the Retina screen
                    x: (e.clientX - rect.left) /(window.devicePixelRatio*window.devicePixelRatio),
                    y: (e.clientY - rect.top) /(window.devicePixelRatio*window.devicePixelRatio)
                };
            }

            document.onmousedown = function(e) {
                mousePressed = true;
            };

            document.onmouseup = function(e) {
                mousePressed = false;
                canvas.onmousemove = null;
            };

            // Both dragenter and dragover must be cancelled for drop to work
            // correctly???
            canvas.ondragenter = StopEvent;
            canvas.ondragover = StopEvent;
            canvas.onmousedown = function(e) {
                var mousePos = getMousePos(canvas, e);
                var x = mousePos.x;
                var y = mousePos.y;
                var len = items.length;

                for (var i = len - 1; i >= 0; i--) {
                    if (items[i].x < x &&
                        items[i].y < y &&
                        (items[i].x + items[i].w) > x &&
                        (items[i].y + items[i].h) > y)
                    {
                        selectedItem = item;
                        console.log("canvas.onmousedown(): Selected item %d "
                                    + "near (%d, %d)", i, x, y);
                        canvas.onmousemove = function (e) {
                            var mousePos = getMousePos(canvas, e);
                            var x = mousePos.x;
                            var y = mousePos.y;
                            console.log("canvas.onmousemove(): Moved cursor "
                                        + "to (%d, %d)", x, y);
                        };
                        return;
                    }
                }
                console.log("canvas.onmousedown(): No item near (%d, %d)",
                            x, y);
            };

            canvas.ondrop = function(e) {
                StopEvent(e);

                files = e.dataTransfer.files;

                var mousePos = getMousePos(canvas, e);
                var x = mousePos.x;
                var y = mousePos.y;

                console.log("canvas.ondrop():  Drop event at (%d, %d)", x, y);

                // If a file was dropped, put a default file icon on the
                // pinboard, then upload the file using an AJAX call (POST)
                if (files.length == 1) {

                    var default_img = new Image();
                    default_img.onload = function() {
                        ctx.drawImage(default_img, x, y, icon_size_x, icon_size_y);
                    };
                    default_img.src = "${g.resource(dir: "images", file: "Binary-icon.png")}";

                    items.push(new item(x, y));
                    console.log("canvas.ondrop(): Added new item (there are now %d items)",
                                items.length);

                    // The FormData object simulates submitting a form using the
                    // form-data/multipart enctype (as would be used for an
                    // <input> of type "file")
                    var data = new FormData();
                    data.append("file", files[0]);
                    data.append("x_pos", x);
                    data.append("y_pos", y);
                    data.append("pinboard_id", ${pinboard.id});
                    $.ajax({
                        url: "${g.createLink(controller: 'PinBoard', action: 'uploadFile')}",
                        data: data,
                        cache: false,
                        contentType: false, // Must be false when using FormData
                        processData: false, // Must be false when using FormData
                        type: 'POST',
                        success: function(data) {
                            alert(data);
                        }
                    });
                } else {
                    if (files.length == 0) {
                        console.log("No files dropped!");
                    } else {
                        console.log("Multiple files dropped!");
                    }
                }
            };
        });
    </r:script>
  </head>
  <body>
    <div id="login_hdr">
      <div id="hello">
        <span>Hello, ${user.username}.  Welcome to your Pinboard.</span>
        <span id="logout">
          <a href="${g.createLink(controller: 'user', action: 'logout')}">
            Logout
          </a>
        </span>
      </div>
      <div id="messages">
        Simply drag files onto your pinboard to upload them!
      </div>
    </div>
    <div id="main">
      <canvas id="pinboard_canvas" width="${pinboard.width}" height="${pinboard.height}">
        Your browser does not support the HTML 5 canvas tag
      </canvas>
    </div>
  </body>
</html>
