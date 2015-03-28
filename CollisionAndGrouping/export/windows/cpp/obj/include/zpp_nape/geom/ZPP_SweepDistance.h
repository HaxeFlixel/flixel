#ifndef INCLUDED_zpp_nape_geom_ZPP_SweepDistance
#define INCLUDED_zpp_nape_geom_ZPP_SweepDistance

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_SweepDistance)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_ToiEvent)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Vec2)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Body)
HX_DECLARE_CLASS2(zpp_nape,phys,ZPP_Interactor)
HX_DECLARE_CLASS2(zpp_nape,shape,ZPP_Shape)
namespace zpp_nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  ZPP_SweepDistance_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ZPP_SweepDistance_obj OBJ_;
		ZPP_SweepDistance_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ZPP_SweepDistance_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ZPP_SweepDistance_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ZPP_SweepDistance"); }

		static Void dynamicSweep( ::zpp_nape::geom::ZPP_ToiEvent toi,Float timeStep,Float lowerBound,Float negRadius,hx::Null< bool >  userAPI);
		static Dynamic dynamicSweep_dyn();

		static Void staticSweep( ::zpp_nape::geom::ZPP_ToiEvent toi,Float timeStep,Float lowerBound,Float negRadius);
		static Dynamic staticSweep_dyn();

		static Float distanceBody( ::zpp_nape::phys::ZPP_Body b1,::zpp_nape::phys::ZPP_Body b2,::zpp_nape::geom::ZPP_Vec2 w1,::zpp_nape::geom::ZPP_Vec2 w2);
		static Dynamic distanceBody_dyn();

		static Float distance( ::zpp_nape::shape::ZPP_Shape s1,::zpp_nape::shape::ZPP_Shape s2,::zpp_nape::geom::ZPP_Vec2 w1,::zpp_nape::geom::ZPP_Vec2 w2,::zpp_nape::geom::ZPP_Vec2 axis,hx::Null< Float >  upperBound);
		static Dynamic distance_dyn();

};

} // end namespace zpp_nape
} // end namespace geom

#endif /* INCLUDED_zpp_nape_geom_ZPP_SweepDistance */ 
