/*
 * Continuous Recognition and Visualization of Pen Strokes and Touch-Screen Gestures
 * Version: 2.0
 *
 * If you use this code for your research then please remember to cite our paper:
 * 
 * Kristensson, P.O. and Denby, L.C. 2011. Continuous recognition and visualization
 * of pen strokes and touch-screen gestures. In Procceedings of the 8th Eurographics
 * Symposium on Sketch-Based Interfaces and Modeling (SBIM 2011). ACM Press: 95-102.
 * 
 * Copyright (C) 2011 by Per Ola Kristensson, University of St Andrews, UK.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package;

/**
 * A continuous gesture recognizer. Outputs a probability distribution over
 * a set of template gestures as a function of received sampling points.
 * 
 * History:
 * Version 1.0 (August 12, 2011)   - Initial public release
 * Version 2.0 (September 6, 2011) - Simplified the public interface, simplified
 *                                   internal implementation.
 * 
 * For details of its operation, see the paper referenced below.
 * 
 * Documentation is here: http://pokristensson.com/increc.html
 * 
 * Copyright (C) 2011 Per Ola Kristensson, University of St Andrews, UK.
 * 
 * If you use this code for your research then please remember to cite our paper:
 * 
 * Kristensson, P.O. and Denby, L.C. 2011. Continuous recognition and visualization
 * of pen strokes and touch-screen gestures. In Procceedings of the 8th Eurographics
 * Symposium on Sketch-Based Interfaces and Modeling (SBIM 2011). ACM Press: 95-102.
 * 
 * @author Per Ola Kristensson
 * @author Leif Denby
 *
 */
class ContinuousGestureRecognizer 
{	
	/**
	 * Creates an instance of a continuous gesture recognizer.
	 *
	 * @param templates the set of templates the recognizer will recognize
	 * @param samplePointDistance the distance between sampling points in the normalized space
	 * (1000 x 1000 units)
	 */
	public function new(templates:List<Template>, samplePointDistance:Int = 5):Void {
		patterns = new List<Pattern>();
		this.samplePointDistance = samplePointDistance;
		setTemplateSet(templates);
	}
	
	/**
	 * Sets the set of templates this recognizer will recognize.
	 * 
	 * @param templates the set of templates this recognizer will recognize
	 */
	public function setTemplateSet(templates:List<Template>):Void {
		patterns.clear();
		for (t in templates) {
			normalize(t.pts);
			patterns.add(new Pattern(t, generateEquiDistantProgressiveSubSequences(t.pts, 200)));
		}
		for (pattern in patterns) {
			var segments:List<List<Pt>> = new List<List<Pt>>();
			for (pts in pattern.segments) {
				var newPts:List<Pt> = deepCopyPts(pts);
				normalize(newPts);
				segments.add(resamplePoints(newPts, getResamplingPointCount(newPts, samplePointDistance)));
			}
			pattern.segments = segments;
		}
	}

	/**
	 * Outputs a list of templates and their associated probabilities for the given input.
	 * 
	 * @param input a list of input points
	 * @param beta a parameter, see the paper for details
	 * @param lambda a parameter, see the paper for details
	 * @param kappa a parameter, see the paper for details
	 * @param e_sigma a parameter, see the paper for details
	 * @return a list of templates and their associated probabilities
	 */
	public function recognize(input:List<Pt>, beta:Float = DEFAULT_BETA, lambda:Float = DEFAULT_LAMBDA, kappa:Float = DEFAULT_KAPPA, e_sigma:Float = DEFAULT_E_SIGMA):Array<Result> {
		if (input.length < 2) {
			throw "input must consist of at least two points";
		}
		var incResults:List<IncrementalResult> = getIncrementalResults(input, beta, lambda, kappa, e_sigma);
		var results:Array<Result> = getResults(incResults);
		results.sort(Result.compare);	
		return results;
	}
	
	/**
	 * Normalizes a point sequence so that it is scaled and centred within a defined box.
	 * 
	 * (This method was implemented and exposed in the public interface to ease the
	 * implementation of the demonstrator. This method is not used by the recognition
	 * algorithm.) 
	 * 
	 * @param pts an input point sequence
	 * @param x the horizontal component of the upper-left corner of the defined box
	 * @param y the vertical component of the upper-left corner of the defined box
	 * @param width the width of the defined box
	 * @param height the height of the defined box
	 * @return a newly created point sequence that is centred and fits within the defined box 
	 */
	public static function normalizeBox(pts:List<Pt>, x:Int, y:Int, width:Int, height:Int):List<Pt> {
		var outPts:List<Pt> = deepCopyPts(pts);
		scaleTo(outPts, new Rect(0, 0, width - x, height - y));
		var c:Centroid = getCentroid(outPts);
		translate(outPts, -c.x, -c.y);
		translate(outPts, width - x, height - y);
		return outPts;
	}
	
