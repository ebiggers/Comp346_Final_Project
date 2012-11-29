package pinboard

class PinBoard {
	int width
	int height
	String name

	static hasMany = [ items: Item ]

	static belongsTo = [user: User]

	PinBoard() {
		width = 960;
		height = 768;
		name = "Untitled";
	}

    Item getItem(int item_id) {
		pinboard.items.each {
			if (it.id == item_id) {
				return it;
			}
		}
		return null;
    }

	static constraints = {
		width(min: 1, nullable: false)
		height(min: 1, nullable: false)
		name(nullable: false, blank: false)
	}
}
