import nme.Lib;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.display.Graphics;
import nme.events.Event;
//haxelib run nme test "FlixelNME.nmml" flash
class Particle
{
   var x:Float;
   var y:Float;
   var red:Float;
   var green:Float;
   var blue:Float;
   var alpha:Float;
   var angle:Float;
   var size:Float;

   var dx:Float;
   var dy:Float;
   var da:Float;

   public function new()
   {
      x = 320;
      y = 240;
      angle = 0;
      dx = Math.random()*2.0 - 1.0;
      dy = Math.random()*2.0 - 1.0;
      da = Math.random()*0.2 - 0.1;

      red = Math.random();
      green = Math.random();
      blue = Math.random();
      alpha = Math.random();

      size = Math.random()*1.9+0.1;
   }

   public function add(data:Array<Float>)
   {
      data.push(x);
      data.push(y);
      data.push(0);
      data.push(size);
      data.push(angle);
      data.push(red);
      data.push(green);
      data.push(blue);
      data.push(alpha);
   }

   public function move()
   {
      var rad = 30 * size;

      x+=dx;
      if (x<rad)
      {
         x = rad;
         dx = -dx;
      }
      if (x>640-rad)
      {
         x = 640-rad;
         dx = -dx;
      }

      y+=dy;
      if (y<rad)
      {
         y = rad;
         dy = -dy;
      }
      if (y>480-rad)
      {
         y = 480-rad;
         dy = -dy;
      }

      angle += da;
	  
	  red = Math.random();
      green = Math.random();
      blue = Math.random();

   }
}

class Sample extends Sprite
{
   var tid:Int;
   var particles : Array<Particle>;
   var tilesheet : Tilesheet;

   public function new()
   {
      super();

      Lib.current.stage.addChild(this);

      var shape = new nme.display.Shape();
      var gfx = shape.graphics;
      gfx.beginFill(0xffffff);
      gfx.lineStyle(1,0x000000);
      gfx.drawCircle(32,32,30);
      gfx.endFill();
      gfx.moveTo(32,32);
      gfx.lineTo(62,32);
      /*var bmp = new BitmapData(64,64,true,#if neko { rgb:0, a:0 } #else 0x00000000 #end );
      bmp.draw(shape);*/
		
	  var player = Type.createInstance(FlxAssets.imgSpaceman, []).bitmapData;
	  var bmp = new BitmapData(16, 16, true);
	  bmp.copyPixels(player, new nme.geom.Rectangle(16, 16, 16, 16), new nme.geom.Point());
	  
      tilesheet = new Tilesheet(bmp);
      tilesheet.addTileRect( new nme.geom.Rectangle(0,0,16,16), new nme.geom.Point(8,8) );
      tid = 0;

      particles = [];
      for(i in 0...100)
         particles.push( new Particle() );

      stage.addEventListener( Event.ENTER_FRAME, onEnter );
	  
	  trace("did it");
   }

   public function onEnter(e:Event)
   {
      var data = new Array<Float>();
      var flags = Graphics.TILE_SCALE | Graphics.TILE_ROTATION |
                  Graphics.TILE_ALPHA | Graphics.TILE_RGB;
      for(p in particles)
      {
         p.move();
         p.add(data);
      }
      graphics.clear();
      graphics.drawTiles(tilesheet,data,true,flags);
   }

   public static function main()
   {
      new Sample();
   }

}
