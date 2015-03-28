#ifndef INCLUDED_flixel_tile_FlxTile
#define INCLUDED_flixel_tile_FlxTile

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/FlxObject.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS2(flixel,tile,FlxBaseTilemap)
HX_DECLARE_CLASS2(flixel,tile,FlxTile)
HX_DECLARE_CLASS2(flixel,tile,FlxTilemap)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxTile_obj : public ::flixel::FlxObject_obj{
	public:
		typedef ::flixel::FlxObject_obj super;
		typedef FlxTile_obj OBJ_;
		FlxTile_obj();
		Void __construct(::flixel::tile::FlxTilemap Tilemap,int Index,Float Width,Float Height,bool Visible,int AllowCollisions);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTile_obj > __new(::flixel::tile::FlxTilemap Tilemap,int Index,Float Width,Float Height,bool Visible,int AllowCollisions);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTile_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTile"); }

		Dynamic callbackFunction;
		Dynamic &callbackFunction_dyn() { return callbackFunction;}
		::Class filter;
		::flixel::tile::FlxTilemap tilemap;
		int index;
		int mapIndex;
		::flixel::graphics::frames::FlxFrame frame;
		virtual Void destroy( );

};

} // end namespace flixel
} // end namespace tile

#endif /* INCLUDED_flixel_tile_FlxTile */ 
