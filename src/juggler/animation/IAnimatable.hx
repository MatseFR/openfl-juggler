package juggler.animation;

/**
 * @author Matse
 */
interface IAnimatable 
{
	/** Advance the time by a number of seconds. @param time in seconds. */
	function advanceTime(time:Float):Void;
}