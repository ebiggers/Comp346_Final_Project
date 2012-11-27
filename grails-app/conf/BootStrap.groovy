import pinboard.User
import pinboard.ItemType

class BootStrap {

    def init = { servletContext ->
            new User("default", "").save(failOnError: true)

			new ItemType("Generic File", "Binary-icon.png").save(failOnError: true)
    }
    def destroy = {
    }
}
