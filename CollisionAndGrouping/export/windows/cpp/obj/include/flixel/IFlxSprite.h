#ifndef INCLUDED_flixel_IFlxSprite
#define INCLUDED_flixel_IFlxSprite

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/IFlxBasic.h>
HX_DECLARE_CLASS1(flixel,IFlxBasic)
HX_DECLARE_CLASS1(flixel,IFlxSprite)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{


class HXCPP_CLASS_ATTRIBUTES  IFlxSprite_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxSprite_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void reset( Float X,Float Y)=0;
		Dynamic reset_dyn();
virtual Void setPosition( hx::Null< Float >  X,hx::Null< Float >  Y)=0;
		Dynamic setPosition_dyn();
};

#define DELEGATE_flixel_IFlxSprite \
virtual Void reset( Float X,Float Y) { return mDelegate->reset(X,Y);}  \
virtual Dynamic reset_dyn() { return mDelegate->reset_dyn();}  \
virtual Void setPosition( hx::Null< Float >  X,hx::Null< Float >  Y) { return mDelegate->setPosition(X,Y);}  \
virtual Dynamic setPosition_dyn() { return mDelegate->setPosition_dyn();}  \


template<typename IMPL>
class IFlxSprite_delegate_ : public IFlxSprite_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxSprite_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_IFlxSprite
};

} // end namespace flixel

#endif /* INCLUDED_flixel_IFlxSprite */ 
