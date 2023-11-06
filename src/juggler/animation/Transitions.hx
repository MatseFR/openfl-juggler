// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
//
// easing functions thankfully taken from http://dojotoolkit.org
//                                    and http://www.robertpenner.com/easing
//

package juggler.animation;

/** The Transitions class contains static methods that define easing functions. 
 *  Those functions are used by the Tween class to execute animations.
 * 
 *  <p>Here is a visual representation of the available transitions:</p> 
 *  <img src="http://gamua.com/img/blog/2010/sparrow-transitions.png"/>
 *  
 *  <p>You can define your own transitions through the "registerTransition" function. A 
 *  transition function must have the following signature, where <code>ratio</code> is 
 *  in the range 0-1:</p>
 *  
 *  <pre>function myTransition(ratio:Float):Float</pre>
 *  
 *  <p>Also have a look at the "BezierEasing" class, which provides a very easy way of
 *  adding custom transitions.</p>
 * 
 *  @see juggler.animation.BezierEasing
 *  @see juggler.animation.Juggler
 *  @see juggler.animation.Tween
 */
class Transitions 
{
	public static inline var LINEAR:String = "linear";
	public static inline var EASE_IN:String = "easeIn";
	public static inline var EASE_OUT:String = "easeOut";
	public static inline var EASE_IN_OUT:String = "easeInOut";
	public static inline var EASE_OUT_IN:String = "easeOutIn";
	public static inline var EASE_IN_BACK:String = "easeInBack";
	public static inline var EASE_OUT_BACK:String = "easeOutBack";
	public static inline var EASE_IN_OUT_BACK:String = "easeInOutBack";
	public static inline var EASE_OUT_IN_BACK:String = "easeOutInBack";
	public static inline var EASE_IN_ELASTIC:String = "easeInElastic";
	public static inline var EASE_OUT_ELASTIC:String = "easeOutElastic";
	public static inline var EASE_IN_OUT_ELASTIC:String = "easeInOutElastic";
	public static inline var EASE_OUT_IN_ELASTIC:String = "easeOutInElastic";
	public static inline var EASE_IN_BOUNCE:String = "easeInBounce";
	public static inline var EASE_OUT_BOUNCE:String = "easeOutBounce";
	public static inline var EASE_IN_OUT_BOUNCE:String = "easeInOutBounce";
	public static inline var EASE_OUT_IN_BOUNCE:String = "easeOutInBounce";
	
	public static var transitionNames(get, never):Array<String>;
	private static var _transitionNames:Array<String>;
	private static function get_transitionNames():Array<String>
	{
		if (_transitionNames == null) registerDefaults();
		return _transitionNames;
	}
	
	private static var sTransitions:Map<String, Float->Float>;
	
	private static inline var BACK_CONSTANT:Float = 1.70158;
	private static inline var BOUNCE_CONSTANT_1:Float = 7.5625;
	private static inline var BOUNCE_CONSTANT_2:Float = 2.75;
	private static inline var BOUNCE_RATIO_1_0:Float = 0.36363636363636363636363636363636;
	private static inline var BOUNCE_RATIO_1_5:Float = 0.54545454545454545454545454545455;
	private static inline var BOUNCE_RATIO_2_0:Float = 0.72727272727272727272727272727273;
	private static inline var BOUNCE_RATIO_2_25:Float = 0.81818181818181818181818181818182;
	private static inline var BOUNCE_RATIO_2_5:Float = 0.90909090909090909090909090909091;
	private static inline var BOUNCE_RATIO_2_625:Float = 0.95454545454545454545454545454545;
	private static inline var ELASTIC_CONSTANT_1:Float = 0.3;
	private static inline var ELASTIC_CONSTANT_2:Float = 0.075;
	private static inline var PI:Float = 3.1415926535897932384626433832795;
	
	/** Returns the transition function that was registered under a certain name. */
	public static function getTransition(name:String):Float->Float
	{
		if (sTransitions == null) registerDefaults();
		return sTransitions[name];
	}
	
	/** Registers a new transition function under a certain name. */
	public static function register(name:String, func:Float->Float):Void
	{
		if (sTransitions == null) registerDefaults();
		transitionNames[transitionNames.length] = name;
		sTransitions[name] = func;
	}
	
	private static function registerDefaults():Void
	{
		_transitionNames = new Array<String>();
		sTransitions = new Map<String, Float->Float>();
		
		register(LINEAR, linear);
		register(EASE_IN, easeIn);
		register(EASE_OUT, easeOut);
		register(EASE_IN_OUT, easeInOut);
		register(EASE_OUT_IN, easeOutIn);
		register(EASE_IN_BACK, easeInBack);
		register(EASE_OUT_BACK, easeOutBack);
		register(EASE_IN_OUT_BACK, easeInOutBack);
		register(EASE_OUT_IN_BACK, easeOutInBack);
		register(EASE_IN_ELASTIC, easeInElastic);
		register(EASE_OUT_ELASTIC, easeOutElastic);
		register(EASE_IN_OUT_ELASTIC, easeInOutElastic);
		register(EASE_OUT_IN_ELASTIC, easeOutInElastic);
		register(EASE_IN_BOUNCE, easeInBounce);
		register(EASE_OUT_BOUNCE, easeOutBounce);
		register(EASE_IN_OUT_BOUNCE, easeInOutBounce);
		register(EASE_OUT_IN_BOUNCE, easeOutInBounce);
	}
	
