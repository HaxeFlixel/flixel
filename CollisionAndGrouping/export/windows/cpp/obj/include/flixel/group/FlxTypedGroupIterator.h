#ifndef INCLUDED_flixel_group_FlxTypedGroupIterator
#define INCLUDED_flixel_group_FlxTypedGroupIterator

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(flixel,group,FlxTypedGroupIterator)
namespace flixel{
namespace group{


class HXCPP_CLASS_ATTRIBUTES  FlxTypedGroupIterator_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxTypedGroupIterator_obj OBJ_;
		FlxTypedGroupIterator_obj();
		Void __construct(Dynamic GroupMembers,Dynamic filter);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxTypedGroupIterator_obj > __new(Dynamic GroupMembers,Dynamic filter);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxTypedGroupIterator_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("FlxTypedGroupIterator"); }

		Dynamic _groupMembers;
		Dynamic _filter;
		Dynamic &_filter_dyn() { return _filter;}
		int _cursor;
		int _length;
		virtual Dynamic next( );
		Dynamic next_dyn();

		virtual bool hasNext( );
		Dynamic hasNext_dyn();

};

} // end namespace flixel
} // end namespace group

#endif /* INCLUDED_flixel_group_FlxTypedGroupIterator */ 
