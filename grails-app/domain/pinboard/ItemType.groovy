package pinboard

class ItemType {
	String typeName
	String defaultIconPath

	static constraints = {
		typeName(nullable: false, blank: false, unique: true)
		defaultIconPath(nullable: false, blank: false)
	}
}
