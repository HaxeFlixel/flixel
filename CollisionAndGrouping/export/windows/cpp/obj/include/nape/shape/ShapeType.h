#ifndef INCLUDED_nape_shape_ShapeType
#define INCLUDED_nape_shape_ShapeType

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,shape,ShapeType)
namespace nape{
namespace shape{


class HXCPP_CLASS_ATTRIBUTES  ShapeType_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef ShapeType_obj OBJ_;
		ShapeType_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< ShapeType_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~ShapeType_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("ShapeType"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::shape::ShapeType get_CIRCLE( );
		static Dynamic get_CIRCLE_dyn();

		static ::nape::shape::ShapeType get_POLYGON( );
		static Dynamic get_POLYGON_dyn();

};

} // end namespace nape
} // end namespace shape

#endif /* INCLUDED_nape_shape_ShapeType */ 
