#ifndef INCLUDED_nape_geom_Ray
#define INCLUDED_nape_geom_Ray

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,AABB)
HX_DECLARE_CLASS2(nape,geom,Ray)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_Ray)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  Ray_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Ray_obj OBJ_;
		Ray_obj();
		Void __construct(::nape::geom::Vec2 origin,::nape::geom::Vec2 direction);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Ray_obj > __new(::nape::geom::Vec2 origin,::nape::geom::Vec2 direction);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Ray_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Ray"); }

		::zpp_nape::geom::ZPP_Ray zpp_inner;
		virtual Dynamic get_userData( );
		Dynamic get_userData_dyn();

		virtual ::nape::geom::Vec2 get_origin( );
		Dynamic get_origin_dyn();

		virtual ::nape::geom::Vec2 set_origin( ::nape::geom::Vec2 origin);
		Dynamic set_origin_dyn();

		virtual ::nape::geom::Vec2 get_direction( );
		Dynamic get_direction_dyn();

		virtual ::nape::geom::Vec2 set_direction( ::nape::geom::Vec2 direction);
		Dynamic set_direction_dyn();

		virtual Float get_maxDistance( );
		Dynamic get_maxDistance_dyn();

		virtual Float set_maxDistance( Float maxDistance);
		Dynamic set_maxDistance_dyn();

		virtual ::nape::geom::AABB aabb( );
		Dynamic aabb_dyn();

		virtual ::nape::geom::Vec2 at( Float distance,hx::Null< bool >  weak);
		Dynamic at_dyn();

		virtual ::nape::geom::Ray copy( );
		Dynamic copy_dyn();

		static ::nape::geom::Ray fromSegment( ::nape::geom::Vec2 start,::nape::geom::Vec2 end);
		static Dynamic fromSegment_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_Ray */ 
