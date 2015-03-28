#ifndef INCLUDED_flixel_IFlxBasic
#define INCLUDED_flixel_IFlxBasic

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,IFlxBasic)
namespace flixel{


class HXCPP_CLASS_ATTRIBUTES  IFlxBasic_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxBasic_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void draw( )=0;
		Dynamic draw_dyn();
virtual Void update( Float elapsed)=0;
		Dynamic update_dyn();
virtual Void destroy( )=0;
		Dynamic destroy_dyn();
virtual Void kill( )=0;
		Dynamic kill_dyn();
virtual Void revive( )=0;
		Dynamic revive_dyn();
virtual ::String toString( )=0;
		Dynamic toString_dyn();
};

#define DELEGATE_flixel_IFlxBasic \
virtual Void draw( ) { return mDelegate->draw();}  \
virtual Dynamic draw_dyn() { return mDelegate->draw_dyn();}  \
virtual Void update( Float elapsed) { return mDelegate->update(elapsed);}  \
virtual Dynamic update_dyn() { return mDelegate->update_dyn();}  \
virtual Void destroy( ) { return mDelegate->destroy();}  \
virtual Dynamic destroy_dyn() { return mDelegate->destroy_dyn();}  \
virtual Void kill( ) { return mDelegate->kill();}  \
virtual Dynamic kill_dyn() { return mDelegate->kill_dyn();}  \
virtual Void revive( ) { return mDelegate->revive();}  \
virtual Dynamic revive_dyn() { return mDelegate->revive_dyn();}  \
virtual ::String toString( ) { return mDelegate->toString();}  \
virtual Dynamic toString_dyn() { return mDelegate->toString_dyn();}  \


template<typename IMPL>
class IFlxBasic_delegate_ : public IFlxBasic_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxBasic_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_IFlxBasic
};

} // end namespace flixel

#endif /* INCLUDED_flixel_IFlxBasic */ 
