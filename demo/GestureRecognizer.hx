package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;

import recognixer.Recognizer;
import recognixer.ContinuousGestureRecognizer;
import recognixer.DollarRecognizer;
import recognixer.Template;
import recognixer.Pt;

using Std;
using Lambda;

class GestureRecognizer extends Sprite {
	static function generateTwoProgressiveRandomTemplates():Array<Template> {
		var templates = new Array<Template>();
		for (i in 1...9) {
			if (i < 3) {
				templates.push(generateRandomTemplate(null, "Random " + i, 2));
			}
			else {
				templates.push(generateRandomTemplate(cast templates[i - 3].points, "Random " + i, 1));
			}
		}
		return templates;
	}
	
	static function generateRandomTemplate(base:List<Pt>, id:String, maxPoints:Int):Template {
		var points = new List<Pt>();
		if (base != null) {
			for (pt in base) {
				points.add(new Pt(pt.x, pt.y));
			}
		}
		
		for (i in 0...maxPoints) {
			points.add(new Pt(Math.random() * 1000.0, Math.random() * 1000.0));
		}
		
		return {
			id: id,
			points:points
		}
	}
	
	var templates:Iterable<Template>;
	var templateSps:Array<PointsSp>;
	var recognizer:Recognizer;
	var mousePressed:Bool;
	var inputSp:PointsSp;
	
	function new():Void {
		super();
		
		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	function init(evt:Event = null):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		mousePressed = false;
		
		templates = DollarRecognizer.predefinedTemplate.slice(0,8);
		
		inputSp = new PointsSp(new List<Pt>(), 0x000000, 0xCCCCCC, 800);
		addChild(inputSp);
		inputSp.redraw();
		
		recognizer = new DollarRecognizer(false);// new ContinuousGestureRecognizer(5);
		
		templateSps = [];
		var i = 0;
		var offset = stage.stageWidth / templates.count();
		for (t in templates) {
			recognizer.addTemplate(t.id, t.points);
			var tSp = new PointsSp(t.points.map(function(p) return new Pt(p.x, p.y)), 0x000000, 0xFFFFFF, offset);
			tSp.templateId = t.id;
			tSp.x = i++ * offset;
			templateSps.push(tSp);
			addChild(tSp);
		}
		
		inputSp.addEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
		inputSp.addEventListener(MouseEvent.MOUSE_UP, onMouseReleased);
		inputSp.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoved);
	}
	
	function onMousePressed(evt:MouseEvent):Void {
		mousePressed = true;
		inputSp.pts.clear();
		inputSp.pts.add(new Pt(evt.localX / (inputSp.size / 1000), evt.localY / (inputSp.size / 1000)));
	}
	
	function onMouseReleased(evt:MouseEvent):Void {
		mousePressed = false;
	}
	
	function onMouseMoved(evt:MouseEvent):Void {
		if (mousePressed) {
			inputSp.pts.add(new Pt(evt.localX / (inputSp.size / 1000), evt.localY / (inputSp.size / 1000)));
			inputSp.redraw();
			
			var results = recognizer.recognize(inputSp.pts);
			for (tps in templateSps) {
				if (tps.templateId == results[0].template.id) {
					tps.color = 0xFF0000;
					tps.redraw();
				} else if (tps.color != 0x000000) {
					tps.color = 0x000000;
					tps.redraw();
				}
				tps.redraw();
			}
			
		}
	}
	
	static public function main():Void {
		Lib.current.addChild(new GestureRecognizer());
	}
}

class PointsSp extends Sprite {
	public var pts:List<Pt>;
	public var color:Int;
	public var bgColor:Int;
	public var size:Float;
	public var templateId:String;
	
	public function new(pts:List<Pt>, color:Int = 0x000000, bgColor:Int = 0xFFFFFF, size:Float = 1000):Void {
		super();
		
		this.templateId = "";
		this.pts = pts;
		this.color = color;
		this.bgColor = bgColor;
		this.size = size;
		
		redraw();
	}
	
	public function redraw():Void {
		graphics.clear();
		
		graphics.beginFill(bgColor);
		graphics.drawRect(0, 0, size, size);
		graphics.endFill();
		
		if (!pts.empty()) {
			graphics.lineStyle(1, color);
			var fpt = pts.first();
			graphics.drawCircle(fpt.x * 0.001 * size, fpt.y * 0.001 * size, 2);
			graphics.moveTo(fpt.x * 0.001 * size, fpt.y * 0.001 * size);
			for (pt in pts) {
				graphics.lineTo(pt.x * 0.001 * size, pt.y * 0.001 * size);
			}
			graphics.moveTo(0, 0);
		}
	}
}