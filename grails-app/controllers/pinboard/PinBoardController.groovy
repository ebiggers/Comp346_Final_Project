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
		PinBoard pinboard
		try {
			pinboard = PinBoard.get(params.id)
			if (pinboard.user.id != session.user) {
				pinboard = getDefaultPinBoard()
			}
		} catch (Exception e) {
			pinboard = getDefaultPinBoard(u)
		}
		return pinboard
	}

    def show() {
		User u = User.get(session.user)
		PinBoard pinboard = getCurrentPinBoard(u)
		[pinboard: pinboard, user: u]
    }

	def listItems() {
		User u = User.get(session.user)
		PinBoard pinboard = getCurrentPinBoard(u)
		render pinboard.items as JSON
	}

	def uploadFile() {

		int x_pos = new Double(params.x_pos).intValue()  //casting to the right type here
		int y_pos = new Double(params.y_pos).intValue()
		int pinboard_id = new Integer(params.pinboard_id).intValue()

		User u = User.get(session.user)

		PinBoard pinboard = PinBoard.get(pinboard_id)

		def f = request.getFile("file")

		String dir = grailsApplication.config.pinboard.upload_dir
		String username = u.username
		if (f.getSize() > 10000000) {
			return render("You cannot upload a file greater than 5MB")
		}
		String filename = f.getOriginalFilename()

		String userFolderName = dir + "/" + username
		File userFolder = new File(userFolderName)
		if (!userFolder.exists()) {
			userFolder.mkdir()
		}

		String pinboardFolderName = userFolderName + "/" + pinboard_id
		File pinboardFolder = new File(pinboardFolderName)
		if (!pinboardFolder.exists()) {
			pinboardFolder.mkdir()
		}

		f.transferTo(new File(pinboardFolderName + "/" + filename))

		Item item = new Item(filename, "Generic File", x_pos, y_pos)

		pinboard.addToItems(item)

		pinboard.save(failOnError: true)

		return render("File \"${filename}\" has been uploaded!")
	}
}
