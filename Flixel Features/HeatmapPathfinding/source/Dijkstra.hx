// https://gist.github.com/trystan/4968958
package  
import flixel.util.FlxPoint;
{
	public class Dijkstra 
	{
		private var grid:Array;
		private var offsets:Array<Array<Int>> = [[ -1, 0], [0, -1], [0, 1], [1, 0], [ -1, -1], [ -1, 1], [1, -1], [1, 1]];
		
		public function Dijkstra(w:Int, h:Int)
		{
			grid = makeGrid(w, h);
		}
		
		private function makeGrid(w:Int, h:Int):Array<Array<Int>> 
		{
			var grid:Array<Array<Int>> = [];
			for(x in 0...w){
			{
				var row:Array<Int> = [];
				for(y in 0...h){
					row.push(-1);
				}
				grid.push(row);
			}
			return grid;
		}
		
		private function makePath(endNode:FlxPoint):Array<FlxPoint> 
		{
			var path:Array<FlxPoint> = [];
			
			while (grid[endNode.x][endNode.y] != endNode)
			{
				path.push(endNode);
				endNode = grid[endNode.x][endNode.y];
			}
			
			path.push(endNode);
			path.reverse();
			return path;
		}
		
		public function pathTo(start:FlxPoint, canEnter:Int->Int->Bool, check:Int->Int->Bool):Array<FlxPoint>
		{
			var open:Array<FlxPoint> = [new FlxPoint(start.x, start.y)];
			grid[start.x][start.y] = open[0];
			
			while (open.length > 0)
			{
				var current:FlxPoint = open[0];
				open.splice(0, 1);
				
				if (check(current.x, current.y))
				{
					return makePath(current);
				}
				
				//for each (var offset:Array in [[-1,0],[0,-1],[0,1],[1,0],[-1,-1],[-1,1],[1,-1],[1,1]])
				var offset:Array<Int>;
				for (offset in offsets) {
				{
					var neighbor:FlxPoint = new FlxPoint(current.x + offset[0], current.y + offset[1]);
					
					if (neighbor.x < 0 
                                           || neighbor.y < 0 
                                           || neighbor.x >= grid.length 
                                           || neighbor.y >= grid[0].length)
						continue;
						
					if (grid[neighbor.x][neighbor.y] != null)
						continue;
					
					grid[neighbor.x][neighbor.y] = current;
					
					if (check(neighbor.x, neighbor.y))
						return makePath(neighbor);
					
					if (!canEnter(neighbor.x, neighbor.y))
						continue;
					
					open.push(neighbor);
				}
			}
			return [];
		}
		
		public static function pathTo(start:FlxPoint, canEnter:Int->Int->Bool, check:Int->Int->Bool):Array
		{
			return new Dijkstra(80, 60).pathTo(start, canEnter, check);
		}
	}
}