class Pinboard {
	int width
	int height
	static belongsTo = User
	static hasMany = [ items: Item ]
}
