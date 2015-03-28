#ifndef INCLUDED_openfl_display_BitmapDataChannel
#define INCLUDED_openfl_display_BitmapDataChannel

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,display,BitmapDataChannel)
namespace openfl{
namespace display{


class HXCPP_CLASS_ATTRIBUTES  BitmapDataChannel_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BitmapDataChannel_obj OBJ_;
		BitmapDataChannel_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BitmapDataChannel_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BitmapDataChannel_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("BitmapDataChannel"); }

		static int ALPHA;
		static int BLUE;
		static int GREEN;
		static int RED;
};

} // end namespace openfl
} // end namespace display

#endif /* INCLUDED_openfl_display_BitmapDataChannel */ 
