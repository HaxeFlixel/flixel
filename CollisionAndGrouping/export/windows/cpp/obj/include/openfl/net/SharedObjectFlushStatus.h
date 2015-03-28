#ifndef INCLUDED_openfl_net_SharedObjectFlushStatus
#define INCLUDED_openfl_net_SharedObjectFlushStatus

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(openfl,net,SharedObjectFlushStatus)
namespace openfl{
namespace net{


class SharedObjectFlushStatus_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef SharedObjectFlushStatus_obj OBJ_;

	public:
		SharedObjectFlushStatus_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl.net.SharedObjectFlushStatus"); }
		::String __ToString() const { return HX_CSTRING("SharedObjectFlushStatus.") + tag; }

		static ::openfl::net::SharedObjectFlushStatus FLUSHED;
		static inline ::openfl::net::SharedObjectFlushStatus FLUSHED_dyn() { return FLUSHED; }
		static ::openfl::net::SharedObjectFlushStatus PENDING;
		static inline ::openfl::net::SharedObjectFlushStatus PENDING_dyn() { return PENDING; }
};

} // end namespace openfl
} // end namespace net

#endif /* INCLUDED_openfl_net_SharedObjectFlushStatus */ 
