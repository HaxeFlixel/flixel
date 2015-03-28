#ifndef INCLUDED_flixel_system_FlxLinkedList
#define INCLUDED_flixel_system_FlxLinkedList

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS1(flixel,FlxBasic)
HX_DECLARE_CLASS1(flixel,FlxObject)
HX_DECLARE_CLASS2(flixel,system,FlxLinkedList)
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
namespace flixel{
namespace system{


class HXCPP_CLASS_ATTRIBUTES  FlxLinkedList_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxLinkedList_obj OBJ_;
		FlxLinkedList_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxLinkedList_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxLinkedList_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxLinkedList_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxLinkedList"); }

		::flixel::FlxObject object;
		::flixel::system::FlxLinkedList next;
		bool exists;
		virtual Void destroy( );
		Dynamic destroy_dyn();

		static int _NUM_CACHED_FLX_LIST;
		static ::flixel::system::FlxLinkedList _cachedListsHead;
		static ::flixel::system::FlxLinkedList recycle( );
		static Dynamic recycle_dyn();

		static Void clearCache( );
		static Dynamic clearCache_dyn();

};

} // end namespace flixel
} // end namespace system

#endif /* INCLUDED_flixel_system_FlxLinkedList */ 
