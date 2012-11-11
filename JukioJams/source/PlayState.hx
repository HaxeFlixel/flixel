package;
import flash.display.BitmapData;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState
{
	//farts
	public var debug:FlxText;
	
	public var tempo:TempoController;
	
	public var triangles:Triangles;
	
	public var a:FlxGroup;
	public var b:FlxGroup;
	
	public var _oldA:Bool;
	public var _oldB:Bool;
	
	public var mirrored:Bool;

	public var firetext:FireText;
	
	public var glitches:Glitches;

	override public function create():Void
	{
		new Mirror();
		
		tempo = new TempoController(onBeat);
		add(tempo);
		
		triangles = new Triangles();
		add(triangles);

		a = cast(add(new FlxGroup()), FlxGroup);
		_oldA = a.visible;
		addStuff(a,false);
		b = cast(add(new FlxGroup()), FlxGroup);
		b.visible = false;
		_oldB = b.visible;
		addStuff(b, true);
		
		firetext = new FireText();
		add(firetext);
		
		glitches = new Glitches();
		
		FlxG.fullscreen();
		FlxG.mouse.hide();
		
		//farts
		//debug = add(new FlxText(0,0,FlxG.width)) as FlxText;
	}
	
	override public function update():Void
	{
		if(FlxG.keys.justPressed("F"))
		{
			FlxG.fullscreen();
		}
		
		super.update();
		
		//shift drop
		if(FlxG.keys.justPressed("SHIFT"))
		{
			_oldA = a.visible;
			_oldB = b.visible;
			a.visible = b.visible = false;
			FlxG.bgColor = 0x50000000;
			triangles.visible = false;
			glitches.visible = false;
		}
		if(FlxG.keys.justReleased("SHIFT"))
		{
			a.visible = _oldA;
			b.visible = _oldB;
			FlxG.flash(0xffffffff,0.5);
			triangles.visible = true;
			glitches.visible = true;
		}
		
		if (FlxG.keys.P)
		{
			firetext.exists = true;
			firetext.resetText(FireText.FISH);
		}
		else if(FlxG.keys.G)
		{
			firetext.exists = true;
			firetext.resetText(FireText.GAMECITY);
		}
		else if (FlxG.keys.K)
		{
			firetext.exists = true;
			firetext.resetText(FireText.KOZILEK);
		}
		else if (FlxG.keys.M)
		{
			firetext.exists = true;
			firetext.resetText(FireText.MM);
		}
		else if (FlxG.keys.Z)
		{
			firetext.exists = true;
			firetext.resetText(FireText.GUNGOD);
		}
		else
		{
			firetext.exists = false;
		}
		
		//farts
		//debug.text = "BEAT GAP: "+tempo.timing+" ("+int(60/tempo.timing)+"bpm)";
		
		FlxG.flashFramerate = 60;
		FlxG.framerate = 60;
		
		glitches.update();
	}
	
	override public function draw():Void
	{
		super.draw();
		if (!firetext.exists)
		{
			Mirror.flip(FlxG.camera.buffer);
		}
		if (glitches.visible && !firetext.exists)
		{
			glitches.draw();
		}
	}
	
	public function addStuff(Group:FlxGroup, Toggled:Bool):Void
	{
		for (i in 0...150)
		{
			Group.add(new SinThing(Toggled));
		}
	}
	
	public function onBeat():Void
	{
		if(FlxG.keys.SHIFT)
		{
			return;
		}
		
		//basic visibility toggle
		a.visible = !a.visible;
		b.visible = !b.visible;
		
		FlxG.bgColor = Colors.random();

		triangles.onBeat();
		glitches.onBeat();
	}
}