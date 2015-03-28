#ifndef INCLUDED_flixel_graphics_tile_FlxDrawBaseItem
#define INCLUDED_flixel_graphics_tile_FlxDrawBaseItem

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawBaseItem)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxDrawItemType)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace graphics{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxDrawBaseItem_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxDrawBaseItem_obj OBJ_;
		FlxDrawBaseItem_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxDrawBaseItem_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxDrawBaseItem_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxDrawBaseItem"); }

		Dynamic nextTyped;
		::flixel::graphics::tile::FlxDrawBaseItem next;
		::flixel::graphics::FlxGraphic graphics;
		bool antialiasing;
		bool colored;
		int blending;
		::flixel::graphics::tile::FlxDrawItemType type;
		virtual Void reset( );
		Dynamic reset_dyn();

		virtual Void dispose( );
		Dynamic dispose_dyn();

		virtual Void render( ::flixel::FlxCamera camera);
		Dynamic render_dyn();

		virtual int get_numVertices( );
		Dynamic get_numVertices_dyn();

		virtual int get_numTriangles( );
		Dynamic get_numTriangles_dyn();

};

} // end namespace flixel
} // end namespace graphics
} // end namespace tile

#endif /* INCLUDED_flixel_graphics_tile_FlxDrawBaseItem */ 
