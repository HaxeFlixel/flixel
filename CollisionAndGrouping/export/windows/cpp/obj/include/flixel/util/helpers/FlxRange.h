#ifndef INCLUDED_flixel_util_helpers_FlxRange
#define INCLUDED_flixel_util_helpers_FlxRange

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,util,helpers,FlxRange)
namespace flixel{
namespace util{
namespace helpers{


class HXCPP_CLASS_ATTRIBUTES  FlxRange_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxRange_obj OBJ_;
		FlxRange_obj();
		Void __construct(Dynamic start,Dynamic end);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxRange_obj > __new(Dynamic start,Dynamic end);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxRange_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxRange"); }

		Dynamic start;
		Dynamic end;
		bool active;
		virtual ::flixel::util::helpers::FlxRange set( Dynamic start,Dynamic end);
		Dynamic set_dyn();

		virtual bool equals( ::flixel::util::helpers::FlxRange OtherFlxRange);
		Dynamic equals_dyn();

		virtual ::String toString( );
		Dynamic toString_dyn();

};

} // end namespace flixel
} // end namespace util
} // end namespace helpers

#endif /* INCLUDED_flixel_util_helpers_FlxRange */ 
