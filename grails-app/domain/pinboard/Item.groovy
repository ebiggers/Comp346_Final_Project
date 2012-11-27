package pinboard

class Item {
	String name
	String dataPath
	ItemType type
	int x_pos
	int y_pos

	static belongsTo = PinBoard

	Item(String name, String itemTypeName, int x_pos, int y_pos) {
		this.name = name
		this.dataPath = name
		this.type = ItemType.findByTypeName(itemTypeName)
		this.x_pos = x_pos
		this.y_pos = y_pos
	}

	static constraints = {
		x_pos(nullable: false, min: 0)
		y_pos(nullable: false, min: 0)
		type(nullable: false)
		name(nullable: false, blank: false)
		dataPath(nullable: false, blank: false)
	}
}
