#ifndef INCLUDED_openfl__v2_AssetCache
#define INCLUDED_openfl__v2_AssetCache

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/IAssetCache.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
HX_DECLARE_CLASS2(openfl,_v2,AssetCache)
HX_DECLARE_CLASS2(openfl,_v2,IAssetCache)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,media,Sound)
HX_DECLARE_CLASS3(openfl,_v2,text,Font)
namespace openfl{
namespace _v2{


class HXCPP_CLASS_ATTRIBUTES  AssetCache_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef AssetCache_obj OBJ_;
		AssetCache_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< AssetCache_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~AssetCache_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::openfl::_v2::IAssetCache_obj *()
			{ return new ::openfl::_v2::IAssetCache_delegate_< AssetCache_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("AssetCache"); }

		::haxe::ds::StringMap bitmapData;
		::haxe::ds::StringMap font;
		::haxe::ds::StringMap sound;
		bool __enabled;
		virtual Void clear( ::String prefix);
		Dynamic clear_dyn();

		virtual ::openfl::_v2::display::BitmapData getBitmapData( ::String id);
		Dynamic getBitmapData_dyn();

		virtual ::openfl::_v2::text::Font getFont( ::String id);
		Dynamic getFont_dyn();

		virtual ::openfl::_v2::media::Sound getSound( ::String id);
		Dynamic getSound_dyn();

		virtual bool hasBitmapData( ::String id);
		Dynamic hasBitmapData_dyn();

		virtual bool hasFont( ::String id);
		Dynamic hasFont_dyn();

		virtual bool hasSound( ::String id);
		Dynamic hasSound_dyn();

		virtual bool removeBitmapData( ::String id);
		Dynamic removeBitmapData_dyn();

		virtual bool removeFont( ::String id);
		Dynamic removeFont_dyn();

		virtual bool removeSound( ::String id);
		Dynamic removeSound_dyn();

		virtual Void setBitmapData( ::String id,::openfl::_v2::display::BitmapData bitmapData);
		Dynamic setBitmapData_dyn();

		virtual Void setFont( ::String id,::openfl::_v2::text::Font font);
		Dynamic setFont_dyn();

		virtual Void setSound( ::String id,::openfl::_v2::media::Sound sound);
		Dynamic setSound_dyn();

		virtual bool get_enabled( );
		Dynamic get_enabled_dyn();

		virtual bool set_enabled( bool value);
		Dynamic set_enabled_dyn();

};

} // end namespace openfl
} // end namespace _v2

#endif /* INCLUDED_openfl__v2_AssetCache */ 
