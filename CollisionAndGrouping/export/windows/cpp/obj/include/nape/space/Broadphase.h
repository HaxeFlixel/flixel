#ifndef INCLUDED_nape_space_Broadphase
#define INCLUDED_nape_space_Broadphase

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(nape,space,Broadphase)
namespace nape{
namespace space{


class HXCPP_CLASS_ATTRIBUTES  Broadphase_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Broadphase_obj OBJ_;
		Broadphase_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Broadphase_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Broadphase_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("Broadphase"); }

		virtual ::String toString( );
		Dynamic toString_dyn();

		static ::nape::space::Broadphase get_DYNAMIC_AABB_TREE( );
		static Dynamic get_DYNAMIC_AABB_TREE_dyn();

		static ::nape::space::Broadphase get_SWEEP_AND_PRUNE( );
		static Dynamic get_SWEEP_AND_PRUNE_dyn();

};

} // end namespace nape
} // end namespace space

#endif /* INCLUDED_nape_space_Broadphase */ 
