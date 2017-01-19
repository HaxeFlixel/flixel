package flixel.graphics.shaders;

typedef FlxShader =	#if (!openfl_legacy) 
						openfl.display.Shader; 
					#else 
						Dynamic; 
					#end