#ifndef INCLUDED_openfl__v2_display_Tilesheet
#define INCLUDED_openfl__v2_display_Tilesheet

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,Graphics)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,Tilesheet)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace openfl{
namespace _v2{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  Tilesheet_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Tilesheet_obj OBJ_;
		Tilesheet_obj();
		Void __construct(::openfl::_v2::display::BitmapData image);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Tilesheet_obj > __new(::openfl::_v2::display::BitmapData image);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Tilesheet_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Tilesheet"); }

		::openfl::_v2::display::BitmapData __bitmap;
		Dynamic __handle;
		int _bitmapHeight;
		int _bitmapWidth;
		Array< ::Dynamic > _tilePoints;
		Array< ::Dynamic > _tiles;
		Array< ::Dynamic > _tileUVs;
		virtual int addTileRect( ::openfl::_v2::geom::Rectangle rectangle,::openfl::_v2::geom::Point centerPoint);
		Dynamic addTileRect_dyn();

		virtual Void drawTiles( ::openfl::_v2::display::Graphics graphics,Array< Float > tileData,hx::Null< bool >  smooth,hx::Null< int >  flags,hx::Null< int >  count);
		Dynamic drawTiles_dyn();

		virtual ::openfl::_v2::geom::Point getTileCenter( int index);
		Dynamic getTileCenter_dyn();

		virtual ::openfl::_v2::geom::Rectangle getTileRect( int index);
		Dynamic getTileRect_dyn();

		virtual ::openfl::_v2::geom::Rectangle getTileUVs( int index);
		Dynamic getTileUVs_dyn();

		static int TILE_SCALE;
		static int TILE_ROTATION;
		static int TILE_RGB;
		static int TILE_ALPHA;
		static int TILE_TRANS_2x2;
		static int TILE_RECT;
		static int TILE_ORIGIN;
		static int TILE_BLEND_NORMAL;
		static int TILE_BLEND_ADD;
		static int TILE_BLEND_MULTIPLY;
		static int TILE_BLEND_SCREEN;
		static ::openfl::_v2::geom::Point defaultRatio;
		static Dynamic lime_tilesheet_create;
		static Dynamic &lime_tilesheet_create_dyn() { return lime_tilesheet_create;}
		static Dynamic lime_tilesheet_add_rect;
		static Dynamic &lime_tilesheet_add_rect_dyn() { return lime_tilesheet_add_rect;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace display

#endif /* INCLUDED_openfl__v2_display_Tilesheet */ 
