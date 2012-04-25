package recognixer;

interface Recognizer {
	/**
	 * Add a gesture template to let the Recognizer matches against.
	 */
	public function addTemplate(id:String, points:Iterable<Pt>):Template;
	
	/**
	 * Remove a gesture template.
	 */
	public function removeTemplate(id:String):Void;
	
	/**
	 * Get the current list of gesture templates
	 */
	public function getTemplates():Iterable<Template>;
	
	/**
	 * Classify the input as a gesture.
	 * It may return a single or multiple Results.
	 * When returnning multiple Results, they come from desc. order, ie. most probably gesture comes first.
	 */
	public function recognize(input:Iterable<Pt>):Array<Result>;
}