	/* End of public interface */
	
	private inline static var DEFAULT_E_SIGMA:Float = 200.0;
	private inline static var DEFAULT_BETA:Float = 400.0;
	private inline static var DEFAULT_LAMBDA:Float = 0.4;
	private inline static var DEFAULT_KAPPA:Float = 1.0;
	private inline static var MAX_RESAMPLING_PTS:Int = 1000;
	private static var normalizedSpace:Rect = new Rect(0, 0, 1000, 1000);
	private var samplePointDistance:Int;
	private var patterns:List<Pattern>;
	
	private function getResults(incrementalResults:List<IncrementalResult>):Array<Result> {
		var results:Array<Result> = new Array<Result>();
		for (ir in incrementalResults) {
			results.push(new Result(ir.pattern.template, ir.prob, ir.mostLikelySegment));
		}
		return results;
	}
	
	private function getIncrementalResults(input:List<Pt>, beta:Float, lambda:Float, kappa:Float, e_sigma:Float):List<IncrementalResult> {
		var results:List<IncrementalResult> = new List<IncrementalResult>();
		var unkPts:List<Pt> = deepCopyPts(input);
		normalize(unkPts);
		for (pattern in patterns) {
			var result:IncrementalResult = getIncrementalResult(unkPts, pattern, beta, lambda, e_sigma);
			var lastSegmentPts:List<Pt> = pattern.segments.last();
			var completeProb:Float = getLikelihoodOfMatch(resamplePoints(unkPts, lastSegmentPts.length), lastSegmentPts, e_sigma, e_sigma/beta, lambda);
			var x:Float = 1 - completeProb;
			result.prob *= (1 + kappa*Math.exp(-x*x));
			results.add(result);
		}
		marginalizeIncrementalResults(results);
		return results;
	}
	
	private static function marginalizeIncrementalResults(results:List<IncrementalResult>):Void {
		var totalMass:Float = 0.0;
		for (r in results) {
			totalMass+= r.prob; 
		}
		for (r in results) {
			r.prob/= totalMass;
		}
	}

	private static function getIncrementalResult(unkPts:List<Pt>, pattern:Pattern, beta:Float, lambda:Float, e_sigma:Float):IncrementalResult {
		var segments:List<List<Pt>> = pattern.segments;
		var maxProb:Float = 0.0;
		var maxSeg:List<Pt> = null;
		var i = 0;
		for (pts in segments) {
			var samplingPtCount:Int = pts.length;
			var unkResampledPts:List<Pt> = resamplePoints(unkPts, samplingPtCount);
			var prob:Float = getLikelihoodOfMatch(unkResampledPts, pts, e_sigma, e_sigma/beta, lambda);
			if (prob > maxProb) {
				maxProb = prob;
				maxSeg = pts;
			}
			
			++i;
		}
		return new IncrementalResult(pattern, maxProb, maxSeg);
	}
	
	public static function deepCopyPts(pts:Iterable<Pt>, len:Int = -1):List<Pt> {
		var newPts:List<Pt> = new List<Pt>();
		
		if (len == -1)
			for (pt in pts)
				newPts.add(new Pt(pt.x, pt.y));
		else
			for (pt in pts)
				if (len-- > 0) newPts.add(new Pt(pt.x, pt.y));
		
		return newPts;
	}
	
	private static function normalize(pts:List<Pt>):Void {
		scaleTo(pts, normalizedSpace);
		var c:Centroid = getCentroid(pts);
		translate(pts, -c.x, -c.y);
	}
	
	private static function scaleTo(pts:List<Pt>, targetBounds:Rect):Void {
		var bounds:Rect = getBoundingBox(pts);
		var a1:Float = targetBounds.width;
		var a2:Float = targetBounds.height;
		var b1:Float = bounds.width;
		var b2:Float = bounds.height;
		var scale:Float = Math.sqrt(a1 * a1 + a2 * a2) / Math.sqrt(b1 * b1 + b2 * b2);
		scaleOrigin(pts, scale, scale, bounds.x, bounds.y);
	}
	
	private static function scaleOrigin(pts:List<Pt>, sx:Float, sy:Float, originX:Float, originY:Float):Void {
		translate(pts, -originX, -originY);
		scale(pts, sx, sy);
		translate(pts, originX, originY);
	}
	
