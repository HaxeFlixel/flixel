#ifndef INCLUDED_flixel_graphics_tile_FlxDrawTrianglesItem
#define INCLUDED_flixel_graphics_tile_FlxDrawTrianglesItem

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/graphics/tile/FlxDrawBaseItem.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawBaseItem)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawTrianglesItem)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace graphics{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxDrawTrianglesItem_obj : public ::flixel::graphics::tile::FlxDrawBaseItem_obj{
	public:
		typedef ::flixel::graphics::tile::FlxDrawBaseItem_obj super;
		typedef FlxDrawTrianglesItem_obj OBJ_;
		FlxDrawTrianglesItem_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxDrawTrianglesItem_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxDrawTrianglesItem_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxDrawTrianglesItem"); }

		Array< Float > vertices;
		Array< int > indices;
		Array< Float > uvt;
		Array< int > colors;
		virtual Void render( ::flixel::FlxCamera camera);

		virtual Void reset( );

		virtual Void dispose( );

		virtual int get_numVertices( );

		virtual int get_numTriangles( );

};

} // end namespace flixel
} // end namespace graphics
} // end namespace tile

#endif /* INCLUDED_flixel_graphics_tile_FlxDrawTrianglesItem */ 
