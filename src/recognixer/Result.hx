package recognixer;

/**
 * Holds a recognition result.
 */
class Result {
	
	/**
	 * The template associated with this recognition result.
	 */
	public var template(default, null):Template;
	/**
	 * The probability associated with this recognition result.
	 */
	public var prob(default, null):Float;

	public function new(template:Template, prob:Float):Void {
		this.template = template;
		this.prob = prob;
	}
	
	static public function compare(r0:Result, r1:Result):Int {
		return if (r0.prob == r1.prob) {
			0;
		} else if (r0.prob < r1.prob) {
			1;
		} else {
			-1;
		}
	}
}