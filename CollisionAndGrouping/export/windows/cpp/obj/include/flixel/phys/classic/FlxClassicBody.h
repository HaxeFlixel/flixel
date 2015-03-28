#ifndef INCLUDED_flixel_phys_classic_FlxClassicBody
#define INCLUDED_flixel_phys_classic_FlxClassicBody

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/phys/IFlxBody.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,math,FlxPoint)
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicSpace)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS2(flixel,util,IFlxPooled)
namespace flixel{
namespace phys{
namespace classic{


class HXCPP_CLASS_ATTRIBUTES  FlxClassicBody_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxClassicBody_obj OBJ_;
		FlxClassicBody_obj();
		Void __construct(::flixel::FlxObject parent,::flixel::phys::classic::FlxClassicSpace space);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxClassicBody_obj > __new(::flixel::FlxObject parent,::flixel::phys::classic::FlxClassicSpace space);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxClassicBody_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxClassicBody_obj >(this); }
		inline operator ::flixel::phys::IFlxBody_obj *()
			{ return new ::flixel::phys::IFlxBody_delegate_< FlxClassicBody_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxClassicBody"); }

		::flixel::FlxObject parent;
		::flixel::phys::IFlxSpace space;
		Float x;
		Float y;
		::flixel::math::FlxPoint last;
		::flixel::math::FlxPoint velocity;
		::flixel::math::FlxPoint drag;
		::flixel::math::FlxPoint maxVelocity;
		::flixel::math::FlxPoint acceleration;
		Float angle;
		Float angularVelocity;
		Float angularDrag;
		Float maxAngular;
		Float angularAcceleration;
		Float mass;
		Float elasticity;
		int allowCollisions;
		int touching;
		bool kinematic;
		bool collisonXDrag;
		Float width;
		Float height;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		virtual Void updateBody( Float elapsed);
		Dynamic updateBody_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace classic

#endif /* INCLUDED_flixel_phys_classic_FlxClassicBody */ 
