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
class DollarRecognizer {
	//
	// DollarRecognizer class constants
	//
	inline static public var NumTemplates = 16;
	inline static public var NumPoints = 64;
	inline static public var SquareSize = 250.0;
	inline static public var Origin = new Pt(0,0);
	inline static public var Diagonal = Math.sqrt(SquareSize * SquareSize + SquareSize * SquareSize);
	inline static public var HalfDiagonal = 0.5 * Diagonal;
	inline static public var AngleRange = deg2Rad(45.0);
	inline static public var AnglePrecision = deg2Rad(2.0);
	inline static public var Phi = 0.5 * (-1.0 + Math.sqrt(5.0)); // Golden Ratio
	
	static public var predefinedTemplate = [
		new Template("triangle", [new Pt(137,139),new Pt(135,141),new Pt(133,144),new Pt(132,146),new Pt(130,149),new Pt(128,151),new Pt(126,155),new Pt(123,160),new Pt(120,166),new Pt(116,171),new Pt(112,177),new Pt(107,183),new Pt(102,188),new Pt(100,191),new Pt(95,195),new Pt(90,199),new Pt(86,203),new Pt(82,206),new Pt(80,209),new Pt(75,213),new Pt(73,213),new Pt(70,216),new Pt(67,219),new Pt(64,221),new Pt(61,223),new Pt(60,225),new Pt(62,226),new Pt(65,225),new Pt(67,226),new Pt(74,226),new Pt(77,227),new Pt(85,229),new Pt(91,230),new Pt(99,231),new Pt(108,232),new Pt(116,233),new Pt(125,233),new Pt(134,234),new Pt(145,233),new Pt(153,232),new Pt(160,233),new Pt(170,234),new Pt(177,235),new Pt(179,236),new Pt(186,237),new Pt(193,238),new Pt(198,239),new Pt(200,237),new Pt(202,239),new Pt(204,238),new Pt(206,234),new Pt(205,230),new Pt(202,222),new Pt(197,216),new Pt(192,207),new Pt(186,198),new Pt(179,189),new Pt(174,183),new Pt(170,178),new Pt(164,171),new Pt(161,168),new Pt(154,160),new Pt(148,155),new Pt(143,150),new Pt(138,148),new Pt(136,148)]),
		new Template("x", [new Pt(87,142),new Pt(89,145),new Pt(91,148),new Pt(93,151),new Pt(96,155),new Pt(98,157),new Pt(100,160),new Pt(102,162),new Pt(106,167),new Pt(108,169),new Pt(110,171),new Pt(115,177),new Pt(119,183),new Pt(123,189),new Pt(127,193),new Pt(129,196),new Pt(133,200),new Pt(137,206),new Pt(140,209),new Pt(143,212),new Pt(146,215),new Pt(151,220),new Pt(153,222),new Pt(155,223),new Pt(157,225),new Pt(158,223),new Pt(157,218),new Pt(155,211),new Pt(154,208),new Pt(152,200),new Pt(150,189),new Pt(148,179),new Pt(147,170),new Pt(147,158),new Pt(147,148),new Pt(147,141),new Pt(147,136),new Pt(144,135),new Pt(142,137),new Pt(140,139),new Pt(135,145),new Pt(131,152),new Pt(124,163),new Pt(116,177),new Pt(108,191),new Pt(100,206),new Pt(94,217),new Pt(91,222),new Pt(89,225),new Pt(87,226),new Pt(87,224)]),
		new Template("rectangle", [new Pt(78,149),new Pt(78,153),new Pt(78,157),new Pt(78,160),new Pt(79,162),new Pt(79,164),new Pt(79,167),new Pt(79,169),new Pt(79,173),new Pt(79,178),new Pt(79,183),new Pt(80,189),new Pt(80,193),new Pt(80,198),new Pt(80,202),new Pt(81,208),new Pt(81,210),new Pt(81,216),new Pt(82,222),new Pt(82,224),new Pt(82,227),new Pt(83,229),new Pt(83,231),new Pt(85,230),new Pt(88,232),new Pt(90,233),new Pt(92,232),new Pt(94,233),new Pt(99,232),new Pt(102,233),new Pt(106,233),new Pt(109,234),new Pt(117,235),new Pt(123,236),new Pt(126,236),new Pt(135,237),new Pt(142,238),new Pt(145,238),new Pt(152,238),new Pt(154,239),new Pt(165,238),new Pt(174,237),new Pt(179,236),new Pt(186,235),new Pt(191,235),new Pt(195,233),new Pt(197,233),new Pt(200,233),new Pt(201,235),new Pt(201,233),new Pt(199,231),new Pt(198,226),new Pt(198,220),new Pt(196,207),new Pt(195,195),new Pt(195,181),new Pt(195,173),new Pt(195,163),new Pt(194,155),new Pt(192,145),new Pt(192,143),new Pt(192,138),new Pt(191,135),new Pt(191,133),new Pt(191,130),new Pt(190,128),new Pt(188,129),new Pt(186,129),new Pt(181,132),new Pt(173,131),new Pt(162,131),new Pt(151,132),new Pt(149,132),new Pt(138,132),new Pt(136,132),new Pt(122,131),new Pt(120,131),new Pt(109,130),new Pt(107,130),new Pt(90,132),new Pt(81,133),new Pt(76,133)]),
		new Template("circle", [new Pt(127,141),new Pt(124,140),new Pt(120,139),new Pt(118,139),new Pt(116,139),new Pt(111,140),new Pt(109,141),new Pt(104,144),new Pt(100,147),new Pt(96,152),new Pt(93,157),new Pt(90,163),new Pt(87,169),new Pt(85,175),new Pt(83,181),new Pt(82,190),new Pt(82,195),new Pt(83,200),new Pt(84,205),new Pt(88,213),new Pt(91,216),new Pt(96,219),new Pt(103,222),new Pt(108,224),new Pt(111,224),new Pt(120,224),new Pt(133,223),new Pt(142,222),new Pt(152,218),new Pt(160,214),new Pt(167,210),new Pt(173,204),new Pt(178,198),new Pt(179,196),new Pt(182,188),new Pt(182,177),new Pt(178,167),new Pt(170,150),new Pt(163,138),new Pt(152,130),new Pt(143,129),new Pt(140,131),new Pt(129,136),new Pt(126,139)]),
		new Template("check", [new Pt(91,185),new Pt(93,185),new Pt(95,185),new Pt(97,185),new Pt(100,188),new Pt(102,189),new Pt(104,190),new Pt(106,193),new Pt(108,195),new Pt(110,198),new Pt(112,201),new Pt(114,204),new Pt(115,207),new Pt(117,210),new Pt(118,212),new Pt(120,214),new Pt(121,217),new Pt(122,219),new Pt(123,222),new Pt(124,224),new Pt(126,226),new Pt(127,229),new Pt(129,231),new Pt(130,233),new Pt(129,231),new Pt(129,228),new Pt(129,226),new Pt(129,224),new Pt(129,221),new Pt(129,218),new Pt(129,212),new Pt(129,208),new Pt(130,198),new Pt(132,189),new Pt(134,182),new Pt(137,173),new Pt(143,164),new Pt(147,157),new Pt(151,151),new Pt(155,144),new Pt(161,137),new Pt(165,131),new Pt(171,122),new Pt(174,118),new Pt(176,114),new Pt(177,112),new Pt(177,114),new Pt(175,116),new Pt(173,118)]),
		new Template("caret", [new Pt(79,245),new Pt(79,242),new Pt(79,239),new Pt(80,237),new Pt(80,234),new Pt(81,232),new Pt(82,230),new Pt(84,224),new Pt(86,220),new Pt(86,218),new Pt(87,216),new Pt(88,213),new Pt(90,207),new Pt(91,202),new Pt(92,200),new Pt(93,194),new Pt(94,192),new Pt(96,189),new Pt(97,186),new Pt(100,179),new Pt(102,173),new Pt(105,165),new Pt(107,160),new Pt(109,158),new Pt(112,151),new Pt(115,144),new Pt(117,139),new Pt(119,136),new Pt(119,134),new Pt(120,132),new Pt(121,129),new Pt(122,127),new Pt(124,125),new Pt(126,124),new Pt(129,125),new Pt(131,127),new Pt(132,130),new Pt(136,139),new Pt(141,154),new Pt(145,166),new Pt(151,182),new Pt(156,193),new Pt(157,196),new Pt(161,209),new Pt(162,211),new Pt(167,223),new Pt(169,229),new Pt(170,231),new Pt(173,237),new Pt(176,242),new Pt(177,244),new Pt(179,250),new Pt(181,255),new Pt(182,257)]),
		new Template("zig-zag", [new Pt(307,216),new Pt(333,186),new Pt(356,215),new Pt(375,186),new Pt(399,216),new Pt(418,186)]),
		new Template("arrow", [new Pt(68,222),new Pt(70,220),new Pt(73,218),new Pt(75,217),new Pt(77,215),new Pt(80,213),new Pt(82,212),new Pt(84,210),new Pt(87,209),new Pt(89,208),new Pt(92,206),new Pt(95,204),new Pt(101,201),new Pt(106,198),new Pt(112,194),new Pt(118,191),new Pt(124,187),new Pt(127,186),new Pt(132,183),new Pt(138,181),new Pt(141,180),new Pt(146,178),new Pt(154,173),new Pt(159,171),new Pt(161,170),new Pt(166,167),new Pt(168,167),new Pt(171,166),new Pt(174,164),new Pt(177,162),new Pt(180,160),new Pt(182,158),new Pt(183,156),new Pt(181,154),new Pt(178,153),new Pt(171,153),new Pt(164,153),new Pt(160,153),new Pt(150,154),new Pt(147,155),new Pt(141,157),new Pt(137,158),new Pt(135,158),new Pt(137,158),new Pt(140,157),new Pt(143,156),new Pt(151,154),new Pt(160,152),new Pt(170,149),new Pt(179,147),new Pt(185,145),new Pt(192,144),new Pt(196,144),new Pt(198,144),new Pt(200,144),new Pt(201,147),new Pt(199,149),new Pt(194,157),new Pt(191,160),new Pt(186,167),new Pt(180,176),new Pt(177,179),new Pt(171,187),new Pt(169,189),new Pt(165,194),new Pt(164,196)]),
		new Template("left square bracket", [new Pt(140,124),new Pt(138,123),new Pt(135,122),new Pt(133,123),new Pt(130,123),new Pt(128,124),new Pt(125,125),new Pt(122,124),new Pt(120,124),new Pt(118,124),new Pt(116,125),new Pt(113,125),new Pt(111,125),new Pt(108,124),new Pt(106,125),new Pt(104,125),new Pt(102,124),new Pt(100,123),new Pt(98,123),new Pt(95,124),new Pt(93,123),new Pt(90,124),new Pt(88,124),new Pt(85,125),new Pt(83,126),new Pt(81,127),new Pt(81,129),new Pt(82,131),new Pt(82,134),new Pt(83,138),new Pt(84,141),new Pt(84,144),new Pt(85,148),new Pt(85,151),new Pt(86,156),new Pt(86,160),new Pt(86,164),new Pt(86,168),new Pt(87,171),new Pt(87,175),new Pt(87,179),new Pt(87,182),new Pt(87,186),new Pt(88,188),new Pt(88,195),new Pt(88,198),new Pt(88,201),new Pt(88,207),new Pt(89,211),new Pt(89,213),new Pt(89,217),new Pt(89,222),new Pt(88,225),new Pt(88,229),new Pt(88,231),new Pt(88,233),new Pt(88,235),new Pt(89,237),new Pt(89,240),new Pt(89,242),new Pt(91,241),new Pt(94,241),new Pt(96,240),new Pt(98,239),new Pt(105,240),new Pt(109,240),new Pt(113,239),new Pt(116,240),new Pt(121,239),new Pt(130,240),new Pt(136,237),new Pt(139,237),new Pt(144,238),new Pt(151,237),new Pt(157,236),new Pt(159,237)]),
		new Template("right square bracket", [new Pt(112,138),new Pt(112,136),new Pt(115,136),new Pt(118,137),new Pt(120,136),new Pt(123,136),new Pt(125,136),new Pt(128,136),new Pt(131,136),new Pt(134,135),new Pt(137,135),new Pt(140,134),new Pt(143,133),new Pt(145,132),new Pt(147,132),new Pt(149,132),new Pt(152,132),new Pt(153,134),new Pt(154,137),new Pt(155,141),new Pt(156,144),new Pt(157,152),new Pt(158,161),new Pt(160,170),new Pt(162,182),new Pt(164,192),new Pt(166,200),new Pt(167,209),new Pt(168,214),new Pt(168,216),new Pt(169,221),new Pt(169,223),new Pt(169,228),new Pt(169,231),new Pt(166,233),new Pt(164,234),new Pt(161,235),new Pt(155,236),new Pt(147,235),new Pt(140,233),new Pt(131,233),new Pt(124,233),new Pt(117,235),new Pt(114,238),new Pt(112,238)]),
		new Template("v", [new Pt(89,164),new Pt(90,162),new Pt(92,162),new Pt(94,164),new Pt(95,166),new Pt(96,169),new Pt(97,171),new Pt(99,175),new Pt(101,178),new Pt(103,182),new Pt(106,189),new Pt(108,194),new Pt(111,199),new Pt(114,204),new Pt(117,209),new Pt(119,214),new Pt(122,218),new Pt(124,222),new Pt(126,225),new Pt(128,228),new Pt(130,229),new Pt(133,233),new Pt(134,236),new Pt(136,239),new Pt(138,240),new Pt(139,242),new Pt(140,244),new Pt(142,242),new Pt(142,240),new Pt(142,237),new Pt(143,235),new Pt(143,233),new Pt(145,229),new Pt(146,226),new Pt(148,217),new Pt(149,208),new Pt(149,205),new Pt(151,196),new Pt(151,193),new Pt(153,182),new Pt(155,172),new Pt(157,165),new Pt(159,160),new Pt(162,155),new Pt(164,150),new Pt(165,148),new Pt(166,146)]),
		new Template("delete", [new Pt(123,129),new Pt(123,131),new Pt(124,133),new Pt(125,136),new Pt(127,140),new Pt(129,142),new Pt(133,148),new Pt(137,154),new Pt(143,158),new Pt(145,161),new Pt(148,164),new Pt(153,170),new Pt(158,176),new Pt(160,178),new Pt(164,183),new Pt(168,188),new Pt(171,191),new Pt(175,196),new Pt(178,200),new Pt(180,202),new Pt(181,205),new Pt(184,208),new Pt(186,210),new Pt(187,213),new Pt(188,215),new Pt(186,212),new Pt(183,211),new Pt(177,208),new Pt(169,206),new Pt(162,205),new Pt(154,207),new Pt(145,209),new Pt(137,210),new Pt(129,214),new Pt(122,217),new Pt(118,218),new Pt(111,221),new Pt(109,222),new Pt(110,219),new Pt(112,217),new Pt(118,209),new Pt(120,207),new Pt(128,196),new Pt(135,187),new Pt(138,183),new Pt(148,167),new Pt(157,153),new Pt(163,145),new Pt(165,142),new Pt(172,133),new Pt(177,127),new Pt(179,127),new Pt(180,125)]),
		new Template("left curly brace", [new Pt(150,116),new Pt(147,117),new Pt(145,116),new Pt(142,116),new Pt(139,117),new Pt(136,117),new Pt(133,118),new Pt(129,121),new Pt(126,122),new Pt(123,123),new Pt(120,125),new Pt(118,127),new Pt(115,128),new Pt(113,129),new Pt(112,131),new Pt(113,134),new Pt(115,134),new Pt(117,135),new Pt(120,135),new Pt(123,137),new Pt(126,138),new Pt(129,140),new Pt(135,143),new Pt(137,144),new Pt(139,147),new Pt(141,149),new Pt(140,152),new Pt(139,155),new Pt(134,159),new Pt(131,161),new Pt(124,166),new Pt(121,166),new Pt(117,166),new Pt(114,167),new Pt(112,166),new Pt(114,164),new Pt(116,163),new Pt(118,163),new Pt(120,162),new Pt(122,163),new Pt(125,164),new Pt(127,165),new Pt(129,166),new Pt(130,168),new Pt(129,171),new Pt(127,175),new Pt(125,179),new Pt(123,184),new Pt(121,190),new Pt(120,194),new Pt(119,199),new Pt(120,202),new Pt(123,207),new Pt(127,211),new Pt(133,215),new Pt(142,219),new Pt(148,220),new Pt(151,221)]),
		new Template("right curly brace", [new Pt(117,132),new Pt(115,132),new Pt(115,129),new Pt(117,129),new Pt(119,128),new Pt(122,127),new Pt(125,127),new Pt(127,127),new Pt(130,127),new Pt(133,129),new Pt(136,129),new Pt(138,130),new Pt(140,131),new Pt(143,134),new Pt(144,136),new Pt(145,139),new Pt(145,142),new Pt(145,145),new Pt(145,147),new Pt(145,149),new Pt(144,152),new Pt(142,157),new Pt(141,160),new Pt(139,163),new Pt(137,166),new Pt(135,167),new Pt(133,169),new Pt(131,172),new Pt(128,173),new Pt(126,176),new Pt(125,178),new Pt(125,180),new Pt(125,182),new Pt(126,184),new Pt(128,187),new Pt(130,187),new Pt(132,188),new Pt(135,189),new Pt(140,189),new Pt(145,189),new Pt(150,187),new Pt(155,186),new Pt(157,185),new Pt(159,184),new Pt(156,185),new Pt(154,185),new Pt(149,185),new Pt(145,187),new Pt(141,188),new Pt(136,191),new Pt(134,191),new Pt(131,192),new Pt(129,193),new Pt(129,195),new Pt(129,197),new Pt(131,200),new Pt(133,202),new Pt(136,206),new Pt(139,211),new Pt(142,215),new Pt(145,220),new Pt(147,225),new Pt(148,231),new Pt(147,239),new Pt(144,244),new Pt(139,248),new Pt(134,250),new Pt(126,253),new Pt(119,253),new Pt(115,253)]),
		new Template("star", [new Pt(75,250),new Pt(75,247),new Pt(77,244),new Pt(78,242),new Pt(79,239),new Pt(80,237),new Pt(82,234),new Pt(82,232),new Pt(84,229),new Pt(85,225),new Pt(87,222),new Pt(88,219),new Pt(89,216),new Pt(91,212),new Pt(92,208),new Pt(94,204),new Pt(95,201),new Pt(96,196),new Pt(97,194),new Pt(98,191),new Pt(100,185),new Pt(102,178),new Pt(104,173),new Pt(104,171),new Pt(105,164),new Pt(106,158),new Pt(107,156),new Pt(107,152),new Pt(108,145),new Pt(109,141),new Pt(110,139),new Pt(112,133),new Pt(113,131),new Pt(116,127),new Pt(117,125),new Pt(119,122),new Pt(121,121),new Pt(123,120),new Pt(125,122),new Pt(125,125),new Pt(127,130),new Pt(128,133),new Pt(131,143),new Pt(136,153),new Pt(140,163),new Pt(144,172),new Pt(145,175),new Pt(151,189),new Pt(156,201),new Pt(161,213),new Pt(166,225),new Pt(169,233),new Pt(171,236),new Pt(174,243),new Pt(177,247),new Pt(178,249),new Pt(179,251),new Pt(180,253),new Pt(180,255),new Pt(179,257),new Pt(177,257),new Pt(174,255),new Pt(169,250),new Pt(164,247),new Pt(160,245),new Pt(149,238),new Pt(138,230),new Pt(127,221),new Pt(124,220),new Pt(112,212),new Pt(110,210),new Pt(96,201),new Pt(84,195),new Pt(74,190),new Pt(64,182),new Pt(55,175),new Pt(51,172),new Pt(49,170),new Pt(51,169),new Pt(56,169),new Pt(66,169),new Pt(78,168),new Pt(92,166),new Pt(107,164),new Pt(123,161),new Pt(140,162),new Pt(156,162),new Pt(171,160),new Pt(173,160),new Pt(186,160),new Pt(195,160),new Pt(198,161),new Pt(203,163),new Pt(208,163),new Pt(206,164),new Pt(200,167),new Pt(187,172),new Pt(174,179),new Pt(172,181),new Pt(153,192),new Pt(137,201),new Pt(123,211),new Pt(112,220),new Pt(99,229),new Pt(90,237),new Pt(80,244),new Pt(73,250),new Pt(69,254),new Pt(69,252)]),
		new Template("pigtail", [new Pt(81,219),new Pt(84,218),new Pt(86,220),new Pt(88,220),new Pt(90,220),new Pt(92,219),new Pt(95,220),new Pt(97,219),new Pt(99,220),new Pt(102,218),new Pt(105,217),new Pt(107,216),new Pt(110,216),new Pt(113,214),new Pt(116,212),new Pt(118,210),new Pt(121,208),new Pt(124,205),new Pt(126,202),new Pt(129,199),new Pt(132,196),new Pt(136,191),new Pt(139,187),new Pt(142,182),new Pt(144,179),new Pt(146,174),new Pt(148,170),new Pt(149,168),new Pt(151,162),new Pt(152,160),new Pt(152,157),new Pt(152,155),new Pt(152,151),new Pt(152,149),new Pt(152,146),new Pt(149,142),new Pt(148,139),new Pt(145,137),new Pt(141,135),new Pt(139,135),new Pt(134,136),new Pt(130,140),new Pt(128,142),new Pt(126,145),new Pt(122,150),new Pt(119,158),new Pt(117,163),new Pt(115,170),new Pt(114,175),new Pt(117,184),new Pt(120,190),new Pt(125,199),new Pt(129,203),new Pt(133,208),new Pt(138,213),new Pt(145,215),new Pt(155,218),new Pt(164,219),new Pt(166,219),new Pt(177,219),new Pt(182,218),new Pt(192,216),new Pt(196,213),new Pt(199,212),new Pt(201,211)])
	];
	
