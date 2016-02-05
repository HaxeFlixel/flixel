package;

import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.geom.Rectangle;
import flash.Vector;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;

/**
 * @author Masadow
 */
class Grid
{
	#if !js
	public var springs:Array<Spring>;
	public var points:Array<PointMass>;
	public var fixedPoints:Array<PointMass>;
	private var numColumns:Int;
	private var numRows:Int;
	private var majorGridSize:Int;
	private var _pt:FlxPoint;
	
	private var lineCommands:Vector<Int>;
	private var lineData:Vector<Float>;
	private var useDrawPath:Bool = true;
	private var renderGrid:Bool = true;
	
	public function new(GridRectangle:Rectangle, NumColumns:Int, NumRows:Int, MajorGridSize:Int = 4)
	{
		_pt = FlxPoint.get();
		springs = [];
		numColumns = NumColumns;
		numRows = NumRows;
		majorGridSize = MajorGridSize;
		var _n:UInt = (numColumns + 1) * (numRows + 1);
		
		var _index:UInt;
		lineCommands = new Vector<Int>(2 * (1 + numColumns) * (1 + numRows), true);
		lineData = new Vector<Float>(2 * lineCommands.length, true);
		for (_y in 0...numRows + 1)
		{
			for (_x in 0...numColumns + 1)
			{
				_index = _y * (numColumns + 1) + _x;
				if (_x == 0) lineCommands[_index] = cast GraphicsPathCommand.MOVE_TO;
				else lineCommands[_index] = cast GraphicsPathCommand.LINE_TO;
				
				lineData[2 * _index] = _x * (FlxG.width / numColumns);
				lineData[2 * _index + 1] = _y * (FlxG.height / numRows);
			}
		}
		
		for (_x in 0...numColumns + 1)
		{
			for (_y in 0...numRows + 1)
			{
				_index = _x * (numRows + 1) + _y;
				if (_y == 0) lineCommands[_index + _n] = cast GraphicsPathCommand.MOVE_TO;
				else lineCommands[_index + _n] = cast GraphicsPathCommand.LINE_TO;
				
				lineData[2 * _index + 2 * _n] = _x * (FlxG.width / numColumns);
				lineData[2 * _index + 2 * _n + 1] = _y * (FlxG.height / numRows);
			}
		}
			
		points= [];
		// these fixed pointswill be used to anchor the grid to fixed positions on the screen
		fixedPoints = [];
		
		// create the poInt masses
		var _cellWidth:Float = GridRectangle.width / numColumns;
		var _cellHeight:Float = GridRectangle.height / numRows;
		for (_y in 0...numRows + 1)
		{
			for (_x in 0...numColumns + 1)
			{
				var _xx:Float = GridRectangle.left + _x * _cellWidth;
				var _yy:Float = GridRectangle.top + _y * _cellHeight;
				points.push(new PointMass(_xx, _yy, 1));
				fixedPoints.push(new PointMass(_xx, _yy, 1));
			}
		}
		
		// link the poInt masses with springs
		for (_y in 0...numRows + 1)
		{
			for (_x in 0...numColumns + 1)
			{ 
				_index = _y * (numColumns + 1) + _x;
				if (_x == 0 || _y == 0 || _x == numColumns || _y == numRows) // anchor the border of the grid 
					springs.push(new Spring(fixedPoints[_index], points[_index], 0.9, 0.9)); 
				else if (_x % 4 == 0 && _y % 4 == 0) // loosely anchor 1/16th of the poInt masses 
					springs.push(new Spring(fixedPoints[_index], points[_index], 0.02, 0.2));
				
				var _stiffness:Float = 0.95;//0.28;
				var _damping:Float = 0.12;//0.06;
				if (_x < numColumns)
					springs.push(new Spring(points[_index + 1], points[_index], _stiffness, _damping));
				if (_y < numRows)
					springs.push(new Spring(points[_index + (numColumns + 1)], points[_index], _stiffness, _damping));
			}
		}
		//springs = springList.concat();
	}
	
