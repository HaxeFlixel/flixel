#ifndef INCLUDED_flixel_effects_particles_IFlxParticle
#define INCLUDED_flixel_effects_particles_IFlxParticle

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/IFlxSprite.h>
HX_DECLARE_CLASS1(flixel,IFlxBasic)
HX_DECLARE_CLASS1(flixel,IFlxSprite)
HX_DECLARE_CLASS3(flixel,effects,particles,IFlxParticle)
HX_DECLARE_CLASS3(flixel,util,helpers,FlxRange)
namespace flixel{
namespace effects{
namespace particles{


class HXCPP_CLASS_ATTRIBUTES  IFlxParticle_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxParticle_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual Void onEmit( )=0;
		Dynamic onEmit_dyn();
};

#define DELEGATE_flixel_effects_particles_IFlxParticle \
virtual Void onEmit( ) { return mDelegate->onEmit();}  \
virtual Dynamic onEmit_dyn() { return mDelegate->onEmit_dyn();}  \


template<typename IMPL>
class IFlxParticle_delegate_ : public IFlxParticle_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxParticle_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_effects_particles_IFlxParticle
};

} // end namespace flixel
} // end namespace effects
} // end namespace particles

#endif /* INCLUDED_flixel_effects_particles_IFlxParticle */ 
