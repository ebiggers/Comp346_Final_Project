class ItemType {
	String typeName
	String defaultIcon

	static constraints = {
		typeName(nullable: false, blank: false, unique: true)
		defaultIcon(nullable: false, blank: false)
	}
}
