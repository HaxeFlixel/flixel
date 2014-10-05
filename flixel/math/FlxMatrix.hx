package flixel.math;

//A copy of flash Matrix, only with the needed feature.
class FlxMatrix {

    public var a:Float;
    public var b:Float;
    public var c:Float;
    public var d:Float;
    public var tx:Float;
    public var ty:Float;

    public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0) {

        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;
        this.tx = tx;
        this.ty = ty;

    } //new

    public function identity() {

        a = 1;
        b = 0;
        c = 0;
        d = 1;
        tx = 0;
        ty = 0;

    } //identity

    public function translate (x:Float, y:Float):Void {

        tx += x;
        ty += y;

    } //translate

    public function compose( Position: FlxPoint, Rotation:Float, Scale:FlxPoint ) {
		
        identity();

        scale( Scale.x, Scale.y );
        rotate( Rotation );
        makeTranslation( Position.x, Position.y );

    } //compose

    public function makeTranslation( X:Float, Y:Float ) : Void {

        tx += X;
        ty += Y;

    } //makeTranslation

    public function rotate (angle:Float):Void {

		angle = angle * Math.PI / 180;
		
        var cos = Math.cos (angle);
        var sin = Math.sin (angle);

        var a1 = a * cos - b * sin;
            b = a * sin + b * cos;
            a = a1;

        var c1 = c * cos - d * sin;
            d = c * sin + d * cos;
            c = c1;

        var tx1 = tx * cos - ty * sin;
            ty = tx * sin + ty * cos;
            tx = tx1;

    } //rotate

    public function scale (x:Float, y:Float):Void {

        a *= x;
        b *= y;

        c *= x;
        d *= y;

        tx *= x;
        ty *= y;

    } //scale

    public function toString ():String {

        return "(a=" + a + ", b=" + b + ", c=" + c + ", d=" + d + ", tx=" + tx + ", ty=" + ty + ")";

    } //toString
	
	public function transformPoint (Point : FlxPoint) : FlxPoint {
		var x1 = Point.x;
		Point.x = Point.x * a + Point.y * b + tx;
		Point.y = x1 * c + Point.y * d + ty;
		
		return Point;
	}

} //Matrix