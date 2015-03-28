#ifndef INCLUDED_flixel_util__FlxBitmapDataPool_FlxBitmapDataPoolNode
#define INCLUDED_flixel_util__FlxBitmapDataPool_FlxBitmapDataPoolNode

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,util,_FlxBitmapDataPool,FlxBitmapDataPoolNode)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
namespace flixel{
namespace util{
namespace _FlxBitmapDataPool{


class HXCPP_CLASS_ATTRIBUTES  FlxBitmapDataPoolNode_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxBitmapDataPoolNode_obj OBJ_;
		FlxBitmapDataPoolNode_obj();
		Void __construct(::openfl::_v2::display::BitmapData bmd,::flixel::util::_FlxBitmapDataPool::FlxBitmapDataPoolNode prev,::flixel::util::_FlxBitmapDataPool::FlxBitmapDataPoolNode next);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxBitmapDataPoolNode_obj > __new(::openfl::_v2::display::BitmapData bmd,::flixel::util::_FlxBitmapDataPool::FlxBitmapDataPoolNode prev,::flixel::util::_FlxBitmapDataPool::FlxBitmapDataPoolNode next);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxBitmapDataPoolNode_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxBitmapDataPoolNode"); }

		::openfl::_v2::display::BitmapData bmd;
		::flixel::util::_FlxBitmapDataPool::FlxBitmapDataPoolNode prev;
		::flixel::util::_FlxBitmapDataPool::FlxBitmapDataPoolNode next;
};

} // end namespace flixel
} // end namespace util
} // end namespace _FlxBitmapDataPool

#endif /* INCLUDED_flixel_util__FlxBitmapDataPool_FlxBitmapDataPoolNode */ 
