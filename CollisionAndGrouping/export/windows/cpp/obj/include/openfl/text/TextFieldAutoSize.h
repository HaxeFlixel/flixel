#ifndef INCLUDED_openfl_text_TextFieldAutoSize
#define INCLUDED_openfl_text_TextFieldAutoSize

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,text,TextFieldAutoSize)
namespace openfl{
namespace text{


class TextFieldAutoSize_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef TextFieldAutoSize_obj OBJ_;

	public:
		TextFieldAutoSize_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.text.TextFieldAutoSize"); }
		::String __ToString() const { return HX_CSTRING("TextFieldAutoSize.") + tag; }

		static ::openfl::text::TextFieldAutoSize CENTER;
		static inline ::openfl::text::TextFieldAutoSize CENTER_dyn() { return CENTER; }
		static ::openfl::text::TextFieldAutoSize LEFT;
		static inline ::openfl::text::TextFieldAutoSize LEFT_dyn() { return LEFT; }
		static ::openfl::text::TextFieldAutoSize NONE;
		static inline ::openfl::text::TextFieldAutoSize NONE_dyn() { return NONE; }
		static ::openfl::text::TextFieldAutoSize RIGHT;
		static inline ::openfl::text::TextFieldAutoSize RIGHT_dyn() { return RIGHT; }
};

} // end namespace openfl
} // end namespace text

#endif /* INCLUDED_openfl_text_TextFieldAutoSize */ 
