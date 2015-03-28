#ifndef INCLUDED_flixel_overlap_FlxOverlap2D
#define INCLUDED_flixel_overlap_FlxOverlap2D

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,math,FlxRect)
HX_DECLARE_CLASS2(flixel,math,FlxVector)
HX_DECLARE_CLASS2(flixel,overlap,FlxCircle)
HX_DECLARE_CLASS2(flixel,overlap,FlxHitboxList)
HX_DECLARE_CLASS2(flixel,overlap,FlxOverlap2D)
HX_DECLARE_CLASS2(flixel,overlap,FlxOverlapData)
HX_DECLARE_CLASS2(flixel,overlap,FlxPolygon)
HX_DECLARE_CLASS2(flixel,overlap,FlxRay)
HX_DECLARE_CLASS2(flixel,overlap,FlxRayData)
HX_DECLARE_CLASS2(flixel,overlap,IFlxHitbox)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace overlap{


class HXCPP_CLASS_ATTRIBUTES  FlxOverlap2D_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxOverlap2D_obj OBJ_;
		FlxOverlap2D_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxOverlap2D_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxOverlap2D_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxOverlap2D"); }

		static ::flixel::math::FlxVector _normalAxis;
		static ::flixel::math::FlxVector _vectorOffset;
		static ::flixel::math::FlxVector _closestVector;
		static ::flixel::math::FlxVector _delta;
		static ::flixel::math::FlxVector _ray2circle;
		static bool testCircleVsPolygon( ::flixel::overlap::FlxCircle circle,::flixel::overlap::FlxPolygon polygon,bool flip,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic testCircleVsPolygon_dyn();

		static bool testCircles( ::flixel::overlap::FlxCircle circle1,::flixel::overlap::FlxCircle circle2,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic testCircles_dyn();

		static bool testPolygons( ::flixel::overlap::FlxPolygon polygon1,::flixel::overlap::FlxPolygon polygon2,hx::Null< bool >  flip,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic testPolygons_dyn();

		static bool checkPolygons( ::flixel::overlap::FlxPolygon polygon1,::flixel::overlap::FlxPolygon polygon2,bool flip,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic checkPolygons_dyn();

		static bool testCircleVsHitboxList( ::flixel::overlap::FlxCircle circle,::flixel::overlap::FlxHitboxList hitboxList,bool flip,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic testCircleVsHitboxList_dyn();

		static bool testPolygonVsHitboxList( ::flixel::overlap::FlxPolygon polygon,::flixel::overlap::FlxHitboxList hitboxList,bool flip,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic testPolygonVsHitboxList_dyn();

		static bool testHitboxLists( ::flixel::overlap::FlxHitboxList hitboxList1,::flixel::overlap::FlxHitboxList hitboxList2,bool flip,::flixel::overlap::FlxOverlapData overlapData);
		static Dynamic testHitboxLists_dyn();

		static bool testRects( ::flixel::math::FlxRect rect1,::flixel::math::FlxRect rect2);
		static Dynamic testRects_dyn();

		static bool rayCircle( ::flixel::overlap::FlxRay ray,::flixel::overlap::FlxCircle circle,::flixel::overlap::FlxRayData rayData);
		static Dynamic rayCircle_dyn();

		static bool rayPolygon( ::flixel::overlap::FlxRay ray,::flixel::overlap::FlxPolygon polygon,::flixel::overlap::FlxRayData rayData);
		static Dynamic rayPolygon_dyn();

		static bool rayHitboxList( ::flixel::overlap::FlxRay ray,::flixel::overlap::FlxHitboxList hitboxList,::flixel::overlap::FlxRayData rayData);
		static Dynamic rayHitboxList_dyn();

		static Dynamic intersectRayRay( ::flixel::math::FlxVector a,::flixel::math::FlxVector adelta,::flixel::math::FlxVector b,::flixel::math::FlxVector bdelta);
		static Dynamic intersectRayRay_dyn();

		static Void findNormalAxis( Array< ::Dynamic > vertices,int index);
		static Dynamic findNormalAxis_dyn();

};

} // end namespace flixel
} // end namespace overlap

#endif /* INCLUDED_flixel_overlap_FlxOverlap2D */ 
