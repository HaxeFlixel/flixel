package flixel.system.debug;

import flixel.FlxG;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class ScrollSprite extends Sprite
{
	public var maxScrollY(get, never):Float;
	inline function get_maxScrollY():Float return this.height - scroll.height;
	
	public var viewHeight(get, never):Float;
	inline function get_viewHeight():Float return scroll.height;
	
	/**
	 * The current amount of scrolling
	 */
	public var scrollY(get, set):Float;
	inline function get_scrollY():Float return scroll.y;
	inline function set_scrollY(value):Float
	{
		scroll.y = value;
		updateScroll();
		return scroll.y;
	}
	
	var scroll = new Rectangle();
	var scrollBar:ScrollBar = null;
	
	public function new ()
	{
		super();
		
		addEventListener(Event.ADDED_TO_STAGE, function (e)
		{
			final stage = this.stage;
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
			addEventListener(Event.REMOVED_FROM_STAGE, (_)->stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll));
		});
	}
	
	public function createScrollBar()
	{
		return scrollBar = new ScrollBar(this);
	}
	
	function onMouseScroll(e:MouseEvent)
	{
		if (mouseX > 0 && mouseX < scroll.width && mouseY - scroll.y > 0 && mouseY - scroll.y < scroll.height)
		{
			scroll.y -= e.delta;
			updateScroll();
		}
	}
	
	public function setScrollSize(width:Float, height:Float)
	{
		scroll.width = width;
		scroll.height = height;
		
		updateScroll();
	}
	
	function updateScroll()
	{
		scrollRect = null;
		
		if (scroll.bottom > this.height)
			scroll.y = height - scroll.height;
		
		if (scroll.y < 0)
			scroll.y = 0;
		
		scrollRect = scroll;
		
		if (scrollBar != null)
			scrollBar.onViewChange();
	}
	
	override function addChild(child)
	{
		super.addChild(child);
		updateScroll();
		return child;
	}
	
	public function isChildVisible(child:DisplayObject)
	{
		if (getChildIndex(child) == -1)
			throw "Invalid child, not a child of this container";
		
		return child.y < scroll.bottom && child.y + child.height > scroll.y;
	}
}

@:allow(flixel.system.debug.ScrollSprite)
class ScrollBar extends Sprite
{
	static inline final WIDTH = 10;
	
	final target:ScrollSprite;
	
	final handle = new Sprite();
	final bg = new Sprite();
	
	var state:ScrollState = IDLE;
	
	public function new (target:ScrollSprite)
	{
		this.target = target;
		super();
		
		bg.mouseChildren = true;
		bg.mouseEnabled = true;
		bg.graphics.beginFill(0xFFFFFF, 0.1);
		bg.graphics.drawRect(0, 0, WIDTH, 1);
		bg.graphics.endFill();
		addChild(bg);
		
		handle.mouseChildren = true;
		handle.mouseEnabled = true;
		handle.buttonMode = true;
		handle.graphics.beginFill(0xFFFFFF, 0.3);
		handle.graphics.drawRect(0, 0, WIDTH, 1);
		handle.graphics.endFill();
		addChild(handle);
		
		function onAdded(_)
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			final stage = this.stage;
			
			bg.addEventListener(MouseEvent.MOUSE_DOWN, onBgMouseDown);
			handle.addEventListener(MouseEvent.MOUSE_DOWN, onHandleMouse);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onHandleMouse);
			
			function onRemoved(_)
			{
				removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
				
				bg.removeEventListener(MouseEvent.MOUSE_DOWN, onBgMouseDown);
				handle.removeEventListener(MouseEvent.MOUSE_DOWN, onHandleMouse);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onHandleMouse);
			}
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	function onBgMouseDown(e:MouseEvent)
	{
		if (state != IDLE)
			throw "expected state: IDLE";
		
		state = DRAG_BG;
		mouseMoveHelper(e.stageY);
	}
	
	function onHandleMouse(e:MouseEvent)
	{
		if (e.type == MouseEvent.MOUSE_DOWN)
		{
			if (state != IDLE)
				throw "expected state: IDLE";
			
			state = DRAG_HANDLE(getLocalY(e.stageY) - handle.y);
		}
		else
			state = IDLE;
	}
	
	function onMouseMove(e:MouseEvent)
	{
		mouseMoveHelper(e.stageY);
	}
	
	function getLocalY(stageY:Float)
	{
		return globalToLocal(new Point (0, stageY)).y;
	}
	
	function mouseMoveHelper(stageY:Float)
	{
		final localY = getLocalY(stageY);
		switch state
		{
			case IDLE:
			case DRAG_HANDLE(offsetY):
				handle.y = localY - offsetY;
				onHandleMove();
			case DRAG_BG:
				handle.y = localY - handle.height / 2;
				onHandleMove();
		}
	}
	
	function onHandleMove()
	{
		if (handle.y < 0)
			handle.y = 0;
		
		if (handle.y > bg.height - handle.height)
			handle.y = bg.height - handle.height;
		
		target.scrollY = handle.y / (bg.height - handle.height) * target.maxScrollY;
	}
	
	public function resize(height:Float)
	{
		bg.height = height;
		handle.height = height / target.height * target.viewHeight;
		onViewChange();
	}
	
	function onViewChange()
	{
		mouseEnabled = mouseChildren = visible = target.maxScrollY > 0 && target.maxScrollY < target.height;
		handle.y = (target.scrollY / target.maxScrollY) * (bg.height - handle.height);
	}
}

private enum ScrollState
{
	IDLE;
	DRAG_HANDLE(offsetY:Float);
	DRAG_BG;
}