class Item {
	int x_pos
	int y_pos
	ItemType type
	String name
	String dataPath

	static belongsTo = Pinboard

	static constraints = {
		x_pos(nullable: false)
		y_pos(nullable: false)
		type(nullable: false)
		name(nullable: false, blank: false)
		dataPath(nullable: false, blank: false)
	}
}
