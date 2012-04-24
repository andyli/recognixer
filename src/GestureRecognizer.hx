package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import ContinuousGestureRecognizer;

using Std;
using Lambda;

class GestureRecognizer extends Sprite {
	static function generateTwoProgressiveRandomTemplates():List<Template> {
		var templates = new Array<Template>();
		for (i in 1...9) {
			if (i < 3) {
				templates.push(generateRandomTemplate(null, "Random " + i, 2));
			}
			else {
				templates.push(generateRandomTemplate(templates[i - 3].pts, "Random " + i, 1));
			}
		}
		return templates.list();
	}
	
	static function generateRandomTemplate(base:List<Pt>, id:String, maxPoints:Int):Template {
		var points = new List<Pt>();
		if (base != null) {
			for (pt in base) {
				points.add(new Pt(pt.x, pt.y));
			}
		}
		for (i in 0...maxPoints) {
			points.add(new Pt(Math.random() * 800.0, Math.random() * 800.0));
		}
		return new Template(id, points);
	}
	
	var templates:List<Template>;
	var templateSps:Array<PointsSp>;
	var recognizer:ContinuousGestureRecognizer;
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
		templates = generateTwoProgressiveRandomTemplates();
		
		
		inputSp = new PointsSp(new List<Pt>(), 0x000000, 0xCCCCCC);
		addChild(inputSp);
		inputSp.redraw();
		
		templateSps = [];
		var i = 0;
		var offset = stage.stageWidth / templates.length;
		for (t in templates) {
			var tSp = new PointsSp(t.pts.map(function(p) return new Pt(p.x, p.y)), 0x000000, 0xFFFFFF, 0.1);
			tSp.templateId = t.id;
			tSp.x = i++ * offset;
			templateSps.push(tSp);
			addChild(tSp);
		}
		
		recognizer = new ContinuousGestureRecognizer(templates, 5);
		
		inputSp.addEventListener(MouseEvent.MOUSE_DOWN, onMousePressed);
		inputSp.addEventListener(MouseEvent.MOUSE_UP, onMouseReleased);
		inputSp.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoved);
	}
	
	function onMousePressed(evt:MouseEvent):Void {
		mousePressed = true;
		inputSp.pts.clear();
		inputSp.pts.add(new Pt(evt.localX, evt.localY));
	}
	
	function onMouseReleased(evt:MouseEvent):Void {
		mousePressed = false;
	}
	
	function onMouseMoved(evt:MouseEvent):Void {
		if (mousePressed) {
			inputSp.pts.add(new Pt(evt.localX, evt.localY));
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
	public var scalePoints:Float;
	public var templateId:String;
	
	public function new(pts:List<Pt>, color:Int = 0x000000, bgColor:Int = 0xFFFFFF, scalePoints:Float = 1):Void {
		super();
		
		this.templateId = "";
		this.pts = pts;
		this.color = color;
		this.bgColor = bgColor;
		this.scalePoints = scalePoints;
		
		redraw();
	}
	
	public function redraw():Void {
		graphics.clear();
		
		graphics.beginFill(bgColor);
		graphics.drawRect(0, 0, 800 * scalePoints, 800 * scalePoints);
		graphics.endFill();
		
		if (!pts.empty()) {
			graphics.lineStyle(1, color);
			var fpt = pts.first();
			graphics.drawCircle(fpt.x * scalePoints, fpt.y * scalePoints, 2);
			graphics.moveTo(fpt.x * scalePoints, fpt.y * scalePoints);
			for (pt in pts) {
				graphics.lineTo(pt.x * scalePoints, pt.y * scalePoints);
			}
			graphics.moveTo(0, 0);
		}
	}
}