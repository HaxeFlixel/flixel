package;

class Main
{
	static public function main()
	{ 
		importFlixel();
	}
	
	macro static function importFlixel()
	{
        haxe.macro.Compiler.include("flixel");
        return haxe.macro.Context.makeExpr(0, haxe.macro.Context.currentPos());
    }
}