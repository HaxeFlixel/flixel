#ifndef INCLUDED_openfl_text_TextFieldType
#define INCLUDED_openfl_text_TextFieldType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,text,TextFieldType)
namespace openfl{
namespace text{


class TextFieldType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef TextFieldType_obj OBJ_;

	public:
		TextFieldType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.text.TextFieldType"); }
		::String __ToString() const { return HX_CSTRING("TextFieldType.") + tag; }

		static ::openfl::text::TextFieldType DYNAMIC;
		static inline ::openfl::text::TextFieldType DYNAMIC_dyn() { return DYNAMIC; }
		static ::openfl::text::TextFieldType INPUT;
		static inline ::openfl::text::TextFieldType INPUT_dyn() { return INPUT; }
};

} // end namespace openfl
} // end namespace text

#endif /* INCLUDED_openfl_text_TextFieldType */ 
