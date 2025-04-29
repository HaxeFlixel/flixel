package flixel.effects;

import flixel.FlxSprite;
import flixel.math.FlxMatrix;

/**
 * A sprite that uses a `renderMatrix` to transform its rendering
 */
class FlxMatrixSprite extends FlxSprite
{
	/**
	 * The matrix used to transform how this sprite is rendered
	 * 
	 * @since 6.2.0
	 */
	public final renderMatrix:FlxMatrix;
	
	public function new (x = 0.0, y = 0.0, simpleGraphic)
	{
		renderMatrix = new FlxSpriteMatrixTransform(this);
		
		super(x, y, simpleGraphic);
	}
	
	override function isSimpleRenderBlit()
	{
		return isSimpleRenderBlit() || matrix.isIdentity();
	}
	
	override function getDrawComplexMatrix(matrix:FlxMatrix, frame:FlxFrame, camera:FlxCamera)
	{
		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);
		
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			
			if (angle != 0)
				matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		
		matrix.concat(renderMatrix);
		
		final screenPos = getScreenPosition(camera).subtract(offset);
		screenPos.add(origin.x, origin.y);
		matrix.translate(screenPos.x, screenPos.y);
		screenPos.put();
		
		if (isPixelPerfectRender(camera))
		{
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}
	}
}