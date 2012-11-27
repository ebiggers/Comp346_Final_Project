package pinboard

class User {
	String username
	byte[] passwordHash
	Date dateCreated
	static hasMany = [ pinboards: PinBoard ]

    User(String username, String password) {
        this.username = username
        this.passwordHash = password.encodeAsMD5()
    }

	static constraints = {
		username(blank: false, unique: true, size: 1..20, matches :"[a-zA-Z1-9_]+")
		passwordHash(nullable: false, size: 32..32)
	}
	static mapping = {
		autoTimestamp true
	}
}
