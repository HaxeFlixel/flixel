#ifndef INCLUDED_DefaultAssetLibrary
#define INCLUDED_DefaultAssetLibrary

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/AssetLibrary.h>
HX_DECLARE_CLASS0(DefaultAssetLibrary)
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS1(haxe,Timer)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS2(openfl,_v2,AssetLibrary)
HX_DECLARE_CLASS2(openfl,_v2,AssetType)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
HX_DECLARE_CLASS3(openfl,_v2,text,Font)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)


class HXCPP_CLASS_ATTRIBUTES  DefaultAssetLibrary_obj : public ::openfl::_v2::AssetLibrary_obj{
	public:
		typedef ::openfl::_v2::AssetLibrary_obj super;
		typedef DefaultAssetLibrary_obj OBJ_;
		DefaultAssetLibrary_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< DefaultAssetLibrary_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~DefaultAssetLibrary_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("DefaultAssetLibrary"); }

		::haxe::ds::StringMap className;
		::haxe::ds::StringMap path;
		::haxe::ds::StringMap type;
		Float lastModified;
		::haxe::Timer timer;
		virtual bool exists( ::String id,::openfl::_v2::AssetType type);

		virtual ::openfl::_v2::display::BitmapData getBitmapData( ::String id);

		virtual ::openfl::_v2::utils::ByteArray getBytes( ::String id);

		virtual ::openfl::_v2::text::Font getFont( ::String id);

		virtual ::openfl::_v2::media::Sound getMusic( ::String id);

		virtual ::String getPath( ::String id);

		virtual ::openfl::_v2::media::Sound getSound( ::String id);

		virtual ::String getText( ::String id);

		virtual bool isLocal( ::String id,::openfl::_v2::AssetType type);

		virtual Array< ::String > list( ::openfl::_v2::AssetType type);

		virtual Void loadBitmapData( ::String id,Dynamic handler);

		virtual Void loadBytes( ::String id,Dynamic handler);

		virtual Void loadFont( ::String id,Dynamic handler);

		virtual Void loadManifest( );
		Dynamic loadManifest_dyn();

		virtual Void loadMusic( ::String id,Dynamic handler);

		virtual Void loadSound( ::String id,Dynamic handler);

		virtual Void loadText( ::String id,Dynamic handler);

};


#endif /* INCLUDED_DefaultAssetLibrary */ 