	public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.P) useDrawPath = !useDrawPath;
		if (FlxG.keys.justPressed.U) renderGrid = !renderGrid;
		
		for (spring in springs) spring.update(elapsed);
		for (mass in points) mass.update(elapsed);
		
		if (useDrawPath)
		{
			var _n:UInt = (numColumns + 1) * (numRows + 1);
			var _index:UInt;
			var _indexTranspose:UInt;
			for (_y in 0...numRows)
			{
				for (_x in 0...numColumns)
				{
					_index = _y * (numColumns + 1) + _x;
					_indexTranspose = _x * (numRows + 1) + _y;
					
					_pt = cast(points[_index], PointMass).position;
					
					lineData[2 * _index] = _pt.x;
					lineData[2 * _index + 1] = _pt.y;
					
					lineData[2 * _indexTranspose + 2 * _n] = _pt.x;
					lineData[2 * _indexTranspose + 2 * _n + 1] = _pt.y;
				}
			}
		}
	}
	
	public function draw():Void
	{
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();
		
		//Cache line to bitmap
		var _thickness:UInt;
		var _color:UInt = 0x01034f;
		var _index:UInt;
		var _upperLeftX:Float;
		var _upperLeftY:Float;
		var _upperRightX:Float;
		var _upperRightY:Float;
		var _lowerLeftX:Float;
		var _lowerLeftY:Float;
		var _lowerRightX:Float;
		var _lowerRightY:Float;
		
		gfx.lineStyle(1, _color);
		if (renderGrid) gfx.drawPath(lineCommands, lineData);
	}
	
	public function applyDirectedForce(Position:FlxPoint, Force:FlxPoint, Radius:Float):Void
	{
		var _distance:Float;
		for (_mass in points)
		{
			_distance = Position.distanceTo(_mass.position);
			if (_distance < Radius) _mass.applyForce(10 * Force.x / (10 + _distance), 10 * Force.y / (10 + _distance));
		}
	}
	
	public function applyImplosiveForce(Position:FlxPoint, Force:Float, Radius:Float):Void
	{
		var _distance:Float;
		for (_mass in points)
		{
			_distance = Position.distanceTo(_mass.position);
			if (_distance < Radius)
			{
				_mass.applyForce(
						10 * Force * (Position.x - _mass.position.x) / (100 + _distance * _distance), 
						10 * Force * (Position.y - _mass.position.y) / (100 + _distance * _distance));
				_mass.increaseDamping(0.6);
			}
		}
	}
	
	public function applyExplosiveForce(Position:FlxPoint, Force:Float, Radius:Float):Void
	{
		var _distance:Float;
		for (_mass in points)
		{
			_distance = Position.distanceTo(_mass.position);
			if (_distance < Radius)
			{
				_mass.applyForce(
						100 * Force * (_mass.position.x - Position.x) / (10000 + _distance * _distance),
						100 * Force * (_mass.position.y - Position.y) / (10000 + _distance * _distance));
				_mass.increaseDamping(0.6);
			}
		}
	}
	
	/* 
	* Calculates 2D cubic Catmull-Rom spline.
	* @see http://www.mvps.org/directx/articles/catmull/ 
	*/ 
	public function spline(Pt0:FlxPoint, Pt1:FlxPoint, Pt2:FlxPoint, Pt3:FlxPoint, t:Float):FlxPoint 
	{
			_pt.x = 0.5 * ((2 * Pt1.x) + t * ((-Pt0.x + Pt2.x) +
							t * ((2 * Pt0.x - 5 * Pt1.x + 4 * Pt2.x - Pt3.x) + t * (-Pt0.x + 3 * Pt1.x - 3 * Pt2.x + Pt3.x))));
			_pt.y = 0.5 * ((2 * Pt1.y) + t * (( -Pt0.y + Pt2.y) +
							t * ((2 * Pt0.y - 5 * Pt1.y + 4 * Pt2.y - Pt3.y) + t * (-Pt0.y + 3 * Pt1.y - 3 * Pt2.y + Pt3.y))));
			return _pt;                        
	}
	#end
}