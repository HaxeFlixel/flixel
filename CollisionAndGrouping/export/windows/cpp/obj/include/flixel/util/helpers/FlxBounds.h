#ifndef INCLUDED_flixel_util_helpers_FlxBounds
#define INCLUDED_flixel_util_helpers_FlxBounds

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,util,helpers,FlxBounds)
namespace flixel{
namespace util{
namespace helpers{


class HXCPP_CLASS_ATTRIBUTES  FlxBounds_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxBounds_obj OBJ_;
		FlxBounds_obj();
		Void __construct(Dynamic min,Dynamic max);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBounds_obj > __new(Dynamic min,Dynamic max);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBounds_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxBounds"); }

		Dynamic min;
		Dynamic max;
		bool active;
		virtual ::flixel::util::helpers::FlxBounds set( Dynamic min,Dynamic max);
		Dynamic set_dyn();

		virtual bool equals( ::flixel::util::helpers::FlxBounds OtherFlxBounds);
		Dynamic equals_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace flixel
} // end namespace util
} // end namespace helpers

#endif /* INCLUDED_flixel_util_helpers_FlxBounds */ 
