#ifndef INCLUDED_flixel_input_IFlxInputManager
#define INCLUDED_flixel_input_IFlxInputManager

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,input,IFlxInputManager)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace input{


class HXCPP_CLASS_ATTRIBUTES  IFlxInputManager_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxInputManager_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void reset( )=0;
		Dynamic reset_dyn();
virtual Void update( )=0;
		Dynamic update_dyn();
virtual Void onFocus( )=0;
		Dynamic onFocus_dyn();
virtual Void onFocusLost( )=0;
		Dynamic onFocusLost_dyn();
};

#define DELEGATE_flixel_input_IFlxInputManager \
virtual Void reset( ) { return mDelegate->reset();}  \
virtual Dynamic reset_dyn() { return mDelegate->reset_dyn();}  \
virtual Void update( ) { return mDelegate->update();}  \
virtual Dynamic update_dyn() { return mDelegate->update_dyn();}  \
virtual Void onFocus( ) { return mDelegate->onFocus();}  \
virtual Dynamic onFocus_dyn() { return mDelegate->onFocus_dyn();}  \
virtual Void onFocusLost( ) { return mDelegate->onFocusLost();}  \
virtual Dynamic onFocusLost_dyn() { return mDelegate->onFocusLost_dyn();}  \


template<typename IMPL>
class IFlxInputManager_delegate_ : public IFlxInputManager_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxInputManager_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_input_IFlxInputManager
};

} // end namespace flixel
} // end namespace input

#endif /* INCLUDED_flixel_input_IFlxInputManager */ 
