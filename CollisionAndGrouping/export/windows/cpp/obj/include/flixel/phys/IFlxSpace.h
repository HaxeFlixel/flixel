#ifndef INCLUDED_flixel_phys_IFlxSpace
#define INCLUDED_flixel_phys_IFlxSpace

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  IFlxSpace_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxSpace_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void step( Float elapsed)=0;
		Dynamic step_dyn();
};

#define DELEGATE_flixel_phys_IFlxSpace \
virtual Void step( Float elapsed) { return mDelegate->step(elapsed);}  \
virtual Dynamic step_dyn() { return mDelegate->step_dyn();}  \


template<typename IMPL>
class IFlxSpace_delegate_ : public IFlxSpace_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxSpace_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_phys_IFlxSpace
};

} // end namespace flixel
} // end namespace phys

#endif /* INCLUDED_flixel_phys_IFlxSpace */ 
