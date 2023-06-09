package juggler.event;

import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class JugglerEvent extends Event 
{
	/** Event type for an animated object that requests to be removed from the juggler. */
	public static inline var REMOVE_FROM_JUGGLER:EventType<JugglerEvent> = "removeFromJuggler";
	
	#if !flash
	private static var _POOL:Array<JugglerEvent> = new Array<JugglerEvent>();
	
	private static function fromPool(type:String, bubbles:Bool, cancelable:Bool):JugglerEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, bubbles, cancelable);
		return new JugglerEvent(type, bubbles, cancelable);
	}
	#end
	
	public static function dispatch(dispatcher:IEventDispatcher, type:String, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new JugglerEvent(type, bubbles, cancelable));
		#else
		var event:JugglerEvent = fromPool(type, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) 
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event 
	{
		#if flash
		return new JugglerEvent(this.type, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, bubbles:Bool = false, cancelable:Bool = false):JugglerEvent
	{
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}