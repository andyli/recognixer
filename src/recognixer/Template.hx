package recognixer;

typedef Template = {
	/**
	 * The identifier for this template gesture / stroke.
	 */
	public var id(default, null):String;
	
	/**
	 * A sequence of points that defines this template
	 * gesture / stroke.
	 */
	public var points(default, null):Iterable<Pt>;
}