	private static function scale(pts:List<Pt>, sx:Float, sy:Float):Void {
		for (pt in pts) {
			pt.x *= sx;
			pt.y *= sy;
		}
	}
	
	private static function translate(pts:List<Pt>, dx:Float, dy:Float):Void {
		for (pt in pts) {
			pt.x += dx;
			pt.y += dy;
		}
	}
	
	private static function getBoundingBox(pts:List<Pt>):Rect {
		var minX = Math.POSITIVE_INFINITY;
		var minY = Math.POSITIVE_INFINITY;
		var maxX = Math.NEGATIVE_INFINITY;
		var maxY = Math.NEGATIVE_INFINITY;
		for (pt in pts) {
			var x = pt.x;
			var y = pt.y;
			if (x < minX) {
				minX = x;
			}
			if (x > maxX) {
				maxX = x;
			}
			if (y < minY) {
				minY = y;
			}
			if (y > maxY) {
				maxY = y;
			}
		}
		return new Rect(minX, minY, (maxX - minX), (maxY - minY));
	}
	
	private static function getCentroid(pts:List<Pt>):Centroid {
		var totalMass:Float = pts.length;
		var xIntegral:Float = 0.0;
		var yIntegral:Float = 0.0;
		for (pt in pts) {
			xIntegral+= pt.x;
			yIntegral+= pt.y;
		}
		return new Centroid(xIntegral / totalMass, yIntegral / totalMass);
	}
	
	private static function generateEquiDistantProgressiveSubSequences(pts:List<Pt>, ptSpacing:Int):List<List<Pt>> {
		var sequences:List<List<Pt>> = new List<List<Pt>>();
		var nSamplePoints:Int = getResamplingPointCount(pts, ptSpacing);
		var resampledPts:List<Pt> = resamplePoints(pts, nSamplePoints);
		for (i in 1...resampledPts.length) {
			var seq:List<Pt> = deepCopyPts(resampledPts, i+1);
			sequences.add(seq);
		}
		return sequences;
	}
	
	private static function getResamplingPointCount(pts:List<Pt>, samplePointDistance:Int):Int {
		var len:Float = getSpatialLength(pts);
		return Std.int((len / samplePointDistance) + 1);
	}
	
	private static function getSpatialLength(pts:List<Pt>):Float {
		var len:Float = 0.0;
		var i:Iterator<Pt> = pts.iterator();
		if (i.hasNext()) {
			var p0:Pt = i.next();
			while (i.hasNext()) {
				var p1:Pt = i.next();
				len+= distancePoints(p0, p1);
				p0 = p1;
			}
		}
		return len;
	}
	
	inline private static function distancePoints(p1:Pt, p2:Pt):Float {
		return distanceCoor(p1.x, p1.y, p2.x, p2.y);
	}

	private static function distanceCoor(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		if ((x2 -= x1) < 0) {
			x2 = -x2;
		}
		if ((y2 -= y1) < 0) {
			y2 = -y2;
		}
		return (x2 + y2 - (((x2 > y2) ? y2 : x2) * 0.5) );//(x2 + y2 - (((x2 > y2) ? y2 : x2) >> 1) );
	}
	
	private static function getLikelihoodOfMatch(pts1:List<Pt>, pts2:List<Pt>, eSigma:Float, aSigma:Float, lambda:Float):Float {
		if (eSigma == 0 || eSigma < 0) {
			throw "eSigma must be positive";
		}
		if (aSigma == 0 || eSigma < 0) {
			throw "aSigma must be positive";
		}
		if (lambda < 0 || lambda > 1) {
			throw "lambda must be in the range between zero and one";
		}
		var x_e:Float = getEuclidianDistancePointLists(pts1, pts2);
		var x_a:Float = getTurningAngleDistancePointLists(pts1, pts2);
		return Math.exp(- (x_e * x_e / (eSigma * eSigma) * lambda + x_a * x_a / (aSigma * aSigma) * (1 - lambda)));
	}

	private static function getEuclidianDistancePointLists(pts1:List<Pt>, pts2:List<Pt>):Float {
		if (pts1.length != pts2.length) {
			throw "lists must be of equal lengths, cf. " + pts1.length + " with " + pts2.length;
		}
		
		var n:Int = pts1.length;
		var td:Float = 0;
		var	i1 = pts1.iterator(),
			i2 = pts2.iterator();
		while (i1.hasNext() && i2.hasNext()) {
			td+= getEuclideanDistancePoints(i1.next(), i2.next());
		}
		return td / n;
	}
	
