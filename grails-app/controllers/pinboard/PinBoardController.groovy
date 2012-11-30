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
		render pinboard.items as JSON
	}

	def deleteItem() {
		User u = User.get(session.user)
		int item_id = new Integer(params.item_id).intValue()
		PinBoard pinboard = getCurrentPinBoard(u)

        String filePath = grailsApplication.config.pinboard.upload_dir
                          + "/" + u.username + "/" + pinboard.id + "/"
                          + item.dataPath;

		Item item = pinboard.getItemFromId(item_id)
		if (item != null) {
            new File(filePath).delete();
			pinboard.removeFromItems(item)
			pinboard.save(failOnError: true)
			render("Item ${item_id} on pinboard ${pinboard_id} was successfully deleted.");
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

	def uploadFile() {

		int x_pos = new Double(params.x_pos).intValue()  //casting to the right type here
		int y_pos = new Double(params.y_pos).intValue()
		User u = User.get(session.user)
		PinBoard pinboard = getCurrentPinBoard(u)

		def f = request.getFile("file")

		String dir = grailsApplication.config.pinboard.upload_dir
		String username = u.username
		if (f.getSize() > 10000000) {
			return render("You cannot upload a file greater than 10 MB!")
		}
		String filename = f.getOriginalFilename()

		String userFolderName = dir + "/" + username
		File userFolder = new File(userFolderName)
		if (!userFolder.exists()) {
			userFolder.mkdir()
		}

		String pinboardFolderName = userFolderName + "/" + pinboard.id
		File pinboardFolder = new File(pinboardFolderName)
		if (!pinboardFolder.exists()) {
			pinboardFolder.mkdir()
		}

		f.transferTo(new File(pinboardFolderName + "/" + filename))

		Item item = new Item(filename, "Generic File", x_pos, y_pos)

		pinboard.addToItems(item)
		pinboard.save(failOnError: true, flush: true)

		return render("${item.id}") //"File \"${filename}\" has been uploaded!")
	}

    def downloadFile() {
        User u = User.get(session.user)
        int item_id = new Integer(params.item_id).intValue()
        PinBoard pinboard = getCurrentPinBoard(u)
        Item item = pinboard.getItemFromId(item_id)

        String filePath = grailsApplication.config.pinboard.upload_dir
                          + "/" + u.username + "/" + pinboard.id + "/"
                          + item.dataPath;

        def file = new File(filePath)

        if (file.exists()) {
            response.setContentType("application/octet-stream")
            response.setHeader("Content-disposition", "filename=${file.name}")
            response.outputStream << file.bytes
            response.outputStream.flush()
        }
    }
}
