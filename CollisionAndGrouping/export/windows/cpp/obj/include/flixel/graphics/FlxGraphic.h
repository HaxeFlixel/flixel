#ifndef INCLUDED_flixel_graphics_FlxGraphic
#define INCLUDED_flixel_graphics_FlxGraphic

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(flixel,graphics,FlxGraphic)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxAtlasFrames)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxEmptyFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrame)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFrameCollectionType)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxFramesCollection)
HX_DECLARE_CLASS3(flixel,graphics,frames,FlxImageFrame)
HX_DECLARE_CLASS3(flixel,graphics,tile,FlxTilesheet)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS2(haxe,ds,BalancedTree)
HX_DECLARE_CLASS2(haxe,ds,EnumValueMap)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,Tilesheet)
namespace flixel{
namespace graphics{


class HXCPP_CLASS_ATTRIBUTES  FlxGraphic_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxGraphic_obj OBJ_;
		FlxGraphic_obj();
		Void __construct(::String Key,::openfl::_v2::display::BitmapData Bitmap,Dynamic Persist);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxGraphic_obj > __new(::String Key,::openfl::_v2::display::BitmapData Bitmap,Dynamic Persist);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxGraphic_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxGraphic"); }

		::String key;
		::openfl::_v2::display::BitmapData bitmap;
		int width;
		int height;
		::String assetsKey;
		::Class assetsClass;
		bool persist;
		bool isDumped;
		::flixel::graphics::tile::FlxTilesheet tilesheet;
		::flixel::graphics::frames::FlxImageFrame imageFrame;
		::flixel::graphics::frames::FlxAtlasFrames atlasFrames;
		::haxe::ds::EnumValueMap frameCollections;
		Array< ::Dynamic > frameCollectionTypes;
		bool unique;
		::flixel::graphics::frames::FlxImageFrame _imageFrame;
		::flixel::graphics::tile::FlxTilesheet _tilesheet;
		int _useCount;
		bool _destroyOnNoUse;
		virtual Void dump( );
		Dynamic dump_dyn();

		virtual Void undump( );
		Dynamic undump_dyn();

		virtual Void onContext( );
		Dynamic onContext_dyn();

		virtual Void onAssetsReload( );
		Dynamic onAssetsReload_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void resetFrameBitmaps( );
		Dynamic resetFrameBitmaps_dyn();

		virtual Void addFrameCollection( ::flixel::graphics::frames::FlxFramesCollection collection);
		Dynamic addFrameCollection_dyn();

		virtual Dynamic getFramesCollections( ::flixel::graphics::frames::FlxFrameCollectionType type);
		Dynamic getFramesCollections_dyn();

		virtual ::flixel::graphics::frames::FlxEmptyFrame getEmptyFrame( ::flixel::math::FlxPoint size);
		Dynamic getEmptyFrame_dyn();

		virtual ::flixel::graphics::tile::FlxTilesheet get_tilesheet( );
		Dynamic get_tilesheet_dyn();

		virtual ::openfl::_v2::display::BitmapData getBitmapFromSystem( );
		Dynamic getBitmapFromSystem_dyn();

		virtual bool get_canBeDumped( );
		Dynamic get_canBeDumped_dyn();

		virtual int get_useCount( );
		Dynamic get_useCount_dyn();

		virtual int set_useCount( int Value);
		Dynamic set_useCount_dyn();

		virtual bool get_destroyOnNoUse( );
		Dynamic get_destroyOnNoUse_dyn();

		virtual bool set_destroyOnNoUse( bool Value);
		Dynamic set_destroyOnNoUse_dyn();

		virtual ::flixel::graphics::frames::FlxImageFrame get_imageFrame( );
		Dynamic get_imageFrame_dyn();

		virtual ::openfl::_v2::display::BitmapData set_bitmap( ::openfl::_v2::display::BitmapData value);
		Dynamic set_bitmap_dyn();

		static bool defaultPersist;
		static ::flixel::graphics::FlxGraphic fromAssetKey( ::String Source,hx::Null< bool >  Unique,::String Key,hx::Null< bool >  Cache);
		static Dynamic fromAssetKey_dyn();

		static ::flixel::graphics::FlxGraphic fromClass( ::Class Source,hx::Null< bool >  Unique,::String Key,hx::Null< bool >  Cache);
		static Dynamic fromClass_dyn();

		static ::flixel::graphics::FlxGraphic fromBitmapData( ::openfl::_v2::display::BitmapData Source,hx::Null< bool >  Unique,::String Key,hx::Null< bool >  Cache);
		static Dynamic fromBitmapData_dyn();

		static ::flixel::graphics::FlxGraphic fromFrame( ::flixel::graphics::frames::FlxFrame Source,hx::Null< bool >  Unique,::String Key);
		static Dynamic fromFrame_dyn();

		static ::flixel::graphics::FlxGraphic fromFrames( ::flixel::graphics::frames::FlxFramesCollection Source,hx::Null< bool >  Unique,::String Key);
		static Dynamic fromFrames_dyn();

		static ::flixel::graphics::FlxGraphic fromGraphic( ::flixel::graphics::FlxGraphic Source,hx::Null< bool >  Unique,::String Key);
		static Dynamic fromGraphic_dyn();

		static ::flixel::graphics::FlxGraphic fromRectangle( int Width,int Height,int Color,hx::Null< bool >  Unique,::String Key);
		static Dynamic fromRectangle_dyn();

		static ::openfl::_v2::display::BitmapData getBitmap( ::openfl::_v2::display::BitmapData Bitmap,hx::Null< bool >  Unique);
		static Dynamic getBitmap_dyn();

		static ::flixel::graphics::FlxGraphic createGraphic( ::openfl::_v2::display::BitmapData Bitmap,::String Key,hx::Null< bool >  Unique,hx::Null< bool >  Cache);
		static Dynamic createGraphic_dyn();

};

} // end namespace flixel
} // end namespace graphics

#endif /* INCLUDED_flixel_graphics_FlxGraphic */ 
