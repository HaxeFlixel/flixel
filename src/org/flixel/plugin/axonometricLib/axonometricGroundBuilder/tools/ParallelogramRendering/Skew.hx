package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.parallelogramRendering;

import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.display.Graphics;


/**
 * 
 * @author Jimmy Delas (Haxe port)
 */
class Skew {
	
	static public function transformer(pa:Array<Dynamic>,pb:Array<Dynamic>,pc:Array<Dynamic>,pd:Array<Dynamic>,bd:BitmapData,cont:Dynamic,AAh:UInt,AAv:UInt):Void {
		var bW:UInt = bd.width;
		var bH:UInt = bd.height;
		var inMat:Matrix = new Matrix();
		var outMat:Matrix = new Matrix();
		outMat.a = ((pb[0]-pa[0])/bW);
		outMat.b = (pb[1]-pa[1])/bW;
		outMat.c = (pd[0]-pa[0])/bH;
		outMat.d = ((pd[1]-pa[1])/bH);
		outMat.tx = pa[0];
		outMat.ty = pa[1];
		cont.graphics.beginBitmapFill(bd,outMat,true,true);
		cont.graphics.moveTo(pa[0],pa[1]);
		cont.graphics.lineTo(pb[0],pb[1]);
		cont.graphics.lineTo(pd[0],pd[1]);
		cont.graphics.lineTo(pa[0],pa[1]);
		cont.graphics.endFill();
		outMat.a = ((pc[0]-pd[0])/bW);
		outMat.b = (pc[1]-pd[1])/bW;
		outMat.c = (pc[0]-pb[0])/bH;
		outMat.d = ((pc[1]-pb[1])/bH);
		outMat.tx = pd[0];
		outMat.ty = pd[1];
		cont.graphics.beginBitmapFill(bd,outMat,true,true);
		cont.graphics.moveTo(pc[0],pc[1]);
		cont.graphics.lineTo(pd[0],pd[1]);
		cont.graphics.lineTo(pb[0],pb[1]);
		cont.graphics.lineTo(pc[0],pc[1]);
		cont.graphics.endFill();
	}
}
