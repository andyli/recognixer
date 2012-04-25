package recognixer;

/**
 * Ported to Haxe by Andy Li
 * Based on...
 *
 * The $1 Unistroke Recognizer (C# version)
 *
 *		Jacob O. Wobbrock, Ph.D.
 * 		The Information School
 *		University of Washington
 *		Mary Gates Hall, Box 352840
 *		Seattle, WA 98195-2840
 *		wobbrock@uw.edu
 *
 *		Andrew D. Wilson, Ph.D.
 *		Microsoft Research
 *		One Microsoft Way
 *		Redmond, WA 98052
 *		awilson@microsoft.com
 *
 *		Yang Li, Ph.D.
 *		Department of Computer Science and Engineering
 * 		University of Washington
 *		The Allen Center, Box 352350
 *		Seattle, WA 98195-2840
 * 		yangli@cs.washington.edu
 *
 * The Protractor enhancement was published by Yang Li and programmed here by 
 * Jacob O. Wobbrock.
 *
 *	Li, Y. (2010). Protractor: A fast and accurate gesture 
 *	  recognizer. Proceedings of the ACM Conference on Human 
 *	  Factors in Computing Systems (CHI '10). Atlanta, Georgia
 *	  (April 10-15, 2010). New York: ACM Press, pp. 2169-2172.
 * 
 * This software is distributed under the "New BSD License" agreement:
 * 
 * Copyright (c) 2007-2011, Jacob O. Wobbrock, Andrew D. Wilson and Yang Li.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the names of the University of Washington nor Microsoft,
 *      nor the names of its contributors may be used to endorse or promote 
 *      products derived from this software without specific prior written
 *      permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Jacob O. Wobbrock OR Andrew D. Wilson
 * OR Yang Li BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
class DollarRecognizer implements Recognizer {
	inline static public var Phi = 0.5 * (-1.0 + Math.sqrt(5.0)); // Golden Ratio
	
	static public var predefinedTemplate = [
		{ id:"triangle", points:[new Pt(548,356), new Pt(540,364), new Pt(532,376), new Pt(528,384), new Pt(520,396), new Pt(512,404), new Pt(504,420), new Pt(492,440), new Pt(480,464), new Pt(464,484), new Pt(448,508), new Pt(428,532), new Pt(408,552), new Pt(400,564), new Pt(380,580), new Pt(360,596), new Pt(344,612), new Pt(328,624), new Pt(320,636), new Pt(300,652), new Pt(292,652), new Pt(280,664), new Pt(268,676), new Pt(256,684), new Pt(244,692), new Pt(240,700), new Pt(248,704), new Pt(260,700), new Pt(268,704), new Pt(296,704), new Pt(308,708), new Pt(340,716), new Pt(364,720), new Pt(396,724), new Pt(432,728), new Pt(464,732), new Pt(500,732), new Pt(536,736), new Pt(580,732), new Pt(612,728), new Pt(640,732), new Pt(680,736), new Pt(708,740), new Pt(716,744), new Pt(744,748), new Pt(772,752), new Pt(792,756), new Pt(800,748), new Pt(808,756), new Pt(816,752), new Pt(824,736), new Pt(820,720), new Pt(808,688), new Pt(788,664), new Pt(768,628), new Pt(744,592), new Pt(716,556), new Pt(696,532), new Pt(680,512), new Pt(656,484), new Pt(644,472), new Pt(616,440), new Pt(592,420), new Pt(572,400), new Pt(552,392), new Pt(544,392)]},
		{ id:"x", points:[new Pt(348,368), new Pt(356,380), new Pt(364,392), new Pt(372,404), new Pt(384,420), new Pt(392,428), new Pt(400,440), new Pt(408,448), new Pt(424,468), new Pt(432,476), new Pt(440,484), new Pt(460,508), new Pt(476,532), new Pt(492,556), new Pt(508,572), new Pt(516,584), new Pt(532,600), new Pt(548,624), new Pt(560,636), new Pt(572,648), new Pt(584,660), new Pt(604,680), new Pt(612,688), new Pt(620,692), new Pt(628,700), new Pt(632,692), new Pt(628,672), new Pt(620,644), new Pt(616,632), new Pt(608,600), new Pt(600,556), new Pt(592,516), new Pt(588,480), new Pt(588,432), new Pt(588,392), new Pt(588,364), new Pt(588,344), new Pt(576,340), new Pt(568,348), new Pt(560,356), new Pt(540,380), new Pt(524,408), new Pt(496,452), new Pt(464,508), new Pt(432,564), new Pt(400,624), new Pt(376,668), new Pt(364,688), new Pt(356,700), new Pt(348,704), new Pt(348,696)]},
		{ id:"rectangle", points:[new Pt(312,396), new Pt(312,412), new Pt(312,428), new Pt(312,440), new Pt(316,448), new Pt(316,456), new Pt(316,468), new Pt(316,476), new Pt(316,492), new Pt(316,512), new Pt(316,532), new Pt(320,556), new Pt(320,572), new Pt(320,592), new Pt(320,608), new Pt(324,632), new Pt(324,640), new Pt(324,664), new Pt(328,688), new Pt(328,696), new Pt(328,708), new Pt(332,716), new Pt(332,724), new Pt(340,720), new Pt(352,728), new Pt(360,732), new Pt(368,728), new Pt(376,732), new Pt(396,728), new Pt(408,732), new Pt(424,732), new Pt(436,736), new Pt(468,740), new Pt(492,744), new Pt(504,744), new Pt(540,748), new Pt(568,752), new Pt(580,752), new Pt(608,752), new Pt(616,756), new Pt(660,752), new Pt(696,748), new Pt(716,744), new Pt(744,740), new Pt(764,740), new Pt(780,732), new Pt(788,732), new Pt(800,732), new Pt(804,740), new Pt(804,732), new Pt(796,724), new Pt(792,704), new Pt(792,680), new Pt(784,628), new Pt(780,580), new Pt(780,524), new Pt(780,492), new Pt(780,452), new Pt(776,420), new Pt(768,380), new Pt(768,372), new Pt(768,352), new Pt(764,340), new Pt(764,332), new Pt(764,320), new Pt(760,312), new Pt(752,316), new Pt(744,316), new Pt(724,328), new Pt(692,324), new Pt(648,324), new Pt(604,328), new Pt(596,328), new Pt(552,328), new Pt(544,328), new Pt(488,324), new Pt(480,324), new Pt(436,320), new Pt(428,320), new Pt(360,328), new Pt(324,332), new Pt(304,332)]},
		{ id:"circle", points:[new Pt(508,364), new Pt(496,360), new Pt(480,356), new Pt(472,356), new Pt(464,356), new Pt(444,360), new Pt(436,364), new Pt(416,376), new Pt(400,388), new Pt(384,408), new Pt(372,428), new Pt(360,452), new Pt(348,476), new Pt(340,500), new Pt(332,524), new Pt(328,560), new Pt(328,580), new Pt(332,600), new Pt(336,620), new Pt(352,652), new Pt(364,664), new Pt(384,676), new Pt(412,688), new Pt(432,696), new Pt(444,696), new Pt(480,696), new Pt(532,692), new Pt(568,688), new Pt(608,672), new Pt(640,656), new Pt(668,640), new Pt(692,616), new Pt(712,592), new Pt(716,584), new Pt(728,552), new Pt(728,508), new Pt(712,468), new Pt(680,400), new Pt(652,352), new Pt(608,320), new Pt(572,316), new Pt(560,324), new Pt(516,344), new Pt(504,356)]},
		{ id:"check", points:[new Pt(364,540), new Pt(372,540), new Pt(380,540), new Pt(388,540), new Pt(400,552), new Pt(408,556), new Pt(416,560), new Pt(424,572), new Pt(432,580), new Pt(440,592), new Pt(448,604), new Pt(456,616), new Pt(460,628), new Pt(468,640), new Pt(472,648), new Pt(480,656), new Pt(484,668), new Pt(488,676), new Pt(492,688), new Pt(496,696), new Pt(504,704), new Pt(508,716), new Pt(516,724), new Pt(520,732), new Pt(516,724), new Pt(516,712), new Pt(516,704), new Pt(516,696), new Pt(516,684), new Pt(516,672), new Pt(516,648), new Pt(516,632), new Pt(520,592), new Pt(528,556), new Pt(536,528), new Pt(548,492), new Pt(572,456), new Pt(588,428), new Pt(604,404), new Pt(620,376), new Pt(644,348), new Pt(660,324), new Pt(684,288), new Pt(696,272), new Pt(704,256), new Pt(708,248), new Pt(708,256), new Pt(700,264), new Pt(692,272)]},
		{ id:"caret", points:[new Pt(316,780), new Pt(316,768), new Pt(316,756), new Pt(320,748), new Pt(320,736), new Pt(324,728), new Pt(328,720), new Pt(336,696), new Pt(344,680), new Pt(344,672), new Pt(348,664), new Pt(352,652), new Pt(360,628), new Pt(364,608), new Pt(368,600), new Pt(372,576), new Pt(376,568), new Pt(384,556), new Pt(388,544), new Pt(400,516), new Pt(408,492), new Pt(420,460), new Pt(428,440), new Pt(436,432), new Pt(448,404), new Pt(460,376), new Pt(468,356), new Pt(476,344), new Pt(476,336), new Pt(480,328), new Pt(484,316), new Pt(488,308), new Pt(496,300), new Pt(504,296), new Pt(516,300), new Pt(524,308), new Pt(528,320), new Pt(544,356), new Pt(564,416), new Pt(580,464), new Pt(604,528), new Pt(624,572), new Pt(628,584), new Pt(644,636), new Pt(648,644), new Pt(668,692), new Pt(676,716), new Pt(680,724), new Pt(692,748), new Pt(704,768), new Pt(708,776), new Pt(716,800), new Pt(724,820), new Pt(728,828)]},
		{ id:"zig-zag", points:[new Pt(228,664), new Pt(332,544), new Pt(424,660), new Pt(500,544), new Pt(596,664), new Pt(672,544)]},
		{ id:"arrow", points:[new Pt(272,688), new Pt(280,680), new Pt(292,672), new Pt(300,668), new Pt(308,660), new Pt(320,652), new Pt(328,648), new Pt(336,640), new Pt(348,636), new Pt(356,632), new Pt(368,624), new Pt(380,616), new Pt(404,604), new Pt(424,592), new Pt(448,576), new Pt(472,564), new Pt(496,548), new Pt(508,544), new Pt(528,532), new Pt(552,524), new Pt(564,520), new Pt(584,512), new Pt(616,492), new Pt(636,484), new Pt(644,480), new Pt(664,468), new Pt(672,468), new Pt(684,464), new Pt(696,456), new Pt(708,448), new Pt(720,440), new Pt(728,432), new Pt(732,424), new Pt(724,416), new Pt(712,412), new Pt(684,412), new Pt(656,412), new Pt(640,412), new Pt(600,416), new Pt(588,420), new Pt(564,428), new Pt(548,432), new Pt(540,432), new Pt(548,432), new Pt(560,428), new Pt(572,424), new Pt(604,416), new Pt(640,408), new Pt(680,396), new Pt(716,388), new Pt(740,380), new Pt(768,376), new Pt(784,376), new Pt(792,376), new Pt(800,376), new Pt(804,388), new Pt(796,396), new Pt(776,428), new Pt(764,440), new Pt(744,468), new Pt(720,504), new Pt(708,516), new Pt(684,548), new Pt(676,556), new Pt(660,576), new Pt(656,584)]},
		{ id:"left square bracket", points:[new Pt(560,296), new Pt(552,292), new Pt(540,288), new Pt(532,292), new Pt(520,292), new Pt(512,296), new Pt(500,300), new Pt(488,296), new Pt(480,296), new Pt(472,296), new Pt(464,300), new Pt(452,300), new Pt(444,300), new Pt(432,296), new Pt(424,300), new Pt(416,300), new Pt(408,296), new Pt(400,292), new Pt(392,292), new Pt(380,296), new Pt(372,292), new Pt(360,296), new Pt(352,296), new Pt(340,300), new Pt(332,304), new Pt(324,308), new Pt(324,316), new Pt(328,324), new Pt(328,336), new Pt(332,352), new Pt(336,364), new Pt(336,376), new Pt(340,392), new Pt(340,404), new Pt(344,424), new Pt(344,440), new Pt(344,456), new Pt(344,472), new Pt(348,484), new Pt(348,500), new Pt(348,516), new Pt(348,528), new Pt(348,544), new Pt(352,552), new Pt(352,580), new Pt(352,592), new Pt(352,604), new Pt(352,628), new Pt(356,644), new Pt(356,652), new Pt(356,668), new Pt(356,688), new Pt(352,700), new Pt(352,716), new Pt(352,724), new Pt(352,732), new Pt(352,740), new Pt(356,748), new Pt(356,760), new Pt(356,768), new Pt(364,764), new Pt(376,764), new Pt(384,760), new Pt(392,756), new Pt(420,760), new Pt(436,760), new Pt(452,756), new Pt(464,760), new Pt(484,756), new Pt(520,760), new Pt(544,748), new Pt(556,748), new Pt(576,752), new Pt(604,748), new Pt(628,744), new Pt(636,748)]},
		{ id:"right square bracket", points:[new Pt(448,352), new Pt(448,344), new Pt(460,344), new Pt(472,348), new Pt(480,344), new Pt(492,344), new Pt(500,344), new Pt(512,344), new Pt(524,344), new Pt(536,340), new Pt(548,340), new Pt(560,336), new Pt(572,332), new Pt(580,328), new Pt(588,328), new Pt(596,328), new Pt(608,328), new Pt(612,336), new Pt(616,348), new Pt(620,364), new Pt(624,376), new Pt(628,408), new Pt(632,444), new Pt(640,480), new Pt(648,528), new Pt(656,568), new Pt(664,600), new Pt(668,636), new Pt(672,656), new Pt(672,664), new Pt(676,684), new Pt(676,692), new Pt(676,712), new Pt(676,724), new Pt(664,732), new Pt(656,736), new Pt(644,740), new Pt(620,744), new Pt(588,740), new Pt(560,732), new Pt(524,732), new Pt(496,732), new Pt(468,740), new Pt(456,752), new Pt(448,752)]},
		{ id:"v", points:[new Pt(356,456), new Pt(360,448), new Pt(368,448), new Pt(376,456), new Pt(380,464), new Pt(384,476), new Pt(388,484), new Pt(396,500), new Pt(404,512), new Pt(412,528), new Pt(424,556), new Pt(432,576), new Pt(444,596), new Pt(456,616), new Pt(468,636), new Pt(476,656), new Pt(488,672), new Pt(496,688), new Pt(504,700), new Pt(512,712), new Pt(520,716), new Pt(532,732), new Pt(536,744), new Pt(544,756), new Pt(552,760), new Pt(556,768), new Pt(560,776), new Pt(568,768), new Pt(568,760), new Pt(568,748), new Pt(572,740), new Pt(572,732), new Pt(580,716), new Pt(584,704), new Pt(592,668), new Pt(596,632), new Pt(596,620), new Pt(604,584), new Pt(604,572), new Pt(612,528), new Pt(620,488), new Pt(628,460), new Pt(636,440), new Pt(648,420), new Pt(656,400), new Pt(660,392), new Pt(664,384)]},
		{ id:"delete", points:[new Pt(492,316), new Pt(492,324), new Pt(496,332), new Pt(500,344), new Pt(508,360), new Pt(516,368), new Pt(532,392), new Pt(548,416), new Pt(572,432), new Pt(580,444), new Pt(592,456), new Pt(612,480), new Pt(632,504), new Pt(640,512), new Pt(656,532), new Pt(672,552), new Pt(684,564), new Pt(700,584), new Pt(712,600), new Pt(720,608), new Pt(724,620), new Pt(736,632), new Pt(744,640), new Pt(748,652), new Pt(752,660), new Pt(744,648), new Pt(732,644), new Pt(708,632), new Pt(676,624), new Pt(648,620), new Pt(616,628), new Pt(580,636), new Pt(548,640), new Pt(516,656), new Pt(488,668), new Pt(472,672), new Pt(444,684), new Pt(436,688), new Pt(440,676), new Pt(448,668), new Pt(472,636), new Pt(480,628), new Pt(512,584), new Pt(540,548), new Pt(552,532), new Pt(592,468), new Pt(628,412), new Pt(652,380), new Pt(660,368), new Pt(688,332), new Pt(708,308), new Pt(716,308), new Pt(720,300)]},
		{ id:"left curly brace", points:[new Pt(600,264), new Pt(588,268), new Pt(580,264), new Pt(568,264), new Pt(556,268), new Pt(544,268), new Pt(532,272), new Pt(516,284), new Pt(504,288), new Pt(492,292), new Pt(480,300), new Pt(472,308), new Pt(460,312), new Pt(452,316), new Pt(448,324), new Pt(452,336), new Pt(460,336), new Pt(468,340), new Pt(480,340), new Pt(492,348), new Pt(504,352), new Pt(516,360), new Pt(540,372), new Pt(548,376), new Pt(556,388), new Pt(564,396), new Pt(560,408), new Pt(556,420), new Pt(536,436), new Pt(524,444), new Pt(496,464), new Pt(484,464), new Pt(468,464), new Pt(456,468), new Pt(448,464), new Pt(456,456), new Pt(464,452), new Pt(472,452), new Pt(480,448), new Pt(488,452), new Pt(500,456), new Pt(508,460), new Pt(516,464), new Pt(520,472), new Pt(516,484), new Pt(508,500), new Pt(500,516), new Pt(492,536), new Pt(484,560), new Pt(480,576), new Pt(476,596), new Pt(480,608), new Pt(492,628), new Pt(508,644), new Pt(532,660), new Pt(568,676), new Pt(592,680), new Pt(604,684)]},
		{ id:"right curly brace", points:[new Pt(468,328), new Pt(460,328), new Pt(460,316), new Pt(468,316), new Pt(476,312), new Pt(488,308), new Pt(500,308), new Pt(508,308), new Pt(520,308), new Pt(532,316), new Pt(544,316), new Pt(552,320), new Pt(560,324), new Pt(572,336), new Pt(576,344), new Pt(580,356), new Pt(580,368), new Pt(580,380), new Pt(580,388), new Pt(580,396), new Pt(576,408), new Pt(568,428), new Pt(564,440), new Pt(556,452), new Pt(548,464), new Pt(540,468), new Pt(532,476), new Pt(524,488), new Pt(512,492), new Pt(504,504), new Pt(500,512), new Pt(500,520), new Pt(500,528), new Pt(504,536), new Pt(512,548), new Pt(520,548), new Pt(528,552), new Pt(540,556), new Pt(560,556), new Pt(580,556), new Pt(600,548), new Pt(620,544), new Pt(628,540), new Pt(636,536), new Pt(624,540), new Pt(616,540), new Pt(596,540), new Pt(580,548), new Pt(564,552), new Pt(544,564), new Pt(536,564), new Pt(524,568), new Pt(516,572), new Pt(516,580), new Pt(516,588), new Pt(524,600), new Pt(532,608), new Pt(544,624), new Pt(556,644), new Pt(568,660), new Pt(580,680), new Pt(588,700), new Pt(592,724), new Pt(588,756), new Pt(576,776), new Pt(556,792), new Pt(536,800), new Pt(504,812), new Pt(476,812), new Pt(460,812)]},
		{ id:"star", points:[new Pt(300,800), new Pt(300,788), new Pt(308,776), new Pt(312,768), new Pt(316,756), new Pt(320,748), new Pt(328,736), new Pt(328,728), new Pt(336,716), new Pt(340,700), new Pt(348,688), new Pt(352,676), new Pt(356,664), new Pt(364,648), new Pt(368,632), new Pt(376,616), new Pt(380,604), new Pt(384,584), new Pt(388,576), new Pt(392,564), new Pt(400,540), new Pt(408,512), new Pt(416,492), new Pt(416,484), new Pt(420,456), new Pt(424,432), new Pt(428,424), new Pt(428,408), new Pt(432,380), new Pt(436,364), new Pt(440,356), new Pt(448,332), new Pt(452,324), new Pt(464,308), new Pt(468,300), new Pt(476,288), new Pt(484,284), new Pt(492,280), new Pt(500,288), new Pt(500,300), new Pt(508,320), new Pt(512,332), new Pt(524,372), new Pt(544,412), new Pt(560,452), new Pt(576,488), new Pt(580,500), new Pt(604,556), new Pt(624,604), new Pt(644,652), new Pt(664,700), new Pt(676,732), new Pt(684,744), new Pt(696,772), new Pt(708,788), new Pt(712,796), new Pt(716,804), new Pt(720,812), new Pt(720,820), new Pt(716,828), new Pt(708,828), new Pt(696,820), new Pt(676,800), new Pt(656,788), new Pt(640,780), new Pt(596,752), new Pt(552,720), new Pt(508,684), new Pt(496,680), new Pt(448,648), new Pt(440,640), new Pt(384,604), new Pt(336,580), new Pt(296,560), new Pt(256,528), new Pt(220,500), new Pt(204,488), new Pt(196,480), new Pt(204,476), new Pt(224,476), new Pt(264,476), new Pt(312,472), new Pt(368,464), new Pt(428,456), new Pt(492,444), new Pt(560,448), new Pt(624,448), new Pt(684,440), new Pt(692,440), new Pt(744,440), new Pt(780,440), new Pt(792,444), new Pt(812,452), new Pt(832,452), new Pt(824,456), new Pt(800,468), new Pt(748,488), new Pt(696,516), new Pt(688,524), new Pt(612,568), new Pt(548,604), new Pt(492,644), new Pt(448,680), new Pt(396,716), new Pt(360,748), new Pt(320,776), new Pt(292,800), new Pt(276,816), new Pt(276,808)]},
		{ id:"pigtail", points:[new Pt(324,676), new Pt(336,672), new Pt(344,680), new Pt(352,680), new Pt(360,680), new Pt(368,676), new Pt(380,680), new Pt(388,676), new Pt(396,680), new Pt(408,672), new Pt(420,668), new Pt(428,664), new Pt(440,664), new Pt(452,656), new Pt(464,648), new Pt(472,640), new Pt(484,632), new Pt(496,620), new Pt(504,608), new Pt(516,596), new Pt(528,584), new Pt(544,564), new Pt(556,548), new Pt(568,528), new Pt(576,516), new Pt(584,496), new Pt(592,480), new Pt(596,472), new Pt(604,448), new Pt(608,440), new Pt(608,428), new Pt(608,420), new Pt(608,404), new Pt(608,396), new Pt(608,384), new Pt(596,368), new Pt(592,356), new Pt(580,348), new Pt(564,340), new Pt(556,340), new Pt(536,344), new Pt(520,360), new Pt(512,368), new Pt(504,380), new Pt(488,400), new Pt(476,432), new Pt(468,452), new Pt(460,480), new Pt(456,500), new Pt(468,536), new Pt(480,560), new Pt(500,596), new Pt(516,612), new Pt(532,632), new Pt(552,652), new Pt(580,660), new Pt(620,672), new Pt(656,676), new Pt(664,676), new Pt(708,676), new Pt(728,672), new Pt(768,664), new Pt(784,652), new Pt(796,648), new Pt(804,644)]}
	];
	
	public var templates:Array<DTemplate>;
	public var useProtractor:Bool;
	public var NumPoints:Int;
	public var SquareSize:Float;
	public var Origin:Pt;
	public var Diagonal:Float;
	public var HalfDiagonal:Float;
	public var AngleRange:Float;
	public var AnglePrecision:Float;
	
	//
	// DollarRecognizer class
	//
	public function new(?useProtractor:Bool = true):Void {
		this.templates = [];
		this.useProtractor = useProtractor;
		
		NumPoints = 64;
		SquareSize = 1000.0;
		Origin = new Pt(0,0);
		Diagonal = Math.sqrt(SquareSize * SquareSize + SquareSize * SquareSize);
		HalfDiagonal = 0.5 * Diagonal;
		AngleRange = deg2Rad(45.0);
		AnglePrecision = deg2Rad(2.0);
	}
	
	//
	// The $1 Gesture Recognizer API begins here -- 3 methods
	//
	public function recognize(pts:Iterable<Pt>):Array<Result> {
		var points = Pt.toArray(pts);
		points = resample(points, NumPoints);
		var radians = indicativeAngle(points);
		points = rotateBy(points, -radians);
		points = scaleTo(points, SquareSize);
		points = translateTo(points, Origin);
		var vector = useProtractor ? vectorize(points) : null; // for Protractor
	
		var b = Math.POSITIVE_INFINITY;
		var t = 0;
		
		for (i in 0...this.templates.length) // for each unistroke template
		{
			var d = if (useProtractor) { // for Protractor
				optimalCosineDistance(this.templates[i].getVector(), vector);
			} else {// Golden Section Search (original $1)
				distanceAtBestAngle(points, templates[i], -AngleRange, AngleRange, AnglePrecision);
			}
			
			if (d < b) {
				b = d; // best (least) distance
				t = i; // unistroke template
			}
		}
		return [new Result(this.templates[t], useProtractor ? 1.0 / b : 1.0 - b / HalfDiagonal)];
	}
	
	public function addTemplate(id:String, points:Iterable<Pt>):Template {
		var pts = Pt.toArray(points);
		pts = DollarRecognizer.resample(pts, NumPoints);
		var radians = DollarRecognizer.indicativeAngle(pts);
		pts = DollarRecognizer.rotateBy(pts, -radians);
		pts = DollarRecognizer.scaleTo(pts, SquareSize);
		pts = DollarRecognizer.translateTo(pts, Origin);
		
		var t = new DTemplate(id, pts);
		this.templates.push(t);
		return t;
	}
	
	public function removeTemplate(id:String):Void {
		for (t in templates) {
			if (t.id == id) {
				templates.remove(t);
				return;
			}
		}
	}
	
	public function getTemplates():Iterable<Template> {
		return templates;
	}
	
	//
	// Private helper functions from this point down
	//
	static public function resample(points:Array<Pt>, n:Int):Array<Pt> {
		var I = pathLength(points) / (n - 1); // interval length
		var D = 0.0;
		var newpoints = [points[0]];
		var i = 1;
		while (i < points.length) {
			var d = distance(points[i - 1], points[i]);
			if ((D + d) >= I) {
				var qx = points[i - 1].x + ((I - D) / d) * (points[i].x - points[i - 1].x);
				var qy = points[i - 1].y + ((I - D) / d) * (points[i].y - points[i - 1].y);
				var q = new Pt(qx, qy);
				newpoints.push(q); // append new point 'q'
				points.insert(i, q); // insert 'q' at position i in points s.t. 'q' will be the next i
				D = 0.0;
			} else {
				D += d;
			}
			
			++i;
		}
		// somtimes we fall a rounding-error short of adding the last point, so add it if so
		if (newpoints.length == n - 1)
		{
			newpoints[newpoints.length] = new Pt(points[points.length - 1].x, points[points.length - 1].y);
		}
		return newpoints;
	}
	
	static public function indicativeAngle(points:Array<Pt>):Float {
		var c = centroid(points);
		return Math.atan2(c.y - points[0].y, c.x - points[0].x);
	}
	
	// rotates points around centroid 
	static public function rotateBy(points:Array<Pt>, radians:Float):Array<Pt> {
		var c = centroid(points);
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);
		
		var newpoints = [];
		for (pt in points) {
			var qx = (pt.x - c.x) * cos - (pt.y - c.y) * sin + c.x;
			var qy = (pt.x - c.x) * sin + (pt.y - c.y) * cos + c.y;
			newpoints.push(new Pt(qx, qy));
		}
		return newpoints;
	}
	
	// non-uniform scale; assumes 2D gestures (i.e., no lines)
	static public function scaleTo(points:Array<Pt>, size:Float):Array<Pt> {
		var B = boundingBox(points);
		var newpoints = [];
		for (pt in points) {
			var qx = pt.x * (size / B.width);
			var qy = pt.y * (size / B.height);
			newpoints.push(new Pt(qx, qy));
		}
		return newpoints;
	}			
	static public function translateTo(points:Array<Pt>, pt):Array<Pt> // translates points' centroid
	{
		var c = centroid(points);
		var newpoints = [];
		for (p in points) {
			var qx = p.x + pt.x - c.x;
			var qy = p.y + pt.y - c.y;
			newpoints.push(new Pt(qx, qy));
		}
		return newpoints;
	}
	
	// for Protractor
	static public function vectorize(points:Array<Pt>):Array<Float> {
		var sum = 0.0;
		var vector = [];
		for (i in 0...points.length) {
			vector.push(points[i].x);
			vector.push(points[i].y);
			sum += points[i].x * points[i].x + points[i].y * points[i].y;
		}
		var magnitude = 1/Math.sqrt(sum);
		for (i in 0...vector.length)
			vector[i] *= magnitude;
		
		return vector;
	}
	
	// for Protractor
	static public function optimalCosineDistance(v1:Array<Float>, v2:Array<Float>):Float {
		var a = 0.0;
		var b = 0.0;
		var i = 0;
		while (i < v1.length) {
			a += v1[i] * v2[i] + v1[i + 1] * v2[i + 1];
	        b += v1[i] * v2[i + 1] - v1[i + 1] * v2[i];
	        
	        i += 2;
		}
		var angle = Math.atan(b / a);
		return Math.acos(a * Math.cos(angle) + b * Math.sin(angle));
	}
	
	static public function distanceAtBestAngle(points:Array<Pt>, T:DTemplate, a:Float, b:Float, threshold:Float):Float {
		var x1 = Phi * a + (1.0 - Phi) * b;
		var f1 = distanceAtAngle(points, T, x1);
		var x2 = (1.0 - Phi) * a + Phi * b;
		var f2 = distanceAtAngle(points, T, x2);
		while (Math.abs(b - a) > threshold)
		{
			if (f1 < f2)
			{
				b = x2;
				x2 = x1;
				f2 = f1;
				x1 = Phi * a + (1.0 - Phi) * b;
				f1 = distanceAtAngle(points, T, x1);
			}
			else
			{
				a = x1;
				x1 = x2;
				f1 = f2;
				x2 = (1.0 - Phi) * a + Phi * b;
				f2 = distanceAtAngle(points, T, x2);
			}
		}
		return Math.min(f1, f2);
	}			
	
	static public function distanceAtAngle(points:Array<Pt>, T:DTemplate, radians:Float):Float {
		var newpoints = rotateBy(points, radians);
		return pathDistance(newpoints, T.points);
	}
	
	static public function centroid(points:Array<Pt>):Pt {
		var x = 0.0, y = 0.0;
		for (i in 0...points.length) {
			x += points[i].x;
			y += points[i].y;
		}
		x /= points.length;
		y /= points.length;
		return new Pt(x, y);
	}
	
	static public function boundingBox(points:Array<Pt>):Rect {
		var	minX = Math.POSITIVE_INFINITY,
			minY = Math.POSITIVE_INFINITY,
			maxX = Math.NEGATIVE_INFINITY,
			maxY = Math.NEGATIVE_INFINITY;
		
		for (i in 0...points.length) {
			if (points[i].x < minX)
				minX = points[i].x;
			if (points[i].x > maxX)
				maxX = points[i].x;
			if (points[i].y < minY)
				minY = points[i].y;
			if (points[i].y > maxY)
				maxY = points[i].y;
		}
		return new Rect(minX, minY, maxX - minX, maxY - minY);
	}
	
	static public function pathDistance(pts1:Array<Pt>, pts2:Array<Pt>):Float {
		#if debug
		if (pts1.length != pts2.length) throw "pts1.length:" + pts1.length + " pts2.length:" + pts2.length;
		#end
		var d = 0.0;
		for (i in 0...pts1.length) // assumes pts1.length == pts2.length
			d += distance(pts1[i], pts2[i]);
		return d / pts1.length;
	}
	
	static public function pathLength(points:Array<Pt>):Float {
		var d = 0.0;
		for (i in 1...points.length)
			d += distance(points[i - 1], points[i]);
		return d;
	}
	
	static public function distance(p1:Pt, p2:Pt):Float {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	inline static public function deg2Rad(d:Float) { return (d * Math.PI / 180.0); }
	inline static public function rad2Deg(r:Float) { return (r * 180.0 / Math.PI); }
}

/**
 * Template class: a unistroke template
 */
private class DTemplate {
	public var id(default, null):String;
	public var points(default, null):Array<Pt>;
	
	public function getVector():Array<Float> {
		return vector != null ? vector : vector = DollarRecognizer.vectorize(this.points);
	}
	
	var vector:Array<Float>;
	
	
	public function new(id:String, points:Iterable<Pt>):Void {
		this.id = id;
		this.points = Pt.toArray(points);
		this.vector = null;
	}
}