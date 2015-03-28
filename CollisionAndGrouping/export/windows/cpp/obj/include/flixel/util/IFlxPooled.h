#ifndef INCLUDED_flixel_util_IFlxPooled
#define INCLUDED_flixel_util_IFlxPooled

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  IFlxPooled_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxPooled_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void put( )=0;
		Dynamic put_dyn();
};

#define DELEGATE_flixel_util_IFlxPooled \
virtual Void put( ) { return mDelegate->put();}  \
virtual Dynamic put_dyn() { return mDelegate->put_dyn();}  \


template<typename IMPL>
class IFlxPooled_delegate_ : public IFlxPooled_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxPooled_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_util_IFlxPooled
};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_IFlxPooled */ 
