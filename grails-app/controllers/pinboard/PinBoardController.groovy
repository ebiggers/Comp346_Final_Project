package pinboard

import grails.converters.JSON

class PinBoardController {

	def beforeInterceptor = [action: this.&auth]

	private auth() {
		if (!session.user) {
			redirect(controller: "user", action: "login")
			return false
		}
	}

	private PinBoard getDefaultPinBoard(User u) {
		for (PinBoard b in u.pinboards) {
			return b
		}
	}

	private PinBoard getCurrentPinBoard(User u) {
		PinBoard pinboard = PinBoard.get(params.pinboard_id)
		if (pinboard == null || pinboard.user.id != session.user)
			return null
		else
			return pinboard
	}

	private PinBoard getCurrentOrDefaultPinBoard(User u) {
		PinBoard pinboard
		pinboard = getCurrentPinBoard(u)
		if (pinboard == null)
			pinboard = getDefaultPinBoard(u)
		return pinboard
	}

    def show() {
		User u = User.get(session.user)
		PinBoard pinboard = getCurrentOrDefaultPinBoard(u)
		[pinboard: pinboard, user: u]
    }

	def listItems() {
	    User u = User.get(session.user)
		PinBoard pinboard = getCurrentPinBoard(u)

        render(builder: "json") {
            array {
                pinboard.items.each {
                    dummy(x_pos: it.x_pos,
                          y_pos: it.y_pos,
                          id:    it.id,
                          name:  it.name,
                          url:   it.type.iconURL)
                }
            }
        }
	}

	def deleteItem() {
        User u = User.get(session.user)
        int item_id = new Integer(params.item_id).intValue()
        PinBoard pinboard = getCurrentPinBoard(u)
        Item item = pinboard.getItemFromId(item_id)

        String filePath = grailsApplication.config.pinboard.upload_dir +
                "/" + u.username + "/" + pinboard.id +
                "/" + item.dataPath;

		if (item != null) {
            new File(filePath).delete();
			pinboard.removeFromItems(item)
			pinboard.save(failOnError: true)
			render("Item ${item_id} on pinboard ${pinboard.id} was successfully deleted.");
		}
	}

	def updateItem() {
		User u = User.get(session.user)
		int item_id = new Integer(params.item_id).intValue()
		int x_pos = new Double(params.x_pos).intValue()
		int y_pos = new Double(params.y_pos).intValue()
		PinBoard pinboard = getCurrentPinBoard(u)
		Item item = pinboard.getItemFromId(item_id)
		if (item != null) {
			item.x_pos = x_pos
			item.y_pos = y_pos
			item.save(failOnError: true)
			render("Item ${item_id} on pinboard ${pinboard.id} was successfully updated.");
		} else {
			render("No item found (params = {.pinboard_id = ${params.pinboard_id}" +
					", .item_id = ${params.item_id}, .x_pos = ${params.x_pos}, " +
					".y_pos = ${params.y_pos}})");
		}
	}

    private String fileNameToFileTypeName(String filename) {
        int idx = filename.lastIndexOf('.')
        if (idx == -1)
            return "Generic File"
        String extension = filename.substring(idx + 1)
        switch (extension) {
            case ~/(?i)zip|tar|gz|bzip2|7z|bz2|iso|o|cpio|a|lz|lzma|xz|ace|wim|apk|jar|cab|dmg|lzx|partimg|rar/:
                return "Archive"
            case ~/(?i)wav|mp3|ogg|midi?/:
                return "Audio"
            case ~/(?i)jpe?g|png|bmp|tiff|gif/:
                return "Image"
            case ~/(?i)pdf/:
                return "PDF"
            case ~/(?i)txt/:
                return "Text"
            case ~/(?i)mp4|mpe?g|avi|mkv|264|vid|webm/:
                return "Video"
            case ~/(?i)docx?|pptx?/:
                return "Word"
            default:
                return "Generic File"
        }
    }

	def uploadFile() {

		int x_pos = new Double(params.x_pos).intValue()  //casting to the right type here
		int y_pos = new Double(params.y_pos).intValue()
		User u = User.get(session.user)
		PinBoard pinboard = getCurrentPinBoard(u)

		def f = request.getFile("file")

		String dirname = grailsApplication.config.pinboard.upload_dir
		String username = u.username
		if (f.getSize() > 10000000) {
            return render(contentType: "text/json") {
                error = "You cannot upload a file greater than 10 MB!"
                errorType = "FileTooBig"
            }
		}
		String filename = f.getOriginalFilename()

        File dir = new File(dirname)
        if (!dir.exists()) {
            dir.mkdir()
        }

		String userFolderName = dirname + "/" + username
		File userFolder = new File(userFolderName)
		if (!userFolder.exists()) {
			userFolder.mkdir()
		}

		String pinboardFolderName = userFolderName + "/" + pinboard.id
		File pinboardFolder = new File(pinboardFolderName)
		if (!pinboardFolder.exists()) {
			pinboardFolder.mkdir()
		}

        File file = new File(pinboardFolderName + "/" + filename);

        Item existing_item = pinboard.getItemFromName(filename)
        if (existing_item != null) {
            return render(contentType: "text/json") {
                error = "You already have a file named \"" + filename + "\"!"
                errorType = "FileAlreadyExists"
            }
        }

        f.transferTo(file)
		Item item = new Item(filename, fileNameToFileTypeName(filename),
                             x_pos, y_pos)

		pinboard.addToItems(item)
		pinboard.save(failOnError: true, flush: true)

        render(contentType: "text/json") {
            id = item.id
            url = item.type.iconURL
        }
	}

    def downloadFile() {
        User u = User.get(session.user)
        int item_id = new Integer(params.item_id).intValue()
        PinBoard pinboard = getCurrentPinBoard(u)
        Item item = pinboard.getItemFromId(item_id)

        String filePath = grailsApplication.config.pinboard.upload_dir +
                          "/" + u.username + "/" + pinboard.id +
                          "/" + item.dataPath;

        def file = new File(filePath)

        if (file.exists()) {
            response.setContentType("application/octet-stream")
            response.setHeader("Content-disposition", "filename=${file.name}")
            response.outputStream << file.bytes
            response.outputStream.flush()
        }
    }
}
