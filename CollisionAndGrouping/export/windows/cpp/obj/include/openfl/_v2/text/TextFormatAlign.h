#ifndef INCLUDED_openfl__v2_text_TextFormatAlign
#define INCLUDED_openfl__v2_text_TextFormatAlign

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,text,TextFormatAlign)
namespace openfl{
namespace _v2{
namespace text{


class HXCPP_CLASS_ATTRIBUTES  TextFormatAlign_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef TextFormatAlign_obj OBJ_;
		TextFormatAlign_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< TextFormatAlign_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~TextFormatAlign_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("TextFormatAlign"); }

		static ::String LEFT;
		static ::String RIGHT;
		static ::String CENTER;
		static ::String JUSTIFY;
};

} // end namespace openfl
} // end namespace _v2
} // end namespace text

#endif /* INCLUDED_openfl__v2_text_TextFormatAlign */ 
