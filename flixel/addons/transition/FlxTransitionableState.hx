package flixel.addons.transition;

import flixel.FlxState;
import flixel.FlxSubState;
import BitmapTransition;

class FlxTransitionableState extends FlxState
{
  // global default transitions for ALL states, used if transIn/transOut are null
  public static var defaultTransIn:Class<TransitionSubstate> = null;
  public static var defaultTransOut:Class<TransitionSubstate> = null;

	public static var skipNextTransIn:Bool = false;
	public static var skipNextTransOut:Bool = false;

	// beginning & ending transitions for THIS state:
	public var transIn:Class<TransitionSubstate>;
	public var transOut:Class<TransitionSubstate>;

	public var hasTransIn(get, never):Bool;
	public var hasTransOut(get, never):Bool;

	/**
	 * Create a state with the ability to do visual transitions
	 * @param	TransIn		Plays when the state begins
	 * @param	TransOut	Plays when the state ends
	 */
	public function new(?TransIn:Class<TransitionSubstate>, ?TransOut:Class<TransitionSubstate>)
	{
		transIn = TransIn;
		transOut = TransOut;

		if (transIn == null && defaultTransIn != null)
		{
      trace("in");
			transIn = defaultTransIn;
		}
		if (transOut == null && defaultTransOut != null)
		{
      trace("out");
			transOut = defaultTransOut;
		}

		super();

	}

	override public function destroy():Void
	{
		super.destroy();
		transIn = null;
		transOut = null;
		_onExit = null;
	}

	override public function create():Void
	{
		super.create();
		transitionIn();
	}

	override public function switchTo(nextState:FlxState):Bool
	{
    trace(!hasTransOut, transOutFinished);
		if (!hasTransOut)
			return true;

		if (!_exiting)
			transitionToState(nextState);

		return transOutFinished;
	}

	function transitionToState(nextState:FlxState):Void
	{
		// play the exit transition, and when it's done call FlxG.switchState
		_exiting = true;
		transitionOut(function()
		{
			FlxG.switchState(nextState);
		});

		if (skipNextTransOut)
		{
			skipNextTransOut = false;
			finishTransOut();
		}
	}

	/**
	 * Starts the in-transition. Can be called manually at any time.
	 */
	public function transitionIn():Void
	{
		if (transIn != null)
		{
			if (skipNextTransIn)
			{
				skipNextTransIn = false;
				if (finishTransIn != null)
				{
					finishTransIn();
				}
				return;
			}


      var trans = Type.createInstance(transIn, []);
			openSubState(trans);

      trans.finishCallback = finishTransIn;
			trans.start(OUT);
		}
	}

	/**
	 * Starts the out-transition. Can be called manually at any time.
	 */
	public function transitionOut(?OnExit:Void->Void):Void
	{
		_onExit = OnExit;
		if (hasTransOut)
		{
      var trans = Type.createInstance(transOut, []);
			openSubState(trans);

      trans.finishCallback = finishTransOut;
			trans.start(IN);
		}
		else
		{
			_onExit();
		}
	}

	var transOutFinished:Bool = false;

	var _exiting:Bool = false;
	var _onExit:Void->Void;

	function get_hasTransIn():Bool
	{
		return transIn != null;
	}

	function get_hasTransOut():Bool
	{
		return transOut != null;
	}

	function finishTransIn()
	{
		closeSubState();
	}

	function finishTransOut()
	{
		transOutFinished = true;

		if (!_exiting)
		{
			closeSubState();
		}

		if (_onExit != null)
		{
			_onExit();
		}
	}
}