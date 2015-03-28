#ifndef INCLUDED_flixel_util_IFlxSignal
#define INCLUDED_flixel_util_IFlxSignal

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxSignal)
namespace flixel{
namespace util{


class HXCPP_CLASS_ATTRIBUTES  IFlxSignal_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxSignal_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void add( Dynamic listener)=0;
		Dynamic add_dyn();
virtual Void addOnce( Dynamic listener)=0;
		Dynamic addOnce_dyn();
virtual Void remove( Dynamic listener)=0;
		Dynamic remove_dyn();
virtual Void removeAll( )=0;
		Dynamic removeAll_dyn();
virtual bool has( Dynamic listener)=0;
		Dynamic has_dyn();
};

#define DELEGATE_flixel_util_IFlxSignal \
virtual Void add( Dynamic listener) { return mDelegate->add(listener);}  \
virtual Dynamic add_dyn() { return mDelegate->add_dyn();}  \
virtual Void addOnce( Dynamic listener) { return mDelegate->addOnce(listener);}  \
virtual Dynamic addOnce_dyn() { return mDelegate->addOnce_dyn();}  \
virtual Void remove( Dynamic listener) { return mDelegate->remove(listener);}  \
virtual Dynamic remove_dyn() { return mDelegate->remove_dyn();}  \
virtual Void removeAll( ) { return mDelegate->removeAll();}  \
virtual Dynamic removeAll_dyn() { return mDelegate->removeAll_dyn();}  \
virtual bool has( Dynamic listener) { return mDelegate->has(listener);}  \
virtual Dynamic has_dyn() { return mDelegate->has_dyn();}  \


template<typename IMPL>
class IFlxSignal_delegate_ : public IFlxSignal_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxSignal_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_util_IFlxSignal
};

} // end namespace flixel
} // end namespace util

#endif /* INCLUDED_flixel_util_IFlxSignal */ 
