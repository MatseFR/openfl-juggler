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
import juggler.animation.IAnimatable;
import juggler.event.JugglerEvent;
import openfl.events.EventDispatcher;

/** A DelayedCall allows you to execute a method after a certain time has passed. Since it 
 *  implements the IAnimatable interface, it can be added to a juggler. In most cases, you 
 *  do not have to use this class directly; the juggler class contains a method to delay
 *  calls directly. 
 * 
 *  <p>DelayedCall dispatches an Event of type 'Event.REMOVE_FROM_JUGGLER' when it is finished,
 *  so that the juggler automatically removes it when its no longer needed.</p>
 * 
 *  @see Juggler
 */ 
@:access(openfl.events.EventDispatcher)
class DelayedCall extends EventDispatcher implements IAnimatable
{
	// delayed call pooling
	
	private static var _POOL:Array<DelayedCall> = new Array<DelayedCall>();
	
	@:allow(juggler.animation.Juggler)
	private static function fromPool(call:Function, delay:Float, args:Array<Dynamic> = null):DelayedCall
	{
		if (_POOL.length != 0) return _POOL.pop().reset(call, delay, args);
		return new DelayedCall(call, delay, args);
	}
	
	@:allow(juggler.animation.Juggler)
	private static function toPool(delayedCall:DelayedCall):Void
	{
		// reset any object-references, to make sure we don't prevent any garbage collection
		delayedCall.__callback = null;
		delayedCall.__args = null;
		#if !flash
		delayedCall.__removeAllListeners(); // not too sure about this
		#end
		_POOL[_POOL.length] = delayedCall;
	}
	
	/** Indicates if enough time has passed, and the call has already been executed. */
	public var isComplete(get, never):Bool;
	private function get_isComplete():Bool 
	{ 
		return this.__repeatCount == 1 && this.__currentTime >= this.__totalTime; 
	}
	
	/** The time for which calls will be delayed (in seconds). */
	public var totalTime(get, never):Float;
	private function get_totalTime():Float { return this.__totalTime; }
	
	/** The time that has already passed (in seconds). */
	public var currentTime(get, never):Float;
	private function get_currentTime():Float { return this.__currentTime; }
	
	/** The number of times the call will be repeated. 
	 * Set to '0' to repeat indefinitely. @default 1 */
	public var repeatCount(get, set):Int;
	private function get_repeatCount():Int { return this.__repeatCount; }
	private function set_repeatCount(value:Int):Int
	{
		return this.__repeatCount = value;
	}
	
	/** The callback that will be executed when the time is up. */
	public var callback(get, never):Function;
	private function get_callback():Function { return this.__callback; }
	
	/** The arguments that the callback will be executed with.
	 *  Beware: not a copy, but the actual object! */
	public var arguments(get, never):Array<Dynamic>;
	private function get_arguments():Array<Dynamic> { return this.__args; }
	
	private var __currentTime:Float;
	private var __totalTime:Float;
	@:allow(juggler.animation.Juggler)
	private var __callback:Function;
	private var __args:Array<Dynamic>;
	private var __repeatCount:Int;

	public function new(callback:Function, delay:Float, args:Array<Dynamic> = null) 
	{
		super();
		reset(callback, delay, args);
	}
	
	/** Resets the delayed call to its default values, which is useful for pooling. */
	public function reset(callback:Function, delay:Float, args:Array<Dynamic> = null):DelayedCall
	{
		this.__currentTime = 0;
		this.__totalTime = Math.max(delay, 0.0001);
		this.__callback = callback;
		this.__args = args;
		this.__repeatCount = 1;
		
		return this;
	}
	
	public function advanceTime(time:Float):Void
	{
		var previousTime:Float = this.__currentTime;
		this.__currentTime += time;
		
		// this code has no effect
		//if (this.__currentTime > this.__totalTime)
		//{
			//this.__currentTime = this.__totalTime;
		//}
		
		if (previousTime < this.__totalTime && this.__currentTime >= this.__totalTime)
		{                
			if (this.__repeatCount == 0 || this.__repeatCount > 1)
			{
				Reflect.callMethod(this.__callback, this.__callback, this.__args);
				
				if (this.__repeatCount != 0) this.__repeatCount -= 1;
				this.__currentTime = 0;
				advanceTime((previousTime + time) - this.__totalTime);
			}
			else
			{
				// save call & args: they might be changed through an event listener
				var call:Function = __callback;
				var args:Array<Dynamic> = __args;
				
				// in the callback, people might want to call "reset" and re-add it to the
				// juggler; so this event has to be dispatched *before* executing 'call'.
				JugglerEvent.dispatch(this, JugglerEvent.REMOVE_FROM_JUGGLER);
				Reflect.callMethod(call, call, args);
			}
		}
	}
	
	/** Advances the delayed call so that it is executed right away. If 'repeatCount' is
	  * anything else than '1', this method will complete only the current iteration. */
	public function complete():Void
	{
		var restTime:Float = this.__totalTime - this.__currentTime;
		if (restTime > 0) advanceTime(restTime);
	}
	
}