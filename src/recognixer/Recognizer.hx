package recognixer;

interface Recognizer {
	public function addTemplate(id:String, points:Iterable<Pt>):Template;
	public function removeTemplate(id:String):Void;
	public function getTemplates():Iterable<Template>;
	
	public function recognize(input:Iterable<Pt>):Array<Result>;
}
