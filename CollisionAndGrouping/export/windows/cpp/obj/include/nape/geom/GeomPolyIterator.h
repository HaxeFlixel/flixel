#ifndef INCLUDED_nape_geom_GeomPolyIterator
#define INCLUDED_nape_geom_GeomPolyIterator

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,GeomPoly)
HX_DECLARE_CLASS2(nape,geom,GeomPolyIterator)
HX_DECLARE_CLASS2(nape,geom,GeomPolyList)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  GeomPolyIterator_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef GeomPolyIterator_obj OBJ_;
		GeomPolyIterator_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GeomPolyIterator_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GeomPolyIterator_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("GeomPolyIterator"); }

		::nape::geom::GeomPolyList zpp_inner;
		int zpp_i;
		bool zpp_critical;
		::nape::geom::GeomPolyIterator zpp_next;
		virtual bool hasNext( );
		Dynamic hasNext_dyn();

		virtual ::nape::geom::GeomPoly next( );
		Dynamic next_dyn();

		static ::nape::geom::GeomPolyIterator zpp_pool;
		static ::nape::geom::GeomPolyIterator get( ::nape::geom::GeomPolyList list);
		static Dynamic get_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_GeomPolyIterator */ 
