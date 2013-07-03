package flixel.addons.tile;

/**
 * This class uses the cellular automata algorithm
 * to generate very sexy caves.
 * (Coded by Eddie Lee, October 16, 2010)
 */
class FlxCaveGenerator
{
	/**
	 * How many times do you want to "smooth" the cave.
	 * The higher number the smoother.
	 */ 
	static public var numSmoothingIterations:Int = 6;
	
	/**
	 * During initial state, how percent of matrix are walls?
	 * The closer the value is to 1.0, more wall-e the area is
	 */
	static public var initWallRatio:Float = 0.5;
	
	private var _numTilesCols:Int;
	private var _numTilesRows:Int;
	
	/**
	 * @param	Columns		Number of columns in the cave tilemap
	 * @param	Rows		Number of rows in the cave tilemap
	 */
	public function new(Columns:Int = 10, Rows:Int = 10) 
	{
		_numTilesCols = Columns;
		_numTilesRows = Rows;
	}
	
	/**
	 * @param 	Matrix		A matrix of data
	 * @return 	A string that is usuable for <code>FlxTileMap.loadMap()</code>
	 */
	static public function convertMatrixToStr(Matrix:Array<Array<Int>>):String
	{
		var mapString:String = "";
		
		for (y in 0...(Matrix.length))
		{
			for (x in 0...(Matrix[y].length))
			{
				mapString += Std.string(Matrix[y][x]) + ",";
			}
			
			mapString += "\n";
		}
		
		return mapString;
	}
	
	/**
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
	
	/**
	 * 
	 * @param	Rows		Number of rows for the matrix
	 * @param	Columns 	Number of cols for the matrix
	 * @return 	Spits out a matrix that is cols x rows, zero initiated
	 */
	private function genInitMatrix(Rows:Int, Columns:Int):Array<Array<Int>>
	{
		// Build array of 1s
		var mat:Array<Array<Int>> = new Array<Array<Int>>();
		
		for (y in 0...(Rows))
		{
			mat.push(new Array<Int>());
			
			for (x in 0...(Columns)) 
			{
				mat[y].push(0);
			}
		}
		
		return mat;
	}
	
	/**
	 * @param	Matrix		Matrix of data (0 = empty, 1 = wall)
	 * @param	PosX		Column we are examining
	 * @param	PosY		Row we are exampining
	 * @param	Distance	Radius of how far to check for neighbors
	 * @return	Number of walls around the target, including itself
	 */
	private function countNumWallsNeighbors(Matrix:Array<Array<Int>>, PosX:Int, PosY:Int, Distance:Int = 1):Int
	{
		var count:Int = 0;
		
		for (y in ( -Distance)...(Distance + 1))
		{
			for (x in ( -Distance)...(Distance + 1))
			{
				// Boundary
				if ((PosX + x < 0) || (PosX + x > _numTilesCols - 1) || (PosY + y < 0) || (PosY + y > _numTilesRows - 1))
				{
					continue;
				}
				
				// Neighbor is non-wall
				if (Matrix[PosY + y][PosX + x] != 0) 
				{
					count++;
				}
			}
		}
		
		return count;
	}
	
	/**
	 * Use the 4-5 rule to smooth cells
	 */
	private function runCelluarAutomata(InMatrix:Array<Array<Int>>, OutMatrix:Array<Array<Int>>):Void
	{
		var numRows:Int = InMatrix.length;
		var numCols:Int = InMatrix[0].length;
		
		for (y in 0...(numRows))
		{
			for (x in 0...(numCols))
			{
				var numWalls:Int = countNumWallsNeighbors(InMatrix, x, y, 1);
				
				if (numWalls >= 5) 
				{
					OutMatrix[y][x] = 1;
				}
				else 
				{
					OutMatrix[y][x] = 0;
				}
			}
		}
	}
}