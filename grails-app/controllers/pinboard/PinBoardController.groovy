package pinboard

class PinBoardController {

    def show() {
    }

	def uploadFile() {
		def f = request.getFile("file")
		String dir = grailsApplication.config.pinboard.upload_dir
		String username = session.user.username
		if (f.getSize() > 10000000) {
			return render("You cannot upload a file greater than 5MB")
		}
		String filename = f.getOriginalFilename()
		File userFolder = new File(dir + "/" + username);
		if (!userFolder.exists()) {
			userFolder.mkdir();
		}
		f.transferTo(new File(dir + "/" + username + "/" + filename))
		return render("File \"${filename}\" has been uploaded!")
	}

	private auth() {
		if (!session.user) {
			redirect(controller: "user", action: "login")
		}
	}

	def beforeInterceptor = [action: this.&auth]
}