	private static function getTurningAngleDistancePointLists(pts1:List<Pt>, pts2:List<Pt>):Float {
		if (pts1.length != pts2.length) {
			throw "lists must be of equal lengths, cf. " + pts1.length + " with " + pts2.length;
		}
		var n:Int = pts1.length;
		var td:Float = 0;
		var	i1 = pts1.iterator(),
			i2 = pts2.iterator();
		var	pt1a = i1.hasNext() ? i1.next() : throw "pts1 length is 0",
			pt2a = i1.hasNext() ? i2.next() : throw "pts2 length is 0",
			pt1b, pt2b;
		while (i1.hasNext() && i2.hasNext()) {
			td += Math.abs(getTurningAngleDistancePoints(pt1a, pt1b = i1.next(), pt2a, pt2b = i2.next()));
			pt1a = pt1b;
			pt2a = pt2b;
		}
		if (Math.isNaN(td)) {
			return 0.0;
		}
		return td / (n - 1);
	}
	
	private static function getEuclideanDistancePoints(pt1:Pt, pt2:Pt):Float {
		return Math.sqrt(getSquaredEuclidenDistance(pt1, pt2));
	}
	
	private static function getSquaredEuclidenDistance(pt1:Pt, pt2:Pt):Float {
		return (pt1.x - pt2.x) * (pt1.x - pt2.x) + (pt1.y - pt2.y) * (pt1.y - pt2.y);
	}
	
	private static function getTurningAngleDistancePoints(ptA1:Pt, ptA2:Pt, ptB1:Pt, ptB2:Pt):Float {		
		var len_a:Float = getEuclideanDistancePoints(ptA1, ptA2);
		var len_b:Float = getEuclideanDistancePoints(ptB1, ptB2);
		if (len_a == 0 || len_b == 0) {
			return 0.0;
		}
		else {
			var cos:Float = (((ptA1.x - ptA2.x) * (ptB1.x - ptB2.x) + (ptA1.y - ptA2.y)*(ptB1.y - ptB2.y) ) / (len_a * len_b));
			if (Math.abs(cos) > 1.0) {
				return 0.0;
			}
			else {
				return Math.acos(cos);
			}
		}
	}
	
	private static function resamplePoints(points:List<Pt>, numTargetPoints:Int):List<Pt> {
		var r:List<Pt> = new List<Pt>();
		var inArray:Array<Float> = toArray(points);
		var outArray:Array<Float> = []; //TODO new int[numTargetPoints * 2];
		
		resample(inArray, outArray, points.length, numTargetPoints);
		var	i = 0,
			n = outArray.length;
		while (i < n) {
			r.add(new Pt(outArray[i], outArray[i + 1]));
			i += 2;
		}
		return r;
	}

	private static function toArray(points:List<Pt>):Array<Float> {
		var out:Array<Float> = [];
			
		for (pt in points) {
			out.push(pt.x);
			out.push(pt.y);
		}
		
		return out;
	}
	
	private static function resample(template:Array<Float>, buffer:Array<Float>, n:Int, numTargetPoints:Int):Void {
		var segment_buf:Array<Float> = []; //TODO new int[MAX_RESAMPLING_PTS];

		var l:Float, segmentLen:Float, horizRest:Float, verticRest:Float, dx:Float, dy:Float;
		var x1:Float, y1:Float, x2:Float, y2:Float;
		var i:Int, m:Int, a:Int, segmentPoints:Float, j:Int, maxOutputs:Int, end:Int;

		m = n * 2;
		l = getSpatialLengthN(template, n);
		segmentLen = l / (numTargetPoints - 1);
		getSegmentPoints(template, n, segmentLen, segment_buf);
		horizRest = 0.0;
		verticRest = 0.0;
		x1 = template[0];
		y1 = template[1];
		a = 0;
		maxOutputs = numTargetPoints * 2;
		i = 2;
		while (i < m) {
			x2 = template[i];
			y2 = template[i + 1];
			segmentPoints = segment_buf[Std.int((i / 2) - 1)];
			dx = -1.0;
			dy = -1.0;
			if (segmentPoints - 1 <= 0) {
				dx = 0.0;
				dy = 0.0;
			}
			else {
				dx = (x2 - x1) / segmentPoints;
				dy = (y2 - y1) / segmentPoints;
			}
			if (segmentPoints > 0) {
				j = 0;
				while (j < segmentPoints) {
					if (j == 0) {
						if (a < maxOutputs) {
							buffer[a] = x1 + horizRest;
							buffer[a + 1] = y1 + verticRest;
							horizRest = 0.0;
							verticRest = 0.0;
							a += 2;
						}
					}
					else {
						if (a < maxOutputs) {
							buffer[a] = x1 + j * dx;
							buffer[a + 1] = y1 + j * dy;
							a += 2;
						}
					}
					
					j++;
				}
			}
			x1 = x2;
			y1 = y2;
			
			i += 2;
		}
		end = (numTargetPoints * 2) - 2;
		if (a < end) {
			i = a;
			while (i < end) {
				buffer[i] = (buffer[i - 2] + template[m - 2]) / 2;
				buffer[i + 1] = (buffer[i - 1] + template[m - 1]) / 2;
				i += 2;
			}
		}
		buffer[maxOutputs - 2] = template[m - 2];
		buffer[maxOutputs - 1] = template[m - 1];
	}
	
