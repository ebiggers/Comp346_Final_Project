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

    def show() {
		User u = User.get(session.user)
		PinBoard pinboard = getDefaultPinBoard(u)
		//try {
			//pinboard = PinBoard.get(params.id)
			//if (pinboard.user.id != session.user.id) {
				//pinboard = getDefaultPinBoard()
			//}
		//} catch (Exception e) {
			//e.printStackTrace()
			//pinboard = getDefaultPinBoard(session.user)
		//}
		[pinboard: pinboard, user: u]
    }

	def listItems() {
		render items as JSON
	}

	def uploadFile() {

		int x_pos = params.x_pos as Long
		int y_pos = params.x_pos as Long
		int pinboard_id = params.pinboard_id as Long

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
		if (!pinboardFolder()) {
			pinboardFolder.mkdir()
		}

		f.transferTo(new File(pinboardFolderName + "/" + filename))

		Item item = new Item(filename, "Generic File", x_pos, y_pos)

		pinboard.addToItems(item)

		pinboard.save(failOnError: true)

		return render("File \"${filename}\" has been uploaded!")
	}
}
