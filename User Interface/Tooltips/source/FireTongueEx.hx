import firetongue.FireTongue;
import flixel.addons.ui.interfaces.IFireTongue;

/**
 * This is a simple wrapper class to solve a dilemma:
 * 
 * I don't want flixel-ui to depend on firetongue
 * I don't want firetongue to depend on flixel-ui
 * 
 * I can solve this by using an interface, IFireTongue, in flixel-ui
 * However, that interface has to go in one namespace or the other and if I put
 * it in firetongue, then there's a dependency. And vice-versa.
 * 
 * This is solved by making a simple wrapper class in the actual project
 * code that includes both libraries. 
 * 
 * The wrapper extends FireTongue, and implements IFireTongue
 * 
 * The actual extended class does nothing, it just falls through to FireTongue.
 * 
 * @author 
 */
class FireTongueEx extends FireTongue implements IFireTongue
{

	public function new() 
	{
		super();
	}
	
}