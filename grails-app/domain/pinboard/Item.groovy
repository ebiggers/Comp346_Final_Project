package pinboard

class Item {
	int x_pos
	int y_pos
	ItemType type
	String name
	String dataPath

	static belongsTo = PinBoard

	static constraints = {
		x_pos(nullable: false, min: 0)
		y_pos(nullable: false, min: 0)
		type(nullable: false)
		name(nullable: false, blank: false)
		dataPath(nullable: false, blank: false)
	}
}
