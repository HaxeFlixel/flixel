import flash.text.TextField;			
import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
	
class Main extends Sprite
{
	public var tf:TextField; 
   
	public function new()
	{
		super ();		

		//This is where to do your own stuff:
		_entryPoint();
	}

	
   /*********PRIVATE***********/    
   
	private function _entryPoint():Void {		
		var game = new GameClass();
		stage.addChild(game);
	}		
}
