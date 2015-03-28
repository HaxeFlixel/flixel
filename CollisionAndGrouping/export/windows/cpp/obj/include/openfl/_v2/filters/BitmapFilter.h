#ifndef INCLUDED_openfl__v2_filters_BitmapFilter
#define INCLUDED_openfl__v2_filters_BitmapFilter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,filters,BitmapFilter)
namespace openfl{
namespace _v2{
namespace filters{


class HXCPP_CLASS_ATTRIBUTES  BitmapFilter_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BitmapFilter_obj OBJ_;
		BitmapFilter_obj();
		Void __construct(::String __o_type);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BitmapFilter_obj > __new(::String __o_type);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BitmapFilter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BitmapFilter"); }

		::String type;
		virtual ::openfl::_v2::filters::BitmapFilter clone( );
		Dynamic clone_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace filters

#endif /* INCLUDED_openfl__v2_filters_BitmapFilter */ 
