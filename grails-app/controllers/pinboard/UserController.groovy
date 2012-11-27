package pinboard

import grails.validation.ValidationException

class UserController {

	def login() {
	}

	def create() {
	}

	def makeNew() {
		def username = params.username
		def password1 = params.password1
		def password2 = params.password2

		if (!username || !password1 || !password2) {
			flash.message = "Invalid username and/or password."
			return redirect(action: "create")
		}

		if (password1 != password2) {
			flash.message = "The passwords you provided didn't match."
			return redirect(action: "create")
		}
		User u;

		u = User.findByUsername(username)
		if (u) {
			flash.message = "There is already a user named \"${username}\". " +
							"Please choose a different username."
			return redirect(action: "create")
		}
		try {
			u = new User(username, password1)
			u.save(failOnError: true)
		} catch (ValidationException e) {
			flash.message = "Invalid username and/or password."
			return redirect(action: "create")
		}
		session.user = u.id
		flash.message = "Hello ${username}."
		return redirect(controller: "pinBoard", action: "show")
	}

	def authenticate() {
		def password_hash = params.password.encodeAsMD5()
		def username = params.username

		if (!password_hash || !username) {
			flash.message = "Incorrect username and/or password.  Please try again."
			return redirect(action: "login")
		}

		def user = User.findByUsernameAndPasswordHash(username, password_hash)
		if (user) {
			session.user = user.id
			flash.message = "Hello ${username}."
			return redirect(controller: "pinBoard", action: "show")
		} else {
			flash.message = "Incorrect username and/or password.  Please try again."
			return redirect(action: "login")
		}
	}

	def logout() {
		User user = User.get(session.user)
		flash.message = "Goodbye ${user.username}.  See you soon!"
		session.user = null
		return redirect(action: "login")
	}
}
