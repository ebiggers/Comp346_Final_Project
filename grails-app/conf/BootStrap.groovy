import pinboard.User
import pinboard.ItemType

class BootStrap {

    def init = { servletContext ->
            new User("default", "").save(failOnError: true)

			//new ItemType("Generic File", "Binary-icon.png").save(failOnError: true)
            new ItemType("Generic File", "default.png").save(failOnError: true)
			new ItemType("Audio", "audio.png").save(failOnError: true)
			new ItemType("Image", "image.png").save(failOnError: true)
			new ItemType("PDF", "pdf.png").save(failOnError: true)
			new ItemType("Text", "text.png").save(failOnError: true)
			new ItemType("Video", "video.png").save(failOnError: true)
			new ItemType("Word", "word.png").save(failOnError: true)
    }
    def destroy = {
    }
}
