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
import juggler.animation.DelayedCall;
import juggler.animation.IAnimatable;
import juggler.animation.Tween;
import juggler.event.JugglerEvent;
import openfl.Lib;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * Basically a copy of Starling's Juggler but requires a call to Juggler.start()
 */
class Juggler implements IAnimatable
{
	public static var root(default, null):Juggler = new Juggler();
	
	public static var isStarted(get, never):Bool;
	private static function get_isStarted():Bool { return __isStarted; }
	
	private static var __isStarted:Bool;
	private static var __timeStamp:Float;
	
	private static var sCurrentObjectID:Int = 0;
	private static var sTweenInstanceFields:Array<String>;
	
	public static function start():Void
	{
		if (__isStarted) return;
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, __rootEnterFrame);
		__timeStamp = Lib.getTimer() / 1000.0;
		__isStarted = true;
	}
	
	public static function stop():Void
	{
		if (!__isStarted) return;
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, __rootEnterFrame);
		__isStarted = false;
	}
	
	private static function __rootEnterFrame(evt:Event):Void
	{
		var now:Float = Lib.getTimer() / 1000.0;
		var passedTime:Float = now - __timeStamp;
		__timeStamp = now;
		
		// to avoid overloading time-based animations, the maximum delta is truncated.
        if (passedTime > 1.0) passedTime = 1.0;
		
        // after about 25 days, 'getTimer()' will roll over. A rare event, but still ...
        if (passedTime < 0.0) passedTime = 1.0 / Lib.current.stage.frameRate;
		
		//trace("passedTime " + passedTime);
		
		root.advanceTime(passedTime);
	}
	
	private static function getNextID():Int { return ++sCurrentObjectID; }
	
	public var elapsedTime(get, never):Float;
	private function get_elapsedTime():Float { return this.__elapsedTime; }
	
	public var objects(get, never):Array<IAnimatable>;
	private function get_objects():Array<IAnimatable> { return this.__objects; }
	
	public var timeScale(get, set):Float;
	private function get_timeScale():Float { return this.__timeScale; }
	private function set_timeScale(value:Float):Float
	{
		return this.__timeScale = value;
	}
	
	private var __objects:Array<IAnimatable>;
	private var __objectIDs:Map<IAnimatable, Int>;
	private var __idToObject:Map<Int, IAnimatable>;
	private var __elapsedTime:Float;
	private var __timeScale:Float;

	public function new() 
	{
		this.__elapsedTime = 0;
		this.__timeScale = 1.0;
		this.__objects = new Array<IAnimatable>();
		this.__objectIDs = new Map<IAnimatable, Int>();
		this.__idToObject = new Map<Int, IAnimatable>();
	}
	
	/** Adds an object to the juggler.
     *
     *  @return Unique numeric identifier for the animation. This identifier may be used
     *          to remove the object via <code>removeByID()</code>.
     */
	public function add(object:IAnimatable):Int
	{
		return addWithID(object, getNextID());
	}
	
	public function addWithID(object:IAnimatable, objectID:Int):Int
	{
		if (object != null && !this.__objectIDs.exists(object))
		{
			var dispatcher:EventDispatcher = Std.isOfType(object, EventDispatcher) ? cast object : null;
			if (dispatcher != null) dispatcher.addEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onRemove);
			
			this.__objects[this.__objects.length] = object;
			this.__objectIDs[object] = objectID;
			this.__idToObject[objectID] = object;
			
			return objectID;
		}
		else return 0;
	}
	
	/** Determines if an object has been added to the juggler. */
	public function contains(object:IAnimatable):Bool
	{
		return this.__objectIDs.exists(object);
	}
	
	/** Removes an object from the juggler.
     *
     *  @return The (now meaningless) unique numeric identifier for the animation, or zero
     *          if the object was not found.
     */
	public function remove(object:IAnimatable):Int
	{
		var objectID:Int = 0;
		
		if (object != null && this.__objectIDs.exists(object))
		{
			var dispatcher:EventDispatcher = Std.isOfType(object, EventDispatcher) ? cast object : null;
			if (dispatcher != null) dispatcher.removeEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onRemove);
			
			var index:Int = this.__objects.indexOf(object);
			this.__objects[index] = null;
			
			objectID = this.__objectIDs[object];
			this.__objectIDs.remove(object);
			this.__idToObject.remove(objectID);
		}
		
		return objectID;
	}
	
	/** Removes an object from the juggler, identified by the unique numeric identifier you
     *  received when adding it.
     *
     *  <p>It's not uncommon that an animatable object is added to a juggler repeatedly,
     *  e.g. when using an object-pool. Thus, when using the <code>remove</code> method,
     *  you might accidentally remove an object that has changed its context. By using
     *  <code>removeByID</code> instead, you can be sure to avoid that, since the objectID
     *  will always be unique.</p>
     *
     *  @return if successful, the passed objectID; if the object was not found, zero.
     */
	public function removeByID(objectID:Int):Int
	{
		if (this.__idToObject.exists(objectID))
		{
			return remove(this.__idToObject[objectID]);
		}
		return 0;
	}
	
	/** Removes all tweens with a certain target. */
	public function removeTweens(target:Dynamic):Void
	{
		if (target == null) return;
		
		var tween:Tween;
		var id:Int;
		var i:Int = this.__objects.length - 1;
		while (i != -1)
		{
			if (Std.isOfType(this.__objects[i], Tween))
			{
				tween = cast this.__objects[i];
				if (tween.target == target)
				{
					tween.removeEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onRemove);
					this.__objects[i] = null;
					id = this.__objectIDs[tween];
					this.__objectIDs.remove(tween);
					this.__idToObject.remove(id);
				}
			}
			--i;
		}
	}
	
	/** Removes all delayed and repeated calls with a certain callback. */
	public function removeDelayedCalls(callback:Function):Void
	{
		if (callback == null) return;
		
		var delayedCall:DelayedCall;
		var id:Int;
		var i:Int = this.__objects.length - 1;
		while (i != -1)
		{
			if (Std.isOfType(this.__objects[i], DelayedCall))
			{
				delayedCall = cast this.__objects[i];
				if (delayedCall.__callback == callback)
				{
					delayedCall.removeEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onRemove);
					this.__objects[i] = null;
					id = this.__objectIDs[delayedCall];
					this.__objectIDs.remove(delayedCall);
					this.__idToObject.remove(id);
				}
			}
			--i;
		}
	}
	
	/** Figures out if the juggler contains one or more tweens with a certain target. */
	public function containsTweens(target:Dynamic):Bool
	{
		if (target != null)
		{
			var tween:Tween;
			var i:Int = this.__objects.length;
			while (i >= 0)
			{
				if (Std.isOfType(this.__objects[i], Tween))
				{
					tween = cast this.__objects[i];
					if (tween.target == target) return true;
				}
				--i;
			}
		}
		
		return false;
	}
	
	/** Figures out if the juggler contains one or more delayed calls with a certain callback. */
	public function containsDelayedCalls(callback:Function):Bool
	{
		if (callback != null)
		{
			var delayedCall:DelayedCall;
			var i:Int = this.__objects.length - 1;
			while (i >= 0)
			{
				if (Std.isOfType(this.__objects[i], DelayedCall))
				{
					delayedCall = cast this.__objects[i];
					if (delayedCall.__callback == callback) return true;
				}
				--i;
			}
		}
		
		return false;
	}
	
	/** Removes all objects at once. */
	public function purge():Void
	{
		// the object vector is not purged right away, because if this method is called 
		// from an 'advanceTime' call, this would make the loop crash. Instead, the
		// vector is filled with 'null' values. They will be cleaned up on the next call
		// to 'advanceTime'.
		
		var object:IAnimatable, dispatcher:EventDispatcher, id:Int;
		var i:Int = this.__objects.length - 1;
		while (i >= 0)
		{
			object = this.__objects[i];
			if (object != null)
			{
				if (Std.isOfType(object, EventDispatcher))
				{
					dispatcher = cast object;
					dispatcher.removeEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onRemove);
				}
				this.__objects[i] = null;
				id = this.__objectIDs[object];
				this.__objectIDs.remove(object);
				this.__idToObject.remove(id);
			}
			--i;
		}
	}
	
	/** Delays the execution of a function until <code>delay</code> seconds have passed.
	 *  This method provides a convenient alternative for creating and adding a DelayedCall
	 *  manually.
	 *
	 *  @return Unique numeric identifier for the delayed call. This identifier may be used
	 *          to remove the object via <code>removeByID()</code>.
	 */
	public function delayCall(call:Function, delay:Float, args:Array<Dynamic> = null):Int
	{
		if (call == null) throw new ArgumentError("call must not be null");
		if (args == null) args = [];
		
		var delayedCall:DelayedCall = DelayedCall.fromPool(call, delay, args);
		delayedCall.addEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onPooledDelayedCallComplete);
		return add(delayedCall);
	}
	
	/** Runs a function at a specified interval (in seconds). A 'repeatCount' of zero
	 *  means that it runs indefinitely.
	 *
	 *  @return Unique numeric identifier for the delayed call. This identifier may be used
	 *          to remove the object via <code>removeByID()</code>.
	 */
	public function repeatCall(call:Function, interval:Float, repeatCount:Int = 0, args:Array<Dynamic> = null):Int
	{
		if (call == null) throw new ArgumentError("call must not be null");
		if (args == null) args = [];
		
		var delayedCall:DelayedCall = DelayedCall.fromPool(call, interval, args);
		delayedCall.repeatCount = repeatCount;
		delayedCall.addEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onPooledDelayedCallComplete);
		return add(delayedCall);
	}
	
	private function onPooledDelayedCallComplete(evt:JugglerEvent):Void
	{
		DelayedCall.toPool(cast evt.target);
	}
	
	/** Utilizes a tween to animate the target object over <code>time</code> seconds. Internally,
	 *  this method uses a tween instance (taken from an object pool) that is added to the
	 *  juggler right away. This method provides a convenient alternative for creating 
	 *  and adding a tween manually.
	 *  
	 *  <p>Fill 'properties' with key-value pairs that describe both the 
	 *  tween and the animation target. Here is an example:</p>
	 *  
	 *  <pre>
	 *  juggler.tween(object, 2.0, {
	 *      transition: Transitions.EASE_IN_OUT,
	 *      delay: 20, // -> tween.delay = 20
	 *      x: 50      // -> tween.animate("x", 50)
	 *  });
	 *  </pre> 
	 *
	 *  <p>To cancel the tween, call 'Juggler.removeTweens' with the same target, or pass
	 *  the returned ID to 'Juggler.removeByID()'.</p>
	 *
	 *  <p>Note that some property types may be animated in a special way:</p>
	 *  <ul>
	 *    <li>If the property contains the string <code>color</code> or <code>Color</code>,
	 *        it will be treated as an unsigned integer with a color value
	 *        (e.g. <code>0xff0000</code> for red). Each color channel will be animated
	 *        individually.</li>
	 *    <li>The same happens if you append the string <code>#rgb</code> to the name.</li>
	 *    <li>If you append <code>#rad</code>, the property is treated as an angle in radians,
	 *        making sure it always uses the shortest possible arc for the rotation.</li>
	 *    <li>The string <code>#deg</code> does the same for angles in degrees.</li>
	 *  </ul>
	 */
	public function tween(target:Dynamic, time:Float, properties:Dynamic):Int
	{
		if (target == null) throw new ArgumentError("target must not be null");
		
		var tween:Tween = Tween.fromPool(target, time);
		var value:Dynamic;
		
		if (sTweenInstanceFields == null) sTweenInstanceFields = Type.getInstanceFields(Tween);
		
		for (property in Reflect.fields(properties))
		{
			value = Reflect.field(properties, property);
			
			if (sTweenInstanceFields.indexOf("set_" + property) != -1)
			{
				Reflect.setProperty(tween, property, value);
			}
			else if (Reflect.hasField(target, property) || Reflect.getProperty(target, property) != null)
			{
				tween.animate(property, value);
			}
			else
			{
				throw new ArgumentError("Invalid property: " + property);
			}
		}
		
		tween.addEventListener(JugglerEvent.REMOVE_FROM_JUGGLER, onPooledTweenComplete);
		return add(tween);
	}
	
	private function onPooledTweenComplete(evt:JugglerEvent):Void
	{
		Tween.toPool(cast evt.target);
	}
	
	/** Advances all objects by a certain time (in seconds). */
	public function advanceTime(time:Float):Void
	{
		var numObjects:Int = this.__objects.length;
		var currentIndex:Int = 0;
		var i:Int = 0;
		
		this.__elapsedTime += time;
		time *= this.__timeScale;
		
		if (numObjects == 0 || time == 0) return;
		
		// there is a high probability that the "advanceTime" function modifies the list 
        // of animatables. we must not process new objects right now (they will be processed
        // in the next frame), and we need to clean up any empty slots in the list.
		
		var object:IAnimatable;
		while (i < numObjects)
		{
			object = this.__objects[i];
			if (object != null)
			{
				// shift objects into empty slots along the way
                if (currentIndex != i) 
                {
                    this.__objects[currentIndex] = object;
                    this.__objects[i] = null;
                }
				
				object.advanceTime(time);
				++currentIndex;
			}
			++i;
		}
		
		if (currentIndex != i)
		{
			numObjects = this.__objects.length; // count might have changed!
			while (i < numObjects)
			{
				this.__objects[currentIndex++] = this.__objects[i++];
			}
			this.__objects.resize(currentIndex);
		}
	}
	
	private function onRemove(evt:JugglerEvent):Void
	{
		var objectID:Int = remove(cast evt.target);
		
		if (objectID != 0)
		{
			if (Std.isOfType(evt.target, Tween))
			{
				var tween:Tween = cast evt.target;
				if (tween.isComplete)
				{
					addWithID(tween.nextTween, objectID);
				}
			}
		}
	}
	
}