import pinboard.User

class BootStrap {

    def init = { servletContext ->
            new User("default", "").save(failOnError: true)
    }
    def destroy = {
    }
}