	private static function getSegmentPoints(pts:Array<Float>, n:Int, length:Float, buffer:Array<Float>):Float {
		var i:Int, m:Int;
		var x1:Float, y1:Float, x2:Float, y2:Float, ps:Float;
		var rest:Float, currentLen:Float;

		m = n * 2;
		rest = 0.0;
		x1 = pts[0];
		y1 = pts[1];
		i = 2;
		while (i < m) {
			x2 = pts[i];
			y2 = pts[i + 1];
			currentLen = distanceCoor(x1, y1, x2, y2);
			currentLen += rest;
			rest = 0.0;
			ps = currentLen / length;
			if (ps == 0) {
				rest += currentLen;
			}
			else {
				rest += currentLen - (ps * length);
			}
			if (i == 2 && ps == 0) {
				ps = 1;
			}
			buffer[Std.int((i / 2) - 1)] = ps;
			x1 = x2;
			y1 = y2;
			
			i += 2;
		}
		return rest;
	}

	private static function getSpatialLengthN(pat:Array<Float>, n:Int):Float {
		var l:Float;
		var i:Int, m:Int;
		var x1:Float, y1:Float, x2:Float, y2:Float;

		l = 0;
		m = 2 * n;
		if (m > 2) {
			x1 = pat[0];
			y1 = pat[1];
			i = 2;
			while (i < m) {
				x2 = pat[i];
				y2 = pat[i + 1];
				l += distanceCoor(x1, y1, x2, y2);
				x1 = x2;
				y1 = y2;
				
				i += 2;
			}
			return l;
		}
		else {
			return 0;
		}
	}
	
}

/**
 * Defines a template gesture / stroke.
 * 
 * @author Per Ola Kristensson
 *
 */
class Template {
	
	/**
	 * The identifier for this template gesture / stroke.
	 */
	public var id(default, null):String;
	/**
	 * A sequence of points that defines this template
	 * gesture / stroke.
	 */
	public var pts(default, null):List<Pt>;
	
	/**
	 * Creates a template gesture / stroke.
	 * 
	 * @param id the identifier for this template gesture / stroke
	 * @param points the sequence of points that define this
	 * template gesture / stroke
	 */
	public function new(id:String, points:Iterable<Pt>):Void {
		this.id = id;
		this.pts = ContinuousGestureRecognizer.deepCopyPts(points);
	}

}

/**
 * Defines a point with optional waypoint information.
 * 
 * @author Per Ola Kristensson
 *
 */
class Pt {

	/**
	 * The horizontal component of this point.
	 */
	public var x:Float;
	/**
	 * The vertical component of this point.
	 */
	public var y:Float;
	
	/**
	 * Creates a point.
	 * 
	 * @param x the horizontal component of this point
	 * @param y the vertical component of this point
	 */
	public function new(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
}

/**
 * Holds a recognition result.
 * 
 * @author Per Ola Kristensson
 *
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
	/**
	 * The point sequence associated with this recognition result.
	 */
	public var pts(default, null):List<Pt>;

	public function new(template:Template, prob:Float, pts:List<Pt>):Void {
		this.template = template;
		this.prob = prob;
		this.pts = pts;
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

private class Pattern {
	public var template:Template;
	public var segments:List<List<Pt>>;
	public function new(template:Template, segments:List<List<Pt>>):Void {
		this.template = template;
		this.segments = segments;
	}
}

private class Rect {
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var width(default, null):Float;
	public var height(default, null):Float;
	public function new(x:Float, y:Float, width:Float, height:Float):Void {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
}

private class Centroid {
	public var x(default, null):Float;
	public var y(default, null):Float;
	public function new(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
}

private class IncrementalResult {
	public var pattern:Pattern;
	public var prob:Float;
	public var mostLikelySegment:List<Pt>;
	public function new(pattern:Pattern, prob:Float, mostLikelySegment:List<Pt>):Void {
		this.pattern = pattern;
		this.prob = prob;
		this.mostLikelySegment = mostLikelySegment;
	}
}