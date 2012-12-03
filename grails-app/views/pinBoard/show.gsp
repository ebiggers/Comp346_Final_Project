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
      }
    </style>
    <r:require module="jquery"/>
    <r:script>
        $(document).ready(function(){

            // The HTML5 canvas for a pinboard, and its 2-dimensional rendering
            // context.
            var canvas = document.getElementById("pinboard_canvas");
            var ctx = canvas.getContext("2d");

            var ICON_SIZE_X = 60;
            var ICON_SIZE_Y = 60;
            var items = [];
            var mousePressed = false;
            var selectedItem = null;
            var selected_x_offset;
            var selected_y_offset;

            //This deals with the Retina screen for canvas
            if (window.devicePixelRatio) {
                var hidefCanvasWidth = $(canvas).attr('width');
                var hidefCanvasHeight = $(canvas).attr('height');
                var hidefCanvasCssWidth = hidefCanvasWidth;
                var hidefCanvasCssHeight = hidefCanvasHeight;

                $(canvas).attr('width', hidefCanvasWidth * window.devicePixelRatio);
                $(canvas).attr('height', hidefCanvasHeight * window.devicePixelRatio);
                $(canvas).css('width', hidefCanvasCssWidth);
                $(canvas).css('height', hidefCanvasCssHeight);
                ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
            }


            $.ajax({
                url: "${g.createLink(controller: 'PinBoard', action: 'listItems')}",
                type: 'GET',
                data: { "pinboard_id" : "${pinboard.id}" },
                success: function(data) {
                    var num_items = data.length;
                    for (var i = 0; i < num_items; i++) {
                        var item = new Item(data[i].x_pos, data[i].y_pos,
                                            ICON_SIZE_X, ICON_SIZE_Y,
                                            data[i].id, data[i].url,
                                            data[i].name);
                        item.draw();
                        items.push(item);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    alert("Failed to download items from server");
                }
            });

            function StopEvent(e) {
                e.stopPropagation();
                e.preventDefault();
            }

            var url_to_image_obj = {}

            function Item(x, y, w, h, id, url, name) {
                console.log("Item(): Creating new Item(x = %d, y = %d, " +
                            "w = %d, h = %d, id = %d, url = %s)",
                            x, y, w, h, id, url);
                this.x = x;
                this.y = y;
                this.w = w;
                this.h = h;
                this.id = id;
                this.url = url;
                this.name = name;
                if (!(url in url_to_image_obj)) {
                    var im = new Image();
                    url_to_image_obj[url] = im;
                    im.src = "${g.resource(dir: 'images')}/" + url;
                }
                this.sel = false;
            }

            var outstanding_draw_requests = [];

            function ImgOnLoadHandler() {
                var num_images = outstanding_draw_requests.length;
                for (var i = 0; i < num_images; i++) {
                    outstanding_draw_requests[i].draw();
                }
            }

            Item.prototype.draw = function() {
                var im = url_to_image_obj[this.url];
                if (im) {
                    ctx.drawImage(im, this.x, this.y, this.w, this.h);
                } else {
                    im.onload = ImgOnLoadHandler;
                    outstanding_draw_requests.push(this);
                }

                if (this.sel == true){
                    ctx.strokeStyle = '#CC0000';
                    ctx.lineWidth = 1;
                    ctx.strokeRect((this.x+1), (this.y+1), (this.w-2), (this.h-2));
                }

            };

            Item.prototype.undraw = function() {
                ctx.clearRect(this.x, this.y, this.w, this.h);
            };

            Item.prototype.move = function(x, y) {
                if (x != this.x || y != this.y) {
                    this.undraw();
                    this.x = Math.round(x);
                    this.y = Math.round(y);
                    this.draw();
                }
            };

            // Return the canvas coordinates of an event e.  *** only works
            // correctly if the canvas width and height are the same as the css
            // width and height. ***
            function getMousePos(canvas, e) {
                var rect = canvas.getBoundingClientRect();
                var x = e.clientX - rect.left;
                var y = e.clientY - rect.top;
                return {
                    x : x,
                    y : y
                };
            }

            document.onmousedown = function(e) {
                mousePressed = true;
            };

            document.onmouseup = function(e) {
                mousePressed = false;
                canvas.onmousemove = null;
            };

            canvas.ondblclick = function(e) {
                var i = getItemFromMousePos(e);
                if (i != -1) {
                    var item = items[i];
                    console.log("Downloading item (id = %d)", item.id);
                    window.location = "${g.createLink(controller: 'PinBoard', action: 'downloadFile')}"
                                + "?pinboard_id=${pinboard.id}&item_id=" + item.id;
                }
            };

            canvas.onmouseup = function(e) {
                if (selectedItem != null) {
                    $.ajax({
                        url: "${g.createLink(controller: 'PinBoard', action: 'updateItem')}",
                        type: 'POST',
                        data: { "pinboard_id" : "${pinboard.id}",
                                "item_id" : selectedItem.id,
                                "x_pos" : selectedItem.x,
                                "y_pos" : selectedItem.y },
                        success: function(data) {
                        },
                        error: function(jqXHR, textStatus, errorThrown) {
                        }
                    });
                }
            };

            function getItemFromMousePos(e) {
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
                        selected_x_offset = x - items[i].x;
                        selected_y_offset = y - items[i].y;
                        return i;
                    }
                }
                return -1;
            }

            function drawAllItems () {
                for (var i = 0; i < items.length; i++) {
                    if (items[i] != selectedItem) {
                        items[i].draw();
                    }
                }
                if (selectedItem != null) {
                    selectedItem.draw();
                }
            }

            function CanvasOnMouseMove(e) {
                canvas.onmousemove = function (e) {
                    var mousePos = getMousePos(canvas, e);
                    var x = mousePos.x;
                    var y = mousePos.y;
                    selectedItem.move(x - selected_x_offset, y - selected_y_offset);
                    drawAllItems();
                    console.log("canvas.onmousemove(): Moved cursor to (%d, %d)", x, y);
                };
            }

            // Both dragenter and dragover must be cancelled for drop to work
            // correctly???
            canvas.ondragenter = StopEvent;
            canvas.ondragover = StopEvent;



            canvas.onmousedown = function(e) {
                var i = getItemFromMousePos(e)
                if (i != -1) {
                    if (selectedItem != null) {
                        selectedItem.undraw();
                        selectedItem.sel = false;
                        selectedItem.draw();
                    }
                    selectedItem = items[i];
                    selectedItem.sel = true;
                    selectedItem.draw();
                    canvas.onmousemove = CanvasOnMouseMove;
                }else{
                    selectedItem.undraw();
                    selectedItem.sel = false;
                    selectedItem = null;
                    drawAllItems();
                }
            };

            document.onkeydown = function(e) {
                //console.log("Keypress keycode=%d", e.keyCode);
                if (selectedItem != null && e.keyCode == 46) {
                    console.log("Deleting item: id = %d", selectedItem.id);
                    selectedItem.undraw();
                    $.ajax({
                        url: "${g.createLink(controller: 'PinBoard', action: 'deleteItem')}",
                        method: "POST",
                        data: {pinboard_id : ${pinboard.id},
                               item_id: selectedItem.id},
                        success: function(data) {
                            alert("Deleted file id=" + selectedItem.id);
                            window.location.reload();
                        }
                    });
                }
            }

            //canvas.ondblclick = function(e) {
                //console.log("canvas.ondblclick
            //}

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

                    var file = files[0];

                    console.log("canvas.ondrop(): Starting upload of file %s",
                                file.name);

                    // The FormData object simulates submitting a form using the
                    // form-data/multipart enctype (as would be used for an
                    // <input> of type "file")
                    var data = new FormData();
                    data.append("file", file);
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
                        dataType: 'json',
                        success: function(data) {
                            console.log("Assigning new item id=%d", data.id);
                            var item = new Item(x, y, ICON_SIZE_X, ICON_SIZE_Y,
                                                data.id, data.url, file.name);
                            console.log("Finished uploading item (id=%d)",
                                        data.id);
                            items.push(item);
                            item.draw();
                        }
                    });

                    console.log("canvas.ondrop(): Added new item (there are now %d items)",
                                items.length);

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
        <p>Simply drag files onto your pinboard to upload them!</p>
      </div>
    </div>
    <div id="main">
      <canvas id="pinboard_canvas" width="${pinboard.width}" height="${pinboard.height}">
        Your browser does not support the HTML 5 canvas tag
      </canvas>
    </div>
  </body>
</html>
