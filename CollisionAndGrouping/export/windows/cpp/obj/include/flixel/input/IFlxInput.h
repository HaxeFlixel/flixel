#ifndef INCLUDED_flixel_input_IFlxInput
#define INCLUDED_flixel_input_IFlxInput

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,input,IFlxInput)
namespace flixel{
namespace input{


class HXCPP_CLASS_ATTRIBUTES  IFlxInput_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxInput_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
};

#define DELEGATE_flixel_input_IFlxInput \


template<typename IMPL>
class IFlxInput_delegate_ : public IFlxInput_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxInput_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_input_IFlxInput
};

} // end namespace flixel
} // end namespace input

#endif /* INCLUDED_flixel_input_IFlxInput */ 
