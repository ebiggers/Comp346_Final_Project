class User {
	String username
	String password_hash
	Date dateCreated
	static hasMany = [ pinboards: Pinboard ]

	static constraints = {
		username(blank: false, unique: true)
		password_hash(size: 16..16, nullable: true)
	}
}
