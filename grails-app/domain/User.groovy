class User {
	String username
	static hasMany = [ pinboards: Pinboard ]
	String password_hash
	Date dateCreated
}
