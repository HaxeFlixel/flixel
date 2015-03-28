#ifndef INCLUDED_flixel_phys_classic_FlxClassicSpace
#define INCLUDED_flixel_phys_classic_FlxClassicSpace

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/phys/IFlxSpace.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS2(flixel,group,FlxTypedGroup)
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS2(flixel,phys,IFlxSpace)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicSpace)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace phys{
namespace classic{


class HXCPP_CLASS_ATTRIBUTES  FlxClassicSpace_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxClassicSpace_obj OBJ_;
		FlxClassicSpace_obj();
		Void __construct(hx::Null< int >  __o_iterationCount);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxClassicSpace_obj > __new(hx::Null< int >  __o_iterationCount);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxClassicSpace_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::phys::IFlxSpace_obj *()
			{ return new ::flixel::phys::IFlxSpace_delegate_< FlxClassicSpace_obj >(this); }
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxClassicSpace_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxClassicSpace"); }

		Array< ::Dynamic > objects;
		::flixel::group::FlxTypedGroup _hasToBeRemoved;
		int iterationCount;
		virtual Void add( ::flixel::phys::IFlxBody body);
		Dynamic add_dyn();

		virtual Void remove( ::flixel::phys::IFlxBody body);
		Dynamic remove_dyn();

		virtual Void step( Float elapsed);
		Dynamic step_dyn();

		virtual Void destroy( );
		Dynamic destroy_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace classic

#endif /* INCLUDED_flixel_phys_classic_FlxClassicSpace */ 
