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

    Item getItemFromFilename(String filename) {
		items.each {
			if (it.name == filename) {
				return it;
			}
		}
		return null;
    }

    Item getItemFromId(int item_id) {
		items.each {
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
