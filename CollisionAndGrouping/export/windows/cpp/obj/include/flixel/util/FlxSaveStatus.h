#ifndef INCLUDED_flixel_util_FlxSaveStatus
#define INCLUDED_flixel_util_FlxSaveStatus

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,util,FlxSaveStatus)
namespace flixel{
namespace util{


class FlxSaveStatus_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxSaveStatus_obj OBJ_;

	public:
		FlxSaveStatus_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.util.FlxSaveStatus"); }
		::String __ToString() const { return HX_CSTRING("FlxSaveStatus.") + tag; }

		static ::flixel::util::FlxSaveStatus ERROR;
		static inline ::flixel::util::FlxSaveStatus ERROR_dyn() { return ERROR; }
		static ::flixel::util::FlxSaveStatus PENDING;
		static inline ::flixel::util::FlxSaveStatus PENDING_dyn() { return PENDING; }
		static ::flixel::util::FlxSaveStatus SUCCESS;
		static inline ::flixel::util::FlxSaveStatus SUCCESS_dyn() { return SUCCESS; }
};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_FlxSaveStatus */ 
