#ifndef INCLUDED_nape_geom_GeomVertexIterator
#define INCLUDED_nape_geom_GeomVertexIterator

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,geom,GeomVertexIterator)
HX_DECLARE_CLASS2(nape,geom,Vec2)
HX_DECLARE_CLASS2(zpp_nape,geom,ZPP_GeomVertexIterator)
namespace nape{
namespace geom{


class HXCPP_CLASS_ATTRIBUTES  GeomVertexIterator_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef GeomVertexIterator_obj OBJ_;
		GeomVertexIterator_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GeomVertexIterator_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GeomVertexIterator_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("GeomVertexIterator"); }

		::zpp_nape::geom::ZPP_GeomVertexIterator zpp_inner;
		virtual bool hasNext( );
		Dynamic hasNext_dyn();

		virtual ::nape::geom::Vec2 next( );
		Dynamic next_dyn();

};

} // end namespace nape
} // end namespace geom

#endif /* INCLUDED_nape_geom_GeomVertexIterator */ 
