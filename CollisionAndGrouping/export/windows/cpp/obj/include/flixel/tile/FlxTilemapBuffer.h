#ifndef INCLUDED_flixel_tile_FlxTilemapBuffer
#define INCLUDED_flixel_tile_FlxTilemapBuffer

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxCamera)
HX_DECLARE_CLASS2(flixel,tile,FlxTilemapBuffer)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace tile{


class HXCPP_CLASS_ATTRIBUTES  FlxTilemapBuffer_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTilemapBuffer_obj OBJ_;
		FlxTilemapBuffer_obj();
		Void __construct(int TileWidth,int TileHeight,int WidthInTiles,int HeightInTiles,::flixel::FlxCamera Camera,hx::Null< Float >  __o_ScaleX,hx::Null< Float >  __o_ScaleY);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTilemapBuffer_obj > __new(int TileWidth,int TileHeight,int WidthInTiles,int HeightInTiles,::flixel::FlxCamera Camera,hx::Null< Float >  __o_ScaleX,hx::Null< Float >  __o_ScaleY);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTilemapBuffer_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxTilemapBuffer_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxTilemapBuffer"); }

		Float x;
		Float y;
		Float width;
		Float height;
		bool dirty;
		int rows;
		int columns;
		Dynamic pixelPerfectRender;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void updateColumns( int TileWidth,int WidthInTiles,hx::Null< Float >  ScaleX,::flixel::FlxCamera Camera);
		Dynamic updateColumns_dyn();

		virtual Void updateRows( int TileHeight,int HeightInTiles,hx::Null< Float >  ScaleY,::flixel::FlxCamera Camera);
		Dynamic updateRows_dyn();

		virtual bool isPixelPerfectRender( ::flixel::FlxCamera Camera);
		Dynamic isPixelPerfectRender_dyn();

};

} // end namespace flixel
} // end namespace tile

#endif /* INCLUDED_flixel_tile_FlxTilemapBuffer */ 
