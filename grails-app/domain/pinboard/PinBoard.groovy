package pinboard

class PinBoard {
	int width
	int height
	static hasMany = [ items: Item ]

	static belongsTo = User

	static constraints = {
		width(min: 1, nullable: false)
		height(min: 1, nullable: false)
	}
}
