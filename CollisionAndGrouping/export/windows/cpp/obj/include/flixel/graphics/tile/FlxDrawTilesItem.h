#ifndef INCLUDED_flixel_graphics_tile_FlxDrawTilesItem
#define INCLUDED_flixel_graphics_tile_FlxDrawTilesItem

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/tile/FlxDrawBaseItem.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawBaseItem)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawTilesItem)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS3(openfl,_v2,geom,Matrix)
namespace flixel{
namespace graphics{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxDrawTilesItem_obj : public ::flixel::graphics::tile::FlxDrawBaseItem_obj{
	public:
		typedef ::flixel::graphics::tile::FlxDrawBaseItem_obj super;
		typedef FlxDrawTilesItem_obj OBJ_;
		FlxDrawTilesItem_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxDrawTilesItem_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxDrawTilesItem_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxDrawTilesItem"); }

		Array< Float > drawData;
		int position;
		virtual Void reset( );

		virtual Void dispose( );

		virtual Void setDrawData( ::flixel::math::FlxPoint coordinate,Float ID,::openfl::_v2::geom::Matrix matrix,hx::Null< bool >  isColored,hx::Null< int >  color,hx::Null< Float >  alpha);
		Dynamic setDrawData_dyn();

		virtual Void render( ::flixel::FlxCamera camera);

		virtual int get_numTiles( );
		Dynamic get_numTiles_dyn();

		virtual int get_numVertices( );

		virtual int get_numTriangles( );

};

} // end namespace flixel
} // end namespace graphics
} // end namespace tile

#endif /* INCLUDED_flixel_graphics_tile_FlxDrawTilesItem */ 
