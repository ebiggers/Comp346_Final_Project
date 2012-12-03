package pinboard

class PinBoard {
	int width
	int height
	String name

	static hasMany = [ items: Item ]

	static belongsTo = [user: User]

	PinBoard() {
		width = 954;
		height = 768;
		name = "Untitled";
	}

    //Item getItemFromFilename(String filename) {
        //for (Item item in items)
            //if (item.name == filename)
                //return item
        //return null
    //}

    Item getItemFromId(int item_id) {
        for (Item item in items) {
            if (item.id == item_id) {
                return item
            }
        }
        return null
    }

	static constraints = {
		width(min: 1, nullable: false)
		height(min: 1, nullable: false)
		name(nullable: false, blank: false)
	}
}
