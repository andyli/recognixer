package recognixer;

class Pt {
	public var x:Float;
	public var y:Float;
	public function new(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
	
	inline static public function from(p:{x:Float, y:Float}):Pt {
		return new Pt(p.x, p.y);
	}
	
	inline static public function toArrayFloat(points:Iterable<Pt>):Array<Float> {
		var out:Array<Float> = [];
			
		for (pt in points) {
			out.push(pt.x);
			out.push(pt.y);
		}
		
		return out;
	}
	
	inline static public function toArray(points:Iterable<Pt>):Array<Pt> {
		var out:Array<Pt> = [];
			
		for (pt in points)
			out.push(new Pt(pt.x, pt.y));
		
		return out;
	}
}