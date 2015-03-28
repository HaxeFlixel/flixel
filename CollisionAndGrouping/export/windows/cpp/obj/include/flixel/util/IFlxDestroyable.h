#ifndef INCLUDED_flixel_util_IFlxDestroyable
#define INCLUDED_flixel_util_IFlxDestroyable

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  IFlxDestroyable_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxDestroyable_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void destroy( )=0;
		Dynamic destroy_dyn();
};

#define DELEGATE_flixel_util_IFlxDestroyable \
virtual Void destroy( ) { return mDelegate->destroy();}  \
virtual Dynamic destroy_dyn() { return mDelegate->destroy_dyn();}  \


template<typename IMPL>
class IFlxDestroyable_delegate_ : public IFlxDestroyable_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxDestroyable_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_util_IFlxDestroyable
};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_IFlxDestroyable */ 
