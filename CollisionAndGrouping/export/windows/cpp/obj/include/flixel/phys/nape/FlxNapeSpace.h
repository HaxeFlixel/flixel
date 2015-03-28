#ifndef INCLUDED_flixel_phys_nape_FlxNapeSpace
#define INCLUDED_flixel_phys_nape_FlxNapeSpace

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/phys/IFlxSpace.h>
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS3(flixel,phys,nape,FlxNapeBody)
HX_DECLARE_CLASS3(flixel,phys,nape,FlxNapeSpace)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(nape,space,Space)
namespace flixel{
namespace phys{
namespace nape{


class HXCPP_CLASS_ATTRIBUTES  FlxNapeSpace_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxNapeSpace_obj OBJ_;
		FlxNapeSpace_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxNapeSpace_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxNapeSpace_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::phys::IFlxSpace_obj *()
			{ return new ::flixel::phys::IFlxSpace_delegate_< FlxNapeSpace_obj >(this); }
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxNapeSpace_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxNapeSpace"); }

		::nape::space::Space napeSpace;
		Array< ::Dynamic > objects;
		virtual Void step( Float elapsed);
		Dynamic step_dyn();

		virtual Void add( ::flixel::phys::nape::FlxNapeBody body);
		Dynamic add_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace nape

#endif /* INCLUDED_flixel_phys_nape_FlxNapeSpace */ 
