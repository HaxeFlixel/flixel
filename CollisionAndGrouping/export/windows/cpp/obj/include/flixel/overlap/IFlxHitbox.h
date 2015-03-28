#ifndef INCLUDED_flixel_overlap_IFlxHitbox
#define INCLUDED_flixel_overlap_IFlxHitbox

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS1(flixel,FlxSprite)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,overlap,FlxCircle)
HX_DECLARE_CLASS2(flixel,overlap,FlxHitboxList)
HX_DECLARE_CLASS2(flixel,overlap,FlxOverlapData)
HX_DECLARE_CLASS2(flixel,overlap,FlxPolygon)
HX_DECLARE_CLASS2(flixel,overlap,FlxRay)
HX_DECLARE_CLASS2(flixel,overlap,FlxRayData)
HX_DECLARE_CLASS2(flixel,overlap,IFlxHitbox)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace overlap{


class HXCPP_CLASS_ATTRIBUTES  IFlxHitbox_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IFlxHitbox_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual bool test( ::flixel::overlap::IFlxHitbox hitbox,::flixel::overlap::FlxOverlapData overlapData)=0;
		Dynamic test_dyn();
virtual bool testCircle( ::flixel::overlap::FlxCircle circle,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData)=0;
		Dynamic testCircle_dyn();
virtual bool testPolygon( ::flixel::overlap::FlxPolygon polygon,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData)=0;
		Dynamic testPolygon_dyn();
virtual bool testHitboxList( ::flixel::overlap::FlxHitboxList hitboxList,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData)=0;
		Dynamic testHitboxList_dyn();
virtual bool testRay( ::flixel::overlap::FlxRay ray,::flixel::overlap::FlxRayData rayData)=0;
		Dynamic testRay_dyn();
};

#define DELEGATE_flixel_overlap_IFlxHitbox \
virtual bool test( ::flixel::overlap::IFlxHitbox hitbox,::flixel::overlap::FlxOverlapData overlapData) { return mDelegate->test(hitbox,overlapData);}  \
virtual Dynamic test_dyn() { return mDelegate->test_dyn();}  \
virtual bool testCircle( ::flixel::overlap::FlxCircle circle,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData) { return mDelegate->testCircle(circle,flip,overlapData);}  \
virtual Dynamic testCircle_dyn() { return mDelegate->testCircle_dyn();}  \
virtual bool testPolygon( ::flixel::overlap::FlxPolygon polygon,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData) { return mDelegate->testPolygon(polygon,flip,overlapData);}  \
virtual Dynamic testPolygon_dyn() { return mDelegate->testPolygon_dyn();}  \
virtual bool testHitboxList( ::flixel::overlap::FlxHitboxList hitboxList,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData) { return mDelegate->testHitboxList(hitboxList,flip,overlapData);}  \
virtual Dynamic testHitboxList_dyn() { return mDelegate->testHitboxList_dyn();}  \
virtual bool testRay( ::flixel::overlap::FlxRay ray,::flixel::overlap::FlxRayData rayData) { return mDelegate->testRay(ray,rayData);}  \
virtual Dynamic testRay_dyn() { return mDelegate->testRay_dyn();}  \


template<typename IMPL>
class IFlxHitbox_delegate_ : public IFlxHitbox_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IFlxHitbox_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_flixel_overlap_IFlxHitbox
};

} // end namespace flixel
} // end namespace overlap

#endif /* INCLUDED_flixel_overlap_IFlxHitbox */ 
