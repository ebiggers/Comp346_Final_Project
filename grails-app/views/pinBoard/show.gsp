<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
  <head>
    <title>Drag and Drop Test</title>
    <meta name="layout" content="main">
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'show.css')}" type="text/css">
    <r:require module="jquery"/>
    <r:script>
        $(document).ready(function(){

            // The HTML5 canvas for a pinboard, and its 2-dimensional rendering
            // context.
            var canvas = document.getElementById("pinboard_canvas");
            var ctx = canvas.getContext("2d");
            var icon_size_x = 20;
            var icon_size_y = 20;

            // Both dragenter and dragover must be cancelled for drop to work
            // correctly???

            canvas.addEventListener("dragenter", StopEvent, false);
            canvas.addEventListener("dragover", StopEvent, false);
            canvas.addEventListener("drop", OnDrop, false);
            canvas.addEventListener('mousedown', OnClick, true);

            function OnClick(e){
                var mousePos = getMousePos(canvas, e);
                var x = mousePos.x;
                var y = mousePos.y;
                alert("x: "+x+" y:"+y);
            }

            function StopEvent(e) {
                e.stopPropagation();
                e.preventDefault();
            }

            // Called when an item is dropped onto the pinboard.
            function OnDrop(e) {
                StopEvent(e);

                files = e.dataTransfer.files;

                var mousePos = getMousePos(canvas, e);
                var x = mousePos.x;
                var y = mousePos.y;

                // If a file was dropped, put a default file icon on the
                // pinboard, then upload the file using an AJAX call (POST)
                if (files.length == 1) {

                    var default_img = new Image();
                    default_img.onload = function() {
                        ctx.drawImage(default_img, x, y, icon_size_x, icon_size_y);
                    };
                    default_img.src = "${g.resource(dir: "images", file: "Binary-icon.png")}";

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
                    y: (e.clientY - rect.top) /(window.devicePixelRatio*window.devicePixelRatio)
                };
            }
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
        <canvas id="pinboard_canvas">
          Your browser does not support the HTML 5 canvas tag
        </canvas>
    </div>
  </body>
</html>
