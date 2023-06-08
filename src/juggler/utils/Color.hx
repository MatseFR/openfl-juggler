// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package juggler.utils;

/**
 * A utility class that copies the 'interpolate' method of Starling's Color class
 */
class Color 
{

	/** Calculates a smooth transition between one color to the next.
	 *  <code>ratio</code> is expected between 0 and 1. */
	public static function interpolate(startColor:Int, endColor:Int, ratio:Float):Int
	{
		var startA:Int = (startColor >> 24) & 0xff;
		var startR:Int = (startColor >> 16) & 0xff;
		var startG:Int = (startColor >>  8) & 0xff;
		var startB:Int = (startColor      ) & 0xff;
		
		var endA:Int = (endColor >> 24) & 0xff;
		var endR:Int = (endColor >> 16) & 0xff;
		var endG:Int = (endColor >>  8) & 0xff;
		var endB:Int = (endColor      ) & 0xff;
		
		var newA:UInt = Std.int(startA + (endA - startA) * ratio);
		var newR:UInt = Std.int(startR + (endR - startR) * ratio);
		var newG:UInt = Std.int(startG + (endG - startG) * ratio);
		var newB:UInt = Std.int(startB + (endB - startB) * ratio);
		
		return (newA << 24) | (newR << 16) | (newG << 8) | newB;
	}
	
}