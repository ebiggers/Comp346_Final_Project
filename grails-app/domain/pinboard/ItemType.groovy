package pinboard

class ItemType {
	String typeName
	String iconURL

	ItemType(String typeName, String iconURL) {
		this.typeName = typeName
		this.iconURL = iconURL
	}

	static constraints = {
		typeName(nullable: false, blank: false, unique: true)
		iconURL(nullable: false, blank: false)
	}
}
