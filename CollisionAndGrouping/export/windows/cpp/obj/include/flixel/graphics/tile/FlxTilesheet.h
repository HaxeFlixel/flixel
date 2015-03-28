#ifndef INCLUDED_flixel_graphics_tile_FlxTilesheet
#define INCLUDED_flixel_graphics_tile_FlxTilesheet

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/Tilesheet.h>
#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxTilesheet)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,Tilesheet)
HX_DECLARE_CLASS3(openfl,_v2,geom,Point)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
namespace flixel{
namespace graphics{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxTilesheet_obj : public ::openfl::_v2::display::Tilesheet_obj{
	public:
		typedef ::openfl::_v2::display::Tilesheet_obj super;
		typedef FlxTilesheet_obj OBJ_;
		FlxTilesheet_obj();
		Void __construct(::openfl::_v2::display::BitmapData bitmap);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTilesheet_obj > __new(::openfl::_v2::display::BitmapData bitmap);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTilesheet_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxTilesheet_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxTilesheet"); }

		Array< ::Dynamic > tileOrder;
		virtual int addTileRect( ::openfl::_v2::geom::Rectangle rectangle,::openfl::_v2::geom::Point centerPoint);

		virtual Void destroy( );
		Dynamic destroy_dyn();

		static int _DRAWCALLS;
		static ::flixel::graphics::tile::FlxTilesheet rebuildFromOld( ::flixel::graphics::tile::FlxTilesheet old,::openfl::_v2::display::BitmapData bitmap);
		static Dynamic rebuildFromOld_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace tile

#endif /* INCLUDED_flixel_graphics_tile_FlxTilesheet */ 
