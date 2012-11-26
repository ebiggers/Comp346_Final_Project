package pinboard

class User {
	String username
	byte[] password_hash
	Date dateCreated
	static hasMany = [ pinboards: PinBoard ]

	static constraints = {
		username(blank: false, unique: true, size: 1..20, matches :"[a-zA-Z1-9_]+")
		password_hash(size: 16..16, nullable: true)
	}
	static mapping = {
		autoTimestamp true
	}
}
