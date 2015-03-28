#ifndef INCLUDED_openfl_text_AntiAliasType
#define INCLUDED_openfl_text_AntiAliasType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,text,AntiAliasType)
namespace openfl{
namespace text{


class AntiAliasType_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef AntiAliasType_obj OBJ_;

	public:
		AntiAliasType_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.text.AntiAliasType"); }
		::String __ToString() const { return HX_CSTRING("AntiAliasType.") + tag; }

		static ::openfl::text::AntiAliasType ADVANCED;
		static inline ::openfl::text::AntiAliasType ADVANCED_dyn() { return ADVANCED; }
		static ::openfl::text::AntiAliasType NORMAL;
		static inline ::openfl::text::AntiAliasType NORMAL_dyn() { return NORMAL; }
};

} // end namespace openfl
} // end namespace text

#endif /* INCLUDED_openfl_text_AntiAliasType */ 