	public var templates:Array<Template>;
	
	//
	// DollarRecognizer class
	//
	public function new():Void {
		//
		// one predefined template for each unistroke type
		//
		this.templates = predefinedTemplate.copy();
	}
	
	//
	// The $1 Gesture Recognizer API begins here -- 3 methods
	//
	public function recognize(points:Array<Pt>, useProtractor:Bool):Result {
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
				optimalCosineDistance(this.templates[i].vector, vector);
			} else {// Golden Section Search (original $1)
				distanceAtBestAngle(points, this.templates[i], -AngleRange, AngleRange, AnglePrecision);
			}
			
			if (d < b) {
				b = d; // best (least) distance
				t = i; // unistroke template
			}
		}
		return new Result(this.templates[t].name, useProtractor ? 1.0 / b : 1.0 - b / HalfDiagonal);
	}
	
	public function addTemplate(name:String, points:Array<Pt>):Int {
		return this.templates.push(new Template(name, points));
	}
	
	//
	// Private helper functions from this point down
	//
	static public function resample(points:Array<Pt>, n:Int):Array<Pt> {
		var I = pathLength(points) / (n - 1); // interval length
		var D = 0.0;
		var newpoints = [points[0]];
		for (i in 1...points.length) {
			var d = distance(points[i - 1], points[i]);
			if ((D + d) >= I)
			{
				var qx = points[i - 1].x + ((I - D) / d) * (points[i].x - points[i - 1].x);
				var qy = points[i - 1].y + ((I - D) / d) * (points[i].y - points[i - 1].y);
				var q = new Pt(qx, qy);
				newpoints[newpoints.length] = q; // append new point 'q'
				points.insert(i, q); // insert 'q' at position i in points s.t. 'q' will be the next i
				D = 0.0;
			}
			else D += d;
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
		for (i in 0...points.length) {
			var qx = (points[i].x - c.x) * cos - (points[i].y - c.y) * sin + c.x;
			var qy = (points[i].x - c.x) * sin + (points[i].y - c.y) * cos + c.y;
			newpoints[newpoints.length] = new Pt(qx, qy);
		}
		return newpoints;
	}
	
	// non-uniform scale; assumes 2D gestures (i.e., no lines)
	static public function scaleTo(points:Array<Pt>, size:Float):Array<Pt> {
		var B = boundingBox(points);
		var newpoints = [];
		for (i in 0...points.length) {
			var qx = points[i].x * (size / B.width);
			var qy = points[i].y * (size / B.height);
			newpoints[newpoints.length] = new Pt(qx, qy);
		}
		return newpoints;
	}			
	static public function translateTo(points:Array<Pt>, pt):Array<Pt> // translates points' centroid
	{
		var c = centroid(points);
		var newpoints = [];
		for (i in 0...points.length) {
			var qx = points[i].x + pt.x - c.x;
			var qy = points[i].y + pt.y - c.y;
			newpoints[newpoints.length] = new Pt(qx, qy);
		}
		return newpoints;
	}
	
	// for Protractor
	static public function vectorize(points:Array<Pt>):Array<Float> {
		var sum = 0.0;
		var vector = [];
		for (i in 0...points.length) {
			vector[vector.length] = points[i].x;
			vector[vector.length] = points[i].y;
			sum += points[i].x * points[i].x + points[i].y * points[i].y;
		}
		var magnitude = Math.sqrt(sum);
		for (i in 0...vector.length)
			vector[i] /= magnitude;
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
	
	static public function distanceAtBestAngle(points:Array<Pt>, T:Template, a:Float, b:Float, threshold:Float):Float {
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
	
	static public function distanceAtAngle(points:Array<Pt>, T:Template, radians:Float):Float {
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
private class Template {
	public var name(default, null):String;
	public var points(default, null):Array<Pt>;
	public var vector(default, null):Array<Float>;
	
	
	public function new(name:String, points:Array<Pt>):Void {
		this.name = name;
		this.points = DollarRecognizer.resample(points, DollarRecognizer.NumPoints);
		var radians = DollarRecognizer.indicativeAngle(this.points);
		this.points = DollarRecognizer.rotateBy(this.points, -radians);
		this.points = DollarRecognizer.scaleTo(this.points, DollarRecognizer.SquareSize);
		this.points = DollarRecognizer.translateTo(this.points, DollarRecognizer.Origin);
		this.vector = DollarRecognizer.vectorize(this.points); // for Protractor
	}
}

/**
 * Result class
 */
private class Result {
	public var name(default, null):String;
	public var score(default, null):Float;
	
	public function new(name:String, score:Float):Void {
		this.name = name;
		this.score = score;
	}
}