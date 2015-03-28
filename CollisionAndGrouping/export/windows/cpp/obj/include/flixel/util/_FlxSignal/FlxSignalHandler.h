#ifndef INCLUDED_flixel_util__FlxSignal_FlxSignalHandler
#define INCLUDED_flixel_util__FlxSignal_FlxSignalHandler

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <flixel/util/IFlxDestroyable.h>
HX_DECLARE_CLASS2(flixel,util,IFlxDestroyable)
HX_DECLARE_CLASS3(flixel,util,_FlxSignal,FlxSignalHandler)
namespace flixel{
namespace util{
namespace _FlxSignal{


class HXCPP_CLASS_ATTRIBUTES  FlxSignalHandler_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxSignalHandler_obj OBJ_;
		FlxSignalHandler_obj();
		Void __construct(Dynamic listener,bool dispatchOnce);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxSignalHandler_obj > __new(Dynamic listener,bool dispatchOnce);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxSignalHandler_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		inline operator ::flixel::util::IFlxDestroyable_obj *()
			{ return new ::flixel::util::IFlxDestroyable_delegate_< FlxSignalHandler_obj >(this); }
		hx::Object *__ToInterface(const hx::type_info &inType);
		::String __ToString() const { return HX_CSTRING("FlxSignalHandler"); }

		Dynamic listener;
		bool dispatchOnce;
		virtual Void destroy( );
		Dynamic destroy_dyn();

};

} // end namespace flixel
} // end namespace util
} // end namespace _FlxSignal

#endif /* INCLUDED_flixel_util__FlxSignal_FlxSignalHandler */ 
