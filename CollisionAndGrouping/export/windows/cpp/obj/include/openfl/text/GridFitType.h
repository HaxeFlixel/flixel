#ifndef INCLUDED_openfl_text_GridFitType
#define INCLUDED_openfl_text_GridFitType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,text,GridFitType)
namespace openfl{
namespace text{


class GridFitType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef GridFitType_obj OBJ_;

	public:
		GridFitType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.text.GridFitType"); }
		::String __ToString() const { return HX_CSTRING("GridFitType.") + tag; }

		static ::openfl::text::GridFitType NONE;
		static inline ::openfl::text::GridFitType NONE_dyn() { return NONE; }
		static ::openfl::text::GridFitType PIXEL;
		static inline ::openfl::text::GridFitType PIXEL_dyn() { return PIXEL; }
		static ::openfl::text::GridFitType SUBPIXEL;
		static inline ::openfl::text::GridFitType SUBPIXEL_dyn() { return SUBPIXEL; }
};

} // end namespace openfl
} // end namespace text

#endif /* INCLUDED_openfl_text_GridFitType */ 
