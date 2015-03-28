#ifndef INCLUDED_flixel_phys_nape_FlxNapeBody
#define INCLUDED_flixel_phys_nape_FlxNapeBody

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/phys/IFlxBody.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS3(flixel,phys,nape,FlxNapeBody)
HX_DECLARE_CLASS3(flixel,phys,nape,FlxNapeSpace)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
HX_DECLARE_CLASS2(nape,phys,Body)
HX_DECLARE_CLASS2(nape,phys,Interactor)
namespace flixel{
namespace phys{
namespace nape{


class HXCPP_CLASS_ATTRIBUTES  FlxNapeBody_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxNapeBody_obj OBJ_;
		FlxNapeBody_obj();
		Void __construct(::flixel::FlxObject parent,::flixel::phys::nape::FlxNapeSpace space,hx::Null< bool >  __o_createRectBody);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxNapeBody_obj > __new(::flixel::FlxObject parent,::flixel::phys::nape::FlxNapeSpace space,hx::Null< bool >  __o_createRectBody);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxNapeBody_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxNapeBody_obj >(this); }
		inline operator ::flixel::phys::IFlxBody_obj *()
			{ return new ::flixel::phys::IFlxBody_delegate_< FlxNapeBody_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxNapeBody"); }

		::nape::phys::Body napeBody;
		::flixel::FlxObject parent;
		::flixel::phys::IFlxSpace space;
		Float x;
		Float y;
		::flixel::math::FlxPoint velocity;
		::flixel::math::FlxPoint maxVelocity;
		::flixel::math::FlxPoint acceleration;
		Float angle;
		Float angularVelocity;
		Float maxAngular;
		Float angularAcceleration;
		Float mass;
		Float elasticity;
		bool kinematic;
		virtual Void updateBody( );
		Dynamic updateBody_dyn();

		virtual Void updateParent( );
		Dynamic updateParent_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace nape

#endif /* INCLUDED_flixel_phys_nape_FlxNapeBody */ 
