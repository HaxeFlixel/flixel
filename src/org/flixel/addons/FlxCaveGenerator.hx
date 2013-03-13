package org.flixel.addons;

/**
 * This class uses the cellular automata algorithm
 * to generate very sexy caves.
 * (Coded by Eddie Lee, October 16, 2010)
 */
class FlxCaveGenerator
{
	private var _numTilesCols:Int;
	private var _numTilesRows:Int;
	
	/**
	 * How many times do you want to "smooth" the cave.
	 * The higher number the smoother.
	 */ 
	public static var numSmoothingIterations:Int = 6;
	
	/**
	 * During initial state, how percent of matrix are walls?
	 * The closer the value is to 1.0, more wall-e the area is
	 */
	public static var initWallRatio:Float = 0.5;
	
	/**
	 * 
	 * @param	nCols	Number of columns in the cave tilemap
	 * @param	nRows	Number of rows in the cave tilemap
	 */
	public function new(nCols:Int = 10, nRows:Int = 10) 
	{
		_numTilesCols = nCols;
		_numTilesRows = nRows;
	}
	
	/**
	 * @param 	mat		A matrix of data
	 * 
	 * @return 	A string that is usuable for FlxTileMap.loadMap(...)
	 */
	static public function convertMatrixToStr(mat:Array<Array<Int>>):String
	{
		var mapString:String = "";
		
		for (y in 0...(mat.length))
		{
			for (x in 0...(mat[y].length))
			{
				mapString += Std.string(mat[y][x]) + ",";
			}
			
			mapString += "\n";
		}
		
		return mapString;
	}
	
	/**
	 * 
	 * @param	rows 	Number of rows for the matrix
	 * @param	cols	Number of cols for the matrix
	 * 
	 * @return Spits out a matrix that is cols x rows, zero initiated
	 */
	private function genInitMatrix(rows:Int, cols:Int):Array<Array<Int>>
	{
		// Build array of 1s
		var mat:Array<Array<Int>> = new Array<Array<Int>>();
		for (y in 0...(rows))
		{
			mat.push(new Array<Int>());
			for (x in 0...(cols)) 
			{
				mat[y].push(0);
			}
		}
		
		return mat;
	}
	
	/**
	 * 
	 * @param	mat		Matrix of data (0=empty, 1 = wall)
	 * @param	xPos	Column we are examining
	 * @param	yPos	Row we are exampining
	 * @param	dist	Radius of how far to check for neighbors
	 * 
	 * @return	Number of walls around the target, including itself
	 */
	private function countNumWallsNeighbors(mat:Array<Array<Int>>, xPos:Int, yPos:Int, dist:Int = 1):Int
	{
		var count:Int = 0;
		
		for (y in (-dist)...(dist + 1))
		{
			for (x in (-dist)...(dist + 1))
			{
				// Boundary
				if ((xPos + x < 0) || (xPos + x > _numTilesCols - 1) || (yPos + y < 0) || (yPos + y > _numTilesRows - 1)) continue;
				
				// Neighbor is non-wall
				if (mat[yPos + y][xPos + x] != 0) ++count;
			}
		}
		
		return count;
	}
	
	/**
	 * Use the 4-5 rule to smooth cells
	 */
	private function runCelluarAutomata(inMat:Array<Array<Int>>, outMat:Array<Array<Int>>):Void
	{
		var numRows:Int = inMat.length;
		var numCols:Int = inMat[0].length;
		
		for (y in 0...(numRows))
		{
			for (x in 0...(numCols))
			{
				var numWalls:Int = countNumWallsNeighbors(inMat, x, y, 1);
				
				if (numWalls >= 5) outMat[y][x] = 1;
				else outMat[y][x] = 0;
			}
		}
	}
	
	/**
	 * 
	 * @return Returns a matrix of a cave!
	 */
	public function generateCaveLevel():Array<Array<Int>>
	{
		// Initialize random array
		var mat:Array<Array<Int>> = genInitMatrix(_numTilesRows, _numTilesCols);
		for (y in 0...(_numTilesRows))
		{
			for (x in 0...(_numTilesCols)) 
			{
				mat[y][x] = (Math.random() < initWallRatio ? 1 : 0);
			}
		}
	
		// Secondary buffer
		var mat2:Array<Array<Int>> = genInitMatrix(_numTilesRows, _numTilesCols);
		
		// Run automata
		for (i in 0...(numSmoothingIterations))
		{
			runCelluarAutomata(mat, mat2);
			
			// Swap
			var temp:Array<Array<Int>> = mat;
			mat = mat2;
			mat2 = temp;
		}
		
		return mat;
	}
}