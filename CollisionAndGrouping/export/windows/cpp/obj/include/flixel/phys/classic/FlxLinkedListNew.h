#ifndef INCLUDED_flixel_phys_classic_FlxLinkedListNew
#define INCLUDED_flixel_phys_classic_FlxLinkedListNew

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,phys,IFlxBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxClassicBody)
HX_DECLARE_CLASS3(flixel,phys,classic,FlxLinkedListNew)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace phys{
namespace classic{


class HXCPP_CLASS_ATTRIBUTES  FlxLinkedListNew_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxLinkedListNew_obj OBJ_;
		FlxLinkedListNew_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxLinkedListNew_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxLinkedListNew_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxLinkedListNew_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxLinkedListNew"); }

		::flixel::phys::classic::FlxClassicBody object;
		::flixel::phys::classic::FlxLinkedListNew next;
		bool exists;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		static int _NUM_CACHED_FLX_LIST;
		static ::flixel::phys::classic::FlxLinkedListNew _cachedListsHead;
		static ::flixel::phys::classic::FlxLinkedListNew recycle( );
		static Dynamic recycle_dyn();

		static Void clearCache( );
		static Dynamic clearCache_dyn();

};

} // end namespace flixel
} // end namespace phys
} // end namespace classic

#endif /* INCLUDED_flixel_phys_classic_FlxLinkedListNew */ 