	// transition functions
	
	private static function linear(ratio:Float):Float
	{
		return ratio;
	}
	
	private static function easeIn(ratio:Float):Float
	{
		return ratio * ratio * ratio;
	}
	
	private static function easeOut(ratio:Float):Float
	{
		var invRatio:Float = ratio - 1.0;
		return invRatio * invRatio * invRatio + 1;
	}
	
	private static function easeInOut(ratio:Float):Float
	{
		return easeCombined(easeIn, easeOut, ratio);
	}
	
	private static function easeOutIn(ratio:Float):Float
	{
		return easeCombined(easeOut, easeIn, ratio);
	}
	
	private static function easeInBack(ratio:Float):Float
	{
		//return Math.pow(ratio, 2) * ((BACK_CONSTANT + 1.0) * ratio - BACK_CONSTANT);
		return ratio * ratio * ((BACK_CONSTANT + 1.0) * ratio - BACK_CONSTANT);
	}
	
	private static function easeOutBack(ratio:Float):Float
	{
		var invRatio:Float = ratio - 1.0;
		//return Math.pow(invRatio, 2) * ((BACK_CONSTANT + 1.0) * invRatio + BACK_CONSTANT) + 1.0;
		return invRatio * invRatio * ((BACK_CONSTANT + 1.0) * invRatio + BACK_CONSTANT) + 1.0;
	}
	
	private static function easeInOutBack(ratio:Float):Float
	{
		return easeCombined(easeInBack, easeOutBack, ratio);
	}
	
	private static function easeOutInBack(ratio:Float):Float
	{
		return easeCombined(easeOutBack, easeInBack, ratio);
	}
	
	private static function easeInElastic(ratio:Float):Float
	{
		if (ratio == 0 || ratio == 1) return ratio;
		
		var invRatio:Float = ratio - 1.0;
		//return -1.0 * Math.pow(2.0, 10.0 * invRatio) * Math.sin((invRatio - ELASTIC_CONSTANT_2) * (2.0 * Math.PI) / ELASTIC_CONSTANT_1);
		return -1.0 * Math.pow(2.0, 10.0 * invRatio) * Math.sin((invRatio - ELASTIC_CONSTANT_2) * (2.0 * PI) / ELASTIC_CONSTANT_1);
	}
	
	private static function easeOutElastic(ratio:Float):Float
	{
		if (ratio == 0 || ratio == 1) return ratio;
		return Math.pow(2.0, -10.0 * ratio) * Math.sin((ratio - ELASTIC_CONSTANT_2) * (2.0 * PI) / ELASTIC_CONSTANT_1) + 1;
	}
	
	private static function easeInOutElastic(ratio:Float):Float
	{
		return easeCombined(easeInElastic, easeOutElastic, ratio);
	}
	
	private static function easeOutInElastic(ratio:Float):Float
	{
		return easeCombined(easeOutElastic, easeInElastic, ratio);
	}
	
	private static function easeInBounce(ratio:Float):Float
	{
		return 1.0 - easeOutBounce(1.0 - ratio);
	}
	
	private static function easeOutBounce(ratio:Float):Float
	{
		if (ratio < BOUNCE_RATIO_1_0)
		{
			return BOUNCE_CONSTANT_1 * Math.pow(ratio, 2);
		}
		else
		{
			if (ratio < BOUNCE_RATIO_2_0)
			{
				ratio -= BOUNCE_RATIO_1_5;
				return BOUNCE_CONSTANT_1 * Math.pow(ratio, 2) + 0.75;
			}
			else
			{
				if (ratio < BOUNCE_RATIO_2_5)
				{
					ratio -= BOUNCE_RATIO_2_25;
					return BOUNCE_CONSTANT_1 * Math.pow(ratio, 2) + 0.9375;
				}
				else
				{
					ratio -= BOUNCE_RATIO_2_625;
					return BOUNCE_CONSTANT_1 * Math.pow(ratio, 2) + 0.984375;
				}
			}
		}
	}
	
	private static function easeInOutBounce(ratio:Float):Float
	{
		return easeCombined(easeInBounce, easeOutBounce, ratio);
	}
	
	private static function easeOutInBounce(ratio:Float):Float
	{
		return easeCombined(easeOutBounce, easeInBounce, ratio);
	}
	
	inline private static function easeCombined(startFunc:Float->Float, endFunc:Float->Float, ratio:Float):Float
	{
		if (ratio < 0.5) return 0.5 * startFunc(ratio * 2.0);
		return 0.5 * endFunc((ratio - 0.5) * 2.0) + 0.5;
	}
}