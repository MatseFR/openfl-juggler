// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package juggler.animation;

import haxe.Constraints.Function;
import juggler.event.JugglerEvent;
import juggler.utils.Color;
import openfl.errors.ArgumentError;
import openfl.events.EventDispatcher;

/** A Tween animates numeric properties of objects. It uses different transition functions
 *  to give the animations various styles.
 *  
 *  <p>The primary use of this class is to do standard animations like movement, fading, 
 *  rotation, etc. But there are no limits on what to animate; as long as the property you want
 *  to animate is numeric (<code>int, uint, Number</code>), the tween can handle it. For a list 
 *  of available Transition types, look at the "Transitions" class.</p> 
 *  
 *  <p>Here is an example of a tween that moves an object to the right, rotates it, and 
 *  fades it out:</p>
 *  
 *  <listing>
 *  var tween:Tween = new Tween(object, 2.0, Transitions.EASE_IN_OUT);
 *  tween.animate("x", object.x + 50);
 *  tween.animate("rotation", deg2rad(45));
 *  tween.fadeTo(0);    // equivalent to 'animate("alpha", 0)'
 *  Starling.juggler.add(tween);</listing> 
 *  
 *  <p>Note that the object is added to a juggler at the end of this sample. That's because a 
 *  tween will only be executed if its "advanceTime" method is executed regularly - the 
 *  juggler will do that for you, and will remove the tween when it is finished.</p>
 *  
 *  @see Juggler
 *  @see Transitions
 */
@:access(openfl.events.EventDispatcher)
class Tween extends EventDispatcher implements IAnimatable
{
	private static inline var HINT_MARKER:String = "#";
	
	/** The time that has passed since the tween was created (in seconds). */
	public var currentTime(get, never):Float;
	/** The delay before the tween is started (in seconds). @default 0 */
	public var delay(get, set):Float;
	/** Indicates if the tween is finished. */
	public var isComplete(get, never):Bool;
	/** Another tween that will be started (i.e. added to the same juggler) as soon as 
	 *  this tween is completed. */
	public var nextTween(get, set):Tween;
	/** A function that will be called when the tween is complete. */
	public var onComplete(get, set):Function;
	/** The arguments that will be passed to the 'onComplete' function. */
	public var onCompleteArgs(get, set):Array<Dynamic>;
	/** A function that will be called each time the tween finishes one repetition
	 * (except the last, which will trigger 'onComplete'). */
	public var onRepeat(get, set):Function;
	/** The arguments that will be passed to the 'onRepeat' function. */
	public var onRepeatArgs(get, set):Array<Dynamic>;
	/** A function that will be called when the tween starts (after a possible delay). */
	public var onStart(get, set):Function;
	/** The arguments that will be passed to the 'onStart' function. */
	public var onStartArgs(get, set):Array<Dynamic>;
	/** A function that will be called each time the tween is advanced. */
	public var onUpdate(get, set):Function;
	/** The arguments that will be passed to the 'onUpdate' function. */
	public var onUpdateArgs(get, set):Array<Dynamic>;
	/** The current progress between 0 and 1, as calculated by the transition function. */
	public var progress(get, never):Float;
	/** The number of times the tween will be executed. 
	 *  Set to '0' to tween indefinitely. @default 1 */
	public var repeatCount(get, set):Int;
	/** The amount of time to wait between repeat cycles (in seconds). @default 0 */
	public var repeatDelay(get, set):Float;
	/** Indicates if the tween should be reversed when it is repeating. If enabled, 
	 *  every second repetition will be reversed. @default false */
	public var reverse(get, set):Bool;
	/** Indicates if the numeric values should be cast to Integers. @default false */
	public var roundToInt(get, set):Bool;
	/** The target object that is animated. */
	public var target(get, never):Dynamic;
	/** The total time the tween will take per repetition (in seconds). */
	public var totalTime(get, never):Float;
	/** The transition method used for the animation. @see Transitions */
	public var transition(get, set):String;
	/** The actual transition function used for the animation. */
	public var transitionFunc(get, set):Float->Float;
	
	private var __currentTime:Float;
	private function get_currentTime():Float { return this.__currentTime; }
	
	private var __delay:Float;
	private function get_delay():Float { return this.__delay; }
	private function set_delay(value:Float):Float
	{
		this.__currentTime = this.__currentTime + this.__delay - value;
		return this.__delay = value;
	}
	
	private function get_isComplete():Bool
	{
		return this.__currentTime >= this.__totalTime && this.__repeatCount == 1;
	}
	
	private var __nextTween:Tween;
	private function get_nextTween():Tween { return this.__nextTween; }
	private function set_nextTween(value:Tween):Tween
	{
		return this.__nextTween = value;
	}
	
	private var __onComplete:Function;
	private function get_onComplete():Function { return this.__onComplete; }
	private function set_onComplete(value:Function):Function
	{
		return this.__onComplete = value;
	}
	
	private var __onCompleteArgs:Array<Dynamic>;
	private function get_onCompleteArgs():Array<Dynamic> { return this.__onCompleteArgs; }
	private function set_onCompleteArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		return this.__onCompleteArgs = value;
	}
	
	private var __onRepeat:Function;
	private function get_onRepeat():Function { return this.__onRepeat; }
	private function set_onRepeat(value:Function):Function
	{
		return this.__onRepeat = value;
	}
	
	private var __onRepeatArgs:Array<Dynamic>;
	private function get_onRepeatArgs():Array<Dynamic> { return this.__onRepeatArgs; }
	private function set_onRepeatArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		return this.__onRepeatArgs = value;
	}
	
	private var __onStart:Function;
	private function get_onStart():Function { return this.__onStart; }
	private function set_onStart(value:Function):Function
	{
		return this.__onStart = value;
	}
	
	private var __onStartArgs:Array<Dynamic>;
	private function get_onStartArgs():Array<Dynamic> { return this.__onStartArgs; }
	private function set_onStartArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		return this.__onStartArgs = value;
	}
	
	private var __onUpdate:Function;
	private function get_onUpdate():Function { return this.__onUpdate; }
	private function set_onUpdate(value:Function):Function
	{
		return this.__onUpdate = value;
	}
	
	private var __onUpdateArgs:Array<Dynamic>;
	private function get_onUpdateArgs():Array<Dynamic> { return this.__onUpdateArgs; }
	private function set_onUpdateArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		return this.__onUpdateArgs = value;
	}
	
	private var __progress:Float;
	private function get_progress():Float { return this.__progress; }
	
	private var __repeatCount:Int;
	private function get_repeatCount():Int { return this.__repeatCount; }
	private function set_repeatCount(value:Int):Int
	{
		return this.__repeatCount = value;
	}
	
	private var __repeatDelay:Float;
	private function get_repeatDelay():Float { return this.__repeatDelay; }
	private function set_repeatDelay(value:Float):Float
	{
		return this.__repeatDelay = value;
	}
	
	private var __reverse:Bool;
	private function get_reverse():Bool { return this.__reverse; }
	private function set_reverse(value:Bool):Bool
	{
		return this.__reverse = value;
	}
	
	private var __roundToInt:Bool;
	private function get_roundToInt():Bool { return this.__reverse; }
	private function set_roundToInt(value:Bool):Bool
	{
		return this.__roundToInt = value;
	}
	
	private var __target:Dynamic;
	private function get_target():Dynamic { return this.__target; }
	
	private var __totalTime:Float;
	private function get_totalTime():Float { return this.__totalTime; }
	
	private var __transitionName:String;
	private function get_transition():String { return this.__transitionName; }
	private function set_transition(value:String):String
	{
		this.__transitionFunc = Transitions.getTransition(value);
        
        if (this.__transitionFunc == null)
		{
            throw new ArgumentError("Invalid transiton: " + value);
		}
		return this.__transitionName = value;
	}
	
	private var __transitionFunc:Float->Float;
	private function get_transitionFunc():Float->Float { return this.__transitionFunc; }
	private function set_transitionFunc(value:Float->Float):Float->Float
	{
		this.__transitionName = "custom";
		return this.__transitionFunc = value;
	}
	
	private var __properties:Array<String>;
	private var __startValues:Array<Float>;
	private var __endValues:Array<Float>;
	private var __updateFuncs:Array<String->Float->Float->Void>;
	
	private var __currentCycle:Int;
	
	public function new(target:Dynamic, time:Float, transition:Dynamic = "linear") 
	{
		//super(target);
		super();
		reset(target, time, transition);
	}
	
	public function clear():Void
	{
		// reset any object-references, to make sure we don't prevent any garbage collection
		this.__onStart = this.__onUpdate = this.__onRepeat = this.__onComplete = null;
		this.__onStartArgs = this.__onUpdateArgs = this.__onRepeatArgs = this.__onCompleteArgs = null;
		this.__target = null;
		this.__transitionFunc = null;
		#if !flash
		this.__removeAllListeners(); // not sure about this
		#end
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	/** Resets the tween to its default values. Useful for pooling tweens. */
	public function reset(target:Dynamic, time:Float, transition:Dynamic = "linear"):Tween
	{
		this.__target = target;
		this.__currentTime = 0.0;
		this.__totalTime = Math.max(0.0001, time);
		this.__progress = 0.0;
		this.__delay = this.__repeatDelay = 0.0;
		this.__onStart = this.__onUpdate = this.__onRepeat = this.__onComplete = null;
		this.__onStartArgs = this.__onUpdateArgs = this.__onRepeatArgs = this.__onCompleteArgs = null;
		this.__roundToInt = this.__reverse = false;
		this.__repeatCount = 1;
		this.__currentCycle = -1;
		this.__nextTween = null;
		
		if (Std.isOfType(transition, String))
		{
			this.transition = cast transition;
		}
		else
		{
			this.transitionFunc = transition;
		}
		
		if (this.__properties != null) 
		{
			this.__properties.resize(0);
		}
		else
		{
			this.__properties = new Array<String>();
		}
		
		if (this.__startValues != null)
		{
			this.__startValues.resize(0);
		}
		else
		{
			this.__startValues = new Array<Float>();
		}
		
		if (this.__endValues != null)
		{
			this.__endValues.resize(0);
		}
		else
		{
			this.__endValues = new Array<Float>();
		}
		
		if (this.__updateFuncs != null)
		{
			this.__updateFuncs.resize(0);
		}
		else
		{
			this.__updateFuncs = new Array<String->Float->Float->Void>();
		}
		
		return this;
	}
	
	/** Animates the property of the target to a certain value. You can call this method
	 * multiple times on one tween.
	 *
	 * <p>Some property types are handled in a special way:</p>
	 * <ul>
	 *   <li>If the property contains the string <code>color</code> or <code>Color</code>,
	 *       it will be treated as an unsigned integer with a color value
	 *       (e.g. <code>0xff0000</code> for red). Each color channel will be animated
	 *       individually.</li>
	 *   <li>The same happens if you append the string <code>#rgb</code> to the name.</li>
	 *   <li>If you append <code>#rad</code>, the property is treated as an angle in radians,
	 *       making sure it always uses the shortest possible arc for the rotation.</li>
	 *   <li>The string <code>#deg</code> does the same for angles in degrees.</li>
	 * </ul>
	 */
	public function animate(property:String, endValue:Float):Void
	{
		if (this.__target == null) return; // tweening null just does nothing.
		
		var pos:Int = this.__properties.length;
		var updateFunc:String->Float->Float->Void = getUpdateFuncFromProperty(property);
		
		this.__properties[pos] = getPropertyName(property);
		this.__startValues[pos] = Math.NaN;
		this.__endValues[pos] = endValue;
		this.__updateFuncs[pos] = updateFunc;
	}
	
	public function animateStartEnd(property:String, startValue:Float, endValue:Float):Void
	{
		if (this.__target == null) return; // tweening null just does nothing.
		
		var pos:Int = this.__properties.length;
		var updateFunc:String->Float->Float->Void = getUpdateFuncFromProperty(property);
		
		this.__properties[pos] = getPropertyName(property);
		this.__startValues[pos] = startValue;
		this.__endValues[pos] = endValue;
		this.__updateFuncs[pos] = updateFunc;
	}
	
	/** Animates the 'scaleX' and 'scaleY' properties of an object simultaneously. */
	public function scaleTo(factor:Float):Void
	{
		animate("scaleX", factor);
		animate("scaleY", factor);
	}
	
	/** Animates the 'x' and 'y' properties of an object simultaneously. */
	public function moveTo(x:Float, y:Float):Void
	{
		animate("x", x);
		animate("y", y);
	}
	
	/** Animates the 'alpha' property of an object to a certain target value. */
	public function fadeTo(alpha:Float):Void
	{
		animate("alpha", alpha);
	}
	
	/** Animates the 'rotation' property of an object to a certain target value, using the
	 * smallest possible arc. 'type' may be either 'rad' or 'deg', depending on the unit of
	 * measurement. */
	public function rotateTo(angle:Float, type:String = "deg"):Void
	{
		animate("rotation#" + type, angle);
	}
	
	/** @inheritDoc */
	public function advanceTime(time:Float):Void
	{
		if (time == 0 || (this.__repeatCount == 1 && this.__currentTime == this.__totalTime)) return;
		
		var i:Int;
		var previousTime:Float = this.__currentTime;
		var restTime:Float = this.__totalTime - this.__currentTime;
		var carryOverTime:Float = time > restTime ? time - restTime : 0.0;
		
		this.__currentTime += time;
		
		if (this.__currentTime <= 0)
		{
			return; // the delay is not over yet
		}
		else if (this.__currentTime > this.__totalTime)
		{
			this.__currentTime = this.__totalTime;
		}
		
		if (this.__currentCycle < 0 && previousTime <= 0 && this.__currentTime > 0)
		{
			this.__currentCycle++;
			if (this.__onStart != null)
			{
				if (this.__onStartArgs != null)
				{
					Reflect.callMethod(this.__onStart, this.__onStart, this.__onStartArgs);
				}
				else
				{
					this.__onStart();
				}
			}
		}
		
		var ratio:Float = this.__currentTime / this.__totalTime;
		var reversed:Bool = this.__reverse && (this.__currentCycle % 2 == 1);
		var numProperties:Int = this.__startValues.length;
		this.__progress = reversed ? this.__transitionFunc(1.0 - ratio) : this.__transitionFunc(ratio);
		
		for (i in 0...numProperties)
		{
			if (this.__startValues[i] != this.__startValues[i]) // isNaN check - "isNaN" causes allocation!
			{
				this.__startValues[i] = Reflect.getProperty(this.__target, this.__properties[i]);
			}
			
			this.__updateFuncs[i](this.__properties[i], this.__startValues[i], this.__endValues[i]);
		}
		
		if (this.__onUpdate != null)
		{
			if (this.__onUpdateArgs != null)
			{
				Reflect.callMethod(this.__onUpdate, this.__onUpdate, this.__onUpdateArgs);
			}
			else
			{
				this.__onUpdate();
			}
		}
		
		if (previousTime < this.__totalTime && this.__currentTime >= this.__totalTime)
		{
			if (this.__repeatCount == 0 || this.__repeatCount > 1)
			{
				this.__currentTime -= this.__repeatDelay;
				this.__currentCycle ++;
				if (this.__repeatCount > 1) this.__repeatCount --;
				if (this.__onRepeat != null)
				{
					if (this.__onRepeatArgs != null)
					{
						Reflect.callMethod(this.__onRepeat, this.__onRepeat, this.__onRepeatArgs);
					}
					else
					{
						this.__onRepeat();
					}
				}
			}
			else
			{
				// save callback & args: they might be changed through an event listener
				var onComplete:Function = this.__onComplete;
				var onCompleteArgs:Array<Dynamic> = this.__onCompleteArgs;
				
				// in the 'onComplete' callback, people might want to call "tween.reset" and
				// add it to another juggler; so this event has to be dispatched *before*
				// executing 'onComplete'.
				JugglerEvent.dispatch(this, JugglerEvent.REMOVE_FROM_JUGGLER);
				if (onComplete != null)
				{
					if (onCompleteArgs != null)
					{
						Reflect.callMethod(onComplete, onComplete, onCompleteArgs);
					}
					else
					{
						onComplete();
					}
				}
				if (this.__currentTime == 0) carryOverTime = 0; // tween was reset
			}
		}
		
		if (carryOverTime != 0) advanceTime(carryOverTime);
	}
	
	// animation hints
	
	private function getUpdateFuncFromProperty(property:String):String->Float->Float->Void
	{
		var hint:String = getPropertyHint(property);
		
		switch (hint)
		{
			case null :
				return updateStandard;
			
			case "rgb" :
				return updateRgb;
			
			case "rad" :
				return updateRad;
			
			case "deg" :
				return updateDeg;
			
			default :
				trace("[Tween] Ignoring unknown property hint: " + hint);
				return updateStandard;
		}
	}
	
	/** @private */
	private static function getPropertyHint(property:String):String
	{
		// colorization is special; it does not require a hint marker, just the word 'color'.
		if (property.indexOf("color") != -1 || property.indexOf("Color") != -1)
		{
			return "rgb";
		}
		
		var hintMarkerIndex:Int = property.indexOf(HINT_MARKER);
		if (hintMarkerIndex != -1) return property.substr(hintMarkerIndex + 1);
		return null;
	}
	
	private static function getPropertyName(property:String):String
	{
		var hintMarkerIndex:Int = property.indexOf(HINT_MARKER);
		if (hintMarkerIndex != -1) return property.substring(0, hintMarkerIndex);
		return property;
	}
	
	private function updateStandard(property:String, startValue:Float, endValue:Float):Void
	{
		var newValue:Float = startValue + this.__progress * (endValue - startValue);
		if (this.__roundToInt) newValue = Math.round(newValue);
		Reflect.setProperty(this.__target, property, newValue);
	}
	
	private function updateRgb(property:String, startValue:Float, endValue:Float):Void
	{
		Reflect.setProperty(this.__target, property, Color.interpolate(Std.int(startValue), Std.int(endValue), this.__progress));
	}
	
	private function updateRad(property:String, startValue:Float, endValue:Float):Void
	{
		updateAngle(Math.PI, property, startValue, endValue);
	}
	
	private function updateDeg(property:String, startValue:Float, endValue:Float):Void
	{
		updateAngle(180, property, startValue, endValue);
	}
	
	private function updateAngle(pi:Float, property:String, startValue:Float, endValue:Float):Void
	{
		while (Math.abs(endValue - startValue) > pi)
		{
			if (startValue < endValue) endValue -= 2.0 * pi;
			else                       endValue += 2.0 * pi;
		}
		updateStandard(property, startValue, endValue);
	}
	
	/** The end value a certain property is animated to. Throws an ArgumentError if the 
	 *  property is not being animated. */
	public function getEndValue(property:String):Float
	{
		var index:Int = this.__properties.indexOf(property);
		if (index == -1) throw new ArgumentError("The property '" + property + "' is not animated");
		return this.__endValues[index];
	}
	
	/** Indicates if a property with the given name is being animated by this tween. */
	public function animatesProperty(property:String):Bool
	{
		return this.__properties.indexOf(property) != -1;
	}
	
	// tween pooling
	
	private static var _POOL:Array<Tween> = new Array<Tween>();
	
	@:allow(juggler.animation.Juggler)
	public static function fromPool(target:Dynamic, time:Float, transition:Dynamic = "linear"):Tween
	{
		if (_POOL.length != 0) return _POOL.pop().reset(target, time, transition);
		return new Tween(target, time, transition);
	}
	
	@:allow(juggler.animation.Juggler)
	private static function toPool(tween:Tween):Void
	{
		tween.clear();
		_POOL[_POOL.length] = tween;
	}
	
}