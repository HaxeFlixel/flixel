#ifndef INCLUDED_openfl__v2_display_Graphics
#define INCLUDED_openfl__v2_display_Graphics

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,CapsStyle)
HX_DECLARE_CLASS3(openfl,_v2,display,Graphics)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,IGraphicsData)
HX_DECLARE_CLASS3(openfl,_v2,display,JointStyle)
HX_DECLARE_CLASS3(openfl,_v2,display,LineScaleMode)
HX_DECLARE_CLASS3(openfl,_v2,display,SpreadMethod)
HX_DECLARE_CLASS3(openfl,_v2,display,Tilesheet)
HX_DECLARE_CLASS3(openfl,_v2,display,TriangleCulling)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
HX_DECLARE_CLASS2(openfl,display,GradientType)
HX_DECLARE_CLASS2(openfl,display,GraphicsPathWinding)
HX_DECLARE_CLASS2(openfl,display,InterpolationMethod)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  Graphics_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Graphics_obj OBJ_;
		Graphics_obj();
		Void __construct(Dynamic handle);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Graphics_obj > __new(Dynamic handle);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Graphics_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Graphics"); }

		Dynamic __handle;
		virtual Void arcTo( Float controlX,Float controlY,Float x,Float y);
		Dynamic arcTo_dyn();

		virtual Void beginBitmapFill( ::openfl::_v2::display::BitmapData bitmap,::openfl::_v2::geom::Matrix matrix,hx::Null< bool >  repeat,hx::Null< bool >  smooth);
		Dynamic beginBitmapFill_dyn();

		virtual Void beginFill( int color,hx::Null< Float >  alpha);
		Dynamic beginFill_dyn();

		virtual Void beginGradientFill( ::openfl::display::GradientType type,Dynamic colors,Dynamic alphas,Dynamic ratios,::openfl::_v2::geom::Matrix matrix,::openfl::_v2::display::SpreadMethod spreadMethod,::openfl::display::InterpolationMethod interpolationMethod,hx::Null< Float >  focalPointRatio);
		Dynamic beginGradientFill_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void copyFrom( ::openfl::_v2::display::Graphics sourceGraphics);
		Dynamic copyFrom_dyn();

		virtual Void cubicCurveTo( Float controlX1,Float controlY1,Float controlX2,Float controlY2,Float anchorX,Float anchorY);
		Dynamic cubicCurveTo_dyn();

		virtual Void curveTo( Float controlX,Float controlY,Float anchorX,Float anchorY);
		Dynamic curveTo_dyn();

		virtual Void drawCircle( Float x,Float y,Float radius);
		Dynamic drawCircle_dyn();

		virtual Void drawEllipse( Float x,Float y,Float width,Float height);
		Dynamic drawEllipse_dyn();

		virtual Void drawGraphicsData( Array< ::Dynamic > graphicsData);
		Dynamic drawGraphicsData_dyn();

		virtual Void drawGraphicsDatum( ::openfl::_v2::display::IGraphicsData graphicsDatum);
		Dynamic drawGraphicsDatum_dyn();

		virtual Void drawPoints( Array< Float > xy,Array< int > pointRGBA,hx::Null< int >  defaultRGBA,hx::Null< Float >  size);
		Dynamic drawPoints_dyn();

		virtual Void drawRect( Float x,Float y,Float width,Float height);
		Dynamic drawRect_dyn();

		virtual Void drawRoundRect( Float x,Float y,Float width,Float height,Float radiusX,Dynamic radiusY);
		Dynamic drawRoundRect_dyn();

		virtual Void drawRoundRectComplex( Float x,Float y,Float width,Float height,Float topLeftRadius,Float topRightRadius,Float bottomLeftRadius,Float bottomRightRadius);
		Dynamic drawRoundRectComplex_dyn();

		virtual Void drawPath( Array< int > commands,Array< Float > data,::openfl::display::GraphicsPathWinding winding);
		Dynamic drawPath_dyn();

		virtual Void drawTiles( ::openfl::_v2::display::Tilesheet sheet,Array< Float > data,hx::Null< bool >  smooth,hx::Null< int >  flags,hx::Null< int >  count);
		Dynamic drawTiles_dyn();

		virtual Void drawTriangles( Array< Float > vertices,Array< int > indices,Array< Float > uvtData,::openfl::_v2::display::TriangleCulling culling,Array< int > colors,hx::Null< int >  blendMode);
		Dynamic drawTriangles_dyn();

		virtual Void endFill( );
		Dynamic endFill_dyn();

		virtual Void lineBitmapStyle( ::openfl::_v2::display::BitmapData bitmap,::openfl::_v2::geom::Matrix matrix,hx::Null< bool >  repeat,hx::Null< bool >  smooth);
		Dynamic lineBitmapStyle_dyn();

		virtual Void lineGradientStyle( ::openfl::display::GradientType type,Dynamic colors,Dynamic alphas,Dynamic ratios,::openfl::_v2::geom::Matrix matrix,::openfl::_v2::display::SpreadMethod spreadMethod,::openfl::display::InterpolationMethod interpolationMethod,hx::Null< Float >  focalPointRatio);
		Dynamic lineGradientStyle_dyn();

		virtual Void lineStyle( Dynamic thickness,hx::Null< int >  color,hx::Null< Float >  alpha,hx::Null< bool >  pixelHinting,::openfl::_v2::display::LineScaleMode scaleMode,::openfl::_v2::display::CapsStyle caps,::openfl::_v2::display::JointStyle joints,hx::Null< Float >  miterLimit);
		Dynamic lineStyle_dyn();

		virtual Void lineTo( Float x,Float y);
		Dynamic lineTo_dyn();

		virtual Void moveTo( Float x,Float y);
		Dynamic moveTo_dyn();

		static int TILE_SCALE;
		static int TILE_ROTATION;
		static int TILE_RGB;
		static int TILE_ALPHA;
		static int TILE_TRANS_2x2;
		static int TILE_RECT;
		static int TILE_ORIGIN;
		static int TILE_SMOOTH;
		static int TILE_BLEND_NORMAL;
		static int TILE_BLEND_ADD;
		static int RGBA( int rgb,hx::Null< int >  alpha);
		static Dynamic RGBA_dyn();

		static Dynamic lime_gfx_clear;
		static Dynamic &lime_gfx_clear_dyn() { return lime_gfx_clear;}
		static Dynamic lime_gfx_begin_fill;
		static Dynamic &lime_gfx_begin_fill_dyn() { return lime_gfx_begin_fill;}
		static Dynamic lime_gfx_begin_bitmap_fill;
		static Dynamic &lime_gfx_begin_bitmap_fill_dyn() { return lime_gfx_begin_bitmap_fill;}
		static Dynamic lime_gfx_line_bitmap_fill;
		static Dynamic &lime_gfx_line_bitmap_fill_dyn() { return lime_gfx_line_bitmap_fill;}
		static Dynamic lime_gfx_begin_gradient_fill;
		static Dynamic &lime_gfx_begin_gradient_fill_dyn() { return lime_gfx_begin_gradient_fill;}
		static Dynamic lime_gfx_line_gradient_fill;
		static Dynamic &lime_gfx_line_gradient_fill_dyn() { return lime_gfx_line_gradient_fill;}
		static Dynamic lime_gfx_end_fill;
		static Dynamic &lime_gfx_end_fill_dyn() { return lime_gfx_end_fill;}
		static Dynamic lime_gfx_line_style;
		static Dynamic &lime_gfx_line_style_dyn() { return lime_gfx_line_style;}
		static Dynamic lime_gfx_move_to;
		static Dynamic &lime_gfx_move_to_dyn() { return lime_gfx_move_to;}
		static Dynamic lime_gfx_line_to;
		static Dynamic &lime_gfx_line_to_dyn() { return lime_gfx_line_to;}
		static Dynamic lime_gfx_curve_to;
		static Dynamic &lime_gfx_curve_to_dyn() { return lime_gfx_curve_to;}
		static Dynamic lime_gfx_arc_to;
		static Dynamic &lime_gfx_arc_to_dyn() { return lime_gfx_arc_to;}
		static Dynamic lime_gfx_draw_ellipse;
		static Dynamic &lime_gfx_draw_ellipse_dyn() { return lime_gfx_draw_ellipse;}
		static Dynamic lime_gfx_draw_data;
		static Dynamic &lime_gfx_draw_data_dyn() { return lime_gfx_draw_data;}
		static Dynamic lime_gfx_draw_datum;
		static Dynamic &lime_gfx_draw_datum_dyn() { return lime_gfx_draw_datum;}
		static Dynamic lime_gfx_draw_rect;
		static Dynamic &lime_gfx_draw_rect_dyn() { return lime_gfx_draw_rect;}
		static Dynamic lime_gfx_draw_path;
		static Dynamic &lime_gfx_draw_path_dyn() { return lime_gfx_draw_path;}
		static Dynamic lime_gfx_draw_tiles;
		static Dynamic &lime_gfx_draw_tiles_dyn() { return lime_gfx_draw_tiles;}
		static Dynamic lime_gfx_draw_points;
		static Dynamic &lime_gfx_draw_points_dyn() { return lime_gfx_draw_points;}
		static Dynamic lime_gfx_draw_round_rect;
		static Dynamic &lime_gfx_draw_round_rect_dyn() { return lime_gfx_draw_round_rect;}
		static Dynamic lime_gfx_draw_triangles;
		static Dynamic &lime_gfx_draw_triangles_dyn() { return lime_gfx_draw_triangles;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_Graphics */ 
