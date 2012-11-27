package pinboard

class ItemType {
	String typeName
	String defaultIconPath

	ItemType(String typeName, String defaultIconPath) {
		this.typeName = typeName
		this.defaultIconPath = defaultIconPath
	}

	static constraints = {
		typeName(nullable: false, blank: false, unique: true)
		defaultIconPath(nullable: false, blank: false)
	}
}
