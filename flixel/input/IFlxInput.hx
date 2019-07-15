package flixel.input;

interface IFlxInput
{
	var justReleased(get, never):Bool;
	var released(get, never):Bool;
	var pressed(get, never):Bool;
	var justPressed(get, never):Bool;
}
