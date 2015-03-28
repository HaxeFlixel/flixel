#ifndef INCLUDED_flixel_phys_IFlxBody
#define INCLUDED_flixel_phys_IFlxBody

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace phys{


class HXCPP_CLASS_ATTRIBUTES  IFlxBody_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxBody_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
};

#define DELEGATE_flixel_phys_IFlxBody \


template<typename IMPL>
class IFlxBody_delegate_ : public IFlxBody_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxBody_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_phys_IFlxBody
};

} // end namespace flixel
} // end namespace phys

#endif /* INCLUDED_flixel_phys_IFlxBody */ 
