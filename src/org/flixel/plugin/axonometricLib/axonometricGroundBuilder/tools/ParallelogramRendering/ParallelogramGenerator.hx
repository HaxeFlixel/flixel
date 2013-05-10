package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.parallelogramRendering;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
//import org.flixel.*;

/**
 * Genera los puntos con respecto a los angulos dados para la generacion y renderizado de los
 * paralelogramos, que en su conjunto crean el cubo
 * 
 * @author	Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class ParallelogramGenerator 
{
	
	private var tilemapdebug:Bool      = false;		
	private var showboundingboxes:Bool = false;
	private var hideTile:Bool          = false;
	private var showmytiles:Bool 	  = false;
	
	/**
	 * Vector que indica la direccion del primer eje, cuyo modulo es la anchura del azulejo
	 */
	public var AxisA:Point;
	/**
	 * Vector que indica la direccion del segundo eje, cuyo modulo es la altura del azulejo
	 */
	public var AxisB:Point;
	/**
	 * Vector generado de la suma de los ejes A y B
	 */
	public var Generated:Point;
		
	/**
	 * Esquina superior izquierda del cuadro que encierra al azulejo
	 */
	public var UpperLeft:Point;
	/**
	 * Esquina inferior derecha del cuadro que encierra al azulejo
	 */
	public var LowerRight:Point; 
	/**
	 * Esquina superior derecha  del cuadro que encierra al azulejo
	 */
	public var UpperRight:Point;
	/**
	 * Esquina inferior izquierda del cuadro que encierra al azulejo
	 */
	public var LowerLeft:Point;

	
	/**
	 * anchura del cuadro que encierra al azulejo
	 */
	public var Rectanglewidth:Int;
	/**
	 * altura del cuadro que encierra al azulejo
	 */
	public var Rectangleheight:Int;
		
	/**
	 * imagen transformada de los azulejos originales, se utiliza para pintar los azulejos
	 */
	public var ParalelogramTiles:BitmapData;
	
	
	/**
	 * modulo de AxisA
	 */
	public var a:Int;
	/**
	 * modulo de AxisB
	 */
	public var b:Int;
	
	/**
	 * vector unitario de AxisA
	 */
	public var axA:Point;
	/**
	 * vector unitario de AxisB
	 */
	public var axB:Point;
		
		
	/**
	 * Inicializa el generador con las variables de depuración seleccionadas
	 * 
	 * @param	tilemapdebug				permite ver los lados de cada azulejo en forma de lineas pintadas
	 * @param	showboundingboxes			permite ver los cuadros que encierran a cada azulejo
	 * @param	hideTile					esconde la parte gráfica de los azulejos
	 * @param	showmytiles					muestra el mapa de azulejos que utiliza como referencia este generador
	 */		
	public function new(tilemapdebug:Bool= false, showboundingboxes:Bool= false, hideTile:Bool= false,showmytiles:Bool=false  ) {
		this.tilemapdebug 	   = tilemapdebug;
		this.showboundingboxes = showboundingboxes;
		this.hideTile 		   = hideTile ;
		this.showmytiles       = showmytiles ;
	}

	/**
	 * Crea las cordenadas de los nuevos azulejos, asi como su renderizado
	 * 
	 * @param	alpha			primer angulo, medido del eje y negativo (positivo en la trigonometria clásica)
	 * @param	a				distancia del primer eje
	 * @param	beta			segundo angulo, medido del eje generado por alpha
	 * @param	b				distancia del segundo eje
	 * @param	_tiles			mapa de azulejos original
	 * @param	positiveAngle	indica si la inclinacion de los angulos es hacia la izquierda (positivo en nuestro sistema)
	 * @param	rotatetile		indica si se quiere rotar el mapa de azulejos
	 * @param	inverttile		indica si se quiere invertir el mapa de azulejos
	 */				
	public function SetParalelogram(alpha:Float, a:Int, beta:Float, b:Int, _tiles:BitmapData,positiveAngle:Bool=false,rotatetile:Bool = false,inverttile:Bool=false):Void {
		// i learned trig on up y being positive, this just makes mental calculation easier for me
		alpha *= -1;
		beta  *= -1;
					
		axA        = new Point(Math.sin(alpha)        , -Math.cos(alpha)        );
		axB        = new Point(Math.sin(alpha + beta) , -Math.cos(alpha + beta) ); 
		this.a = a;
		this.b = b;
		
		//Paralelogram corners
		AxisA        = new Point(Math.sin(alpha)        * a ,-Math.cos(alpha)        * a);
		AxisB        = new Point(Math.sin(alpha + beta) * b ,-Math.cos(alpha + beta) * b); 
		Generated    = new Point(AxisA.x + AxisB.x          , AxisA.y + AxisB.y         );
		
		UpperLeft  = new Point(  Math.min(Math.min(AxisA.x, AxisB.x), Math.min(Generated.x,0)) ,
										   Math.min(Math.min(AxisA.y, AxisB.y), Math.min(Generated.y,0))  );											
		
		LowerRight = new Point(  Math.max(Math.max(AxisA.x, AxisB.x), Math.max(Generated.x,0)) ,
										   Math.max(Math.max(AxisA.y, AxisB.y), Math.max(Generated.y,0))  );			
		UpperRight = new Point(LowerRight.x,UpperLeft.y);											
		LowerLeft  = new Point(UpperLeft.x,LowerRight.y);
										
										
		Rectanglewidth  = Math.ceil(UpperRight.x - UpperLeft.x)+2;
		Rectangleheight = Math.ceil(LowerLeft.y  - UpperLeft.y)+2;
		
		var r:UInt = Math.floor(_tiles.height/ a);
		var c:UInt = Math.floor(_tiles.width / b);

		var cx:Float = -UpperLeft.x;
		var cy:Float = -UpperLeft.y;
		
		ParalelogramTiles = new BitmapData(Rectanglewidth*c, Rectangleheight*r, true, 0x00000000);								
		if (showmytiles){
			FlxG.stage.addChild(new Bitmap(ParalelogramTiles));
			//FlxG.stage.addChild(new Bitmap(_tiles));
		}
						
		var P:Point = new Point();
		var rec:Rectangle = new Rectangle(0, 0, a, b);						
		var Buffer:BitmapData = new BitmapData(a, b, true, 0xFF000000);
		
		var gfx:Graphics = FlxG.flashGfx;
		
		var Point1:Point= new Point(0,0);
		var Point2:Point= new Point(0,0);
		var Point3:Point= new Point(0,0);
		var Point4:Point= new Point(0,0);

		//temporary solution to the streaching of the tiles
		var temp:Float;
		var unitaryAtoB:Point = new Point(AxisB.x - AxisA.x, AxisB.y - AxisA.y);						
		temp = Math.sqrt(unitaryAtoB.x * unitaryAtoB.x + unitaryAtoB.y * unitaryAtoB.y);
		unitaryAtoB.x = unitaryAtoB.x / temp;
		unitaryAtoB.y = unitaryAtoB.x / temp;
		temp = Math.sqrt(Generated.x * Generated.x + Generated.y * Generated.y);						
		var unitaryG:Point = new Point(Generated.x/temp, Generated.y/temp);

		ParalelogramTiles.lock();
		for ( i in 0 ... 1){ // Weird loop ?
			for ( j in 0 ... c) {
				gfx.clear();
				rec.x = j*a;
				rec.y = i*b;
				cx = -UpperLeft.x+Rectanglewidth*j;
				cy = -UpperLeft.y+Rectangleheight*i;
				Buffer.copyPixels(_tiles, rec, P, null, null, true);
				
				Point1.x = cx               - unitaryG   .x;
				Point1.y = cy 		        - unitaryG   .y;

				Point2.x = cx + AxisA.x     - unitaryAtoB.x;
				Point2.y = cy + AxisA.y     - unitaryAtoB.y;
				
				Point3.x = cx + Generated.x + unitaryG .x;
				Point3.y = cy + Generated.y + unitaryG .y;
				
				Point4.x = cx + AxisB.x     + unitaryAtoB.x;
				Point4.y = cy + AxisB.y     + unitaryAtoB.y;

				if (!hideTile) {
					if (!rotatetile) {
						if(!positiveAngle){
							RenderParallelogram(Buffer,Point1,Point2,Point3,Point4);
						}else {
							RenderParallelogram(Buffer,Point2,Point1,Point4,Point3);
						}
					}else {
						if(!positiveAngle){
							if (!inverttile) {
								RenderParallelogram(Buffer,Point2,Point3,Point4,Point1);
							}else {
								RenderParallelogram(Buffer,Point3,Point2,Point1,Point4);
							}
						}else {
							if (!inverttile) {
								RenderParallelogram(Buffer,Point3,Point2,Point1,Point4);
							}else {
								RenderParallelogram(Buffer,Point2,Point3,Point4,Point1);
							}								
						}
					}
				}
				
				gfx.clear();
				var linesize:Float = 1;															
				if (tilemapdebug) {
					gfx.lineStyle(1,FlxG.RED,linesize);
					gfx.moveTo(cx       , cy);			
					gfx.lineTo(cx + AxisA.x, cy + AxisA.y);						
					gfx.lineStyle(1,FlxG.GREEN,linesize);
					gfx.moveTo(cx       , cy);
					gfx.lineTo(cx + AxisB.x, cy + AxisB.y);									
					gfx.lineStyle(1,FlxG.BLUE,linesize);
					gfx.moveTo(cx + AxisA.x, cy + AxisA.y);
					gfx.lineTo(cx + Generated.x, cy + Generated.y);						
					gfx.moveTo(cx + AxisB.x, cy + AxisB.y);
					gfx.lineTo(cx + Generated.x, cy + Generated.y);												
				}	
				if (showboundingboxes) {
					gfx.lineStyle(1,FlxG.WHITE,linesize);
					gfx.moveTo(cx + UpperLeft .x +0.5, cy + UpperLeft .y +0.5);
					gfx.lineTo(cx + UpperRight.x -1.4, cy + UpperRight.y +1.4);						
					gfx.lineTo(cx + LowerRight.x -1.4, cy + LowerRight.y -1.4);
					gfx.lineTo(cx + LowerLeft .x +0.5, cy + LowerLeft .y -0.5);
					gfx.lineTo(cx + UpperLeft .x +0.5, cy + UpperLeft .y +0.5);						
				}
				ParalelogramTiles.draw(FlxG.flashGfxSprite);
				
			}
		}
		ParalelogramTiles.unlock();				
	}
	
	private function RenderParallelogram(Buffer:BitmapData,P1:Point,P2:Point,P3:Point,P4:Point):Void {

		Skew.transformer(
		   [P1.x  , P1.y]
		   ,
		   [P2.x  , P2.y]
		   ,
		   [P3.x  , P3.y]
		   ,
		   [P4.x  , P4.y]
		   ,
		   Buffer
		   ,
		   FlxG.flashGfxSprite
		   ,
		   30
		   ,
		   15
	   );
	
		ParalelogramTiles.draw(FlxG.flashGfxSprite);						
	}
				
	
	/**
	 * Vector que indica la primera esquina del mapa generado
	 */
	public var BigAxisA:Point;
	/**
	 * Vector que indica la segunda esquina del mapa generado
	 */
	public var BigAxisB:Point;
	/**
	 * Vector que indica la esquina generada del mapa generado
	 */
	public var BigGenerated:Point;
			
	/**
	 * Esquina superior izquierda del cuadro que encierra al mapa
	 */
	public var BigUpperLeft:Point;								
	/**
	 * Esquina inferior derecha del cuadro que encierra al mapa
	 */
	public var BigLowerRight:Point; 
	/**
	 * Esquina superior derecha del cuadro que encierra al mapa
	 */
	public var BigUpperRight:Point;
	/**
	 * Esquina superior izquierda del cuadro que encierra al mapa
	 */
	public var BigLowerLeft:Point;

	/**
	 * Anchura del cuadro que encierra al mapa
	 */
	public var BigRectanglewidth:Float;
	/**
	 * Altura del cuadro que encierra al mapa
	 */
	public var BigRectangleheight:Float;
									 
	
	/**
	 * Crea las cordenadas del mapa generado
	 * 
	 * @param	amountA			cantidad de azulejos en el eje A (columnas)
	 * @param	amountB			cantidad de azulejos en el eje B (filas)
	 */				
	public function setBigParalelogram(amountA:Float, amountB:Float):Void {
		
		BigAxisA     = new Point( axA.x*a * amountA, axA.y*a * amountA);
		BigAxisB     = new Point( axB.x*b * amountB, axB.y*b * amountB);
		
		//BigAxisA     = new Point( AxisA.x * amountA, AxisA.y * amountA);
		//BigAxisB     = new Point( AxisB.x * amountB, AxisB.y * amountB);
		BigGenerated = new Point( BigAxisA.x + BigAxisB.x, BigAxisA.y + BigAxisB.y);
		
		
		BigUpperLeft  = new Point(  Math.min(Math.min(BigAxisA.x, BigAxisB.x), Math.min(BigGenerated.x,0)) ,
									Math.min(Math.min(BigAxisA.y, BigAxisB.y), Math.min(BigGenerated.y,0))  );														
		BigLowerRight = new Point(  Math.max(Math.max(BigAxisA.x, BigAxisB.x), Math.max(BigGenerated.x,0)) ,
									Math.max(Math.max(BigAxisA.y, BigAxisB.y), Math.max(BigGenerated.y,0))  );						
		BigUpperRight = new Point(BigLowerRight.x ,BigUpperLeft .y);
		BigLowerLeft  = new Point(BigUpperLeft .x ,BigLowerRight.y);

		BigRectanglewidth  = BigUpperRight.x - BigUpperLeft.x;
		BigRectangleheight = BigLowerLeft.y  - BigUpperLeft.y;
	}

	/**
	 * Funcion para el depurado, pinta lineas con respecto a los vectores de los azulejos
	 * 
	 * @param	pixels			la imagen en donde se va a pintar
	 */				
	public function DrawBigSiluette(pixels:BitmapData):Void {
		var gfx:Graphics = FlxG.flashGfx;
		var cx:Float = 0;
		var cy:Float = 0;

		if(tilemapdebug){
			//white cross
			gfx.clear();
			gfx.lineStyle(1, FlxG.WHITE, 0.5);
			gfx.moveTo(cx                , cy );
			gfx.lineTo(cx + pixels.width , cy + pixels.height);			
			gfx.moveTo(cx + pixels.width , cy );						
			gfx.lineTo(cx                , cy + pixels.height);
			pixels.draw(FlxG.flashGfxSprite);														
			
			//red cross
			gfx.clear();			
			gfx.lineStyle(1, FlxG.RED, 0.5);
			gfx.moveTo(cx   				  , cy );
			gfx.lineTo(cx + BigRectanglewidth , cy + BigRectangleheight);			
			gfx.moveTo(cx + BigRectanglewidth , cy );
			gfx.lineTo(cx                     , cy + BigRectangleheight);
			pixels.draw(FlxG.flashGfxSprite);

			//siluette
			gfx.clear();
			gfx.lineStyle(1, FlxG.BLUE, 0.5);
			cx= -BigUpperLeft.x;
			cy= -BigUpperLeft.y;
			gfx.moveTo(cx       , cy);
			gfx.lineTo(cx + BigAxisA.x, cy + BigAxisA.y);
			gfx.moveTo(cx       , cy);			
			gfx.lineTo(cx + BigAxisB.x, cy + BigAxisB.y);
			gfx.moveTo(cx + BigAxisA.x     , cy + BigAxisA.y);
			gfx.lineTo(cx + BigGenerated.x , cy + BigGenerated.y);
			gfx.moveTo(cx + BigAxisB.x     , cy + BigAxisB.y);
			gfx.lineTo(cx + BigGenerated.x , cy + BigGenerated.y);
			pixels.draw(FlxG.flashGfxSprite);			
		}
	}
	
	/**
	 * Funcion para la destruccion de objetos ( reciclado)
	 * 
	 */						
	public function destroy():Void {
	
	}
}