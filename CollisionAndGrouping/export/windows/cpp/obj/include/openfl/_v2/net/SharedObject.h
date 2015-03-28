#ifndef INCLUDED_openfl__v2_net_SharedObject
#define INCLUDED_openfl__v2_net_SharedObject

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/events/EventDispatcher.h>
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,net,SharedObject)
HX_DECLARE_CLASS2(openfl,net,SharedObjectFlushStatus)
namespace openfl{
namespace _v2{
namespace net{


class HXCPP_CLASS_ATTRIBUTES  SharedObject_obj : public ::openfl::_v2::events::EventDispatcher_obj{
	public:
		typedef ::openfl::_v2::events::EventDispatcher_obj super;
		typedef SharedObject_obj OBJ_;
		SharedObject_obj();
		Void __construct(::String name,::String localPath,Dynamic data);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< SharedObject_obj > __new(::String name,::String localPath,Dynamic data);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~SharedObject_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("SharedObject"); }

		Dynamic data;
		int size;
		::String localPath;
		::String name;
		virtual Void clear( );
		Dynamic clear_dyn();

		virtual Void close( );
		Dynamic close_dyn();

		virtual ::openfl::net::SharedObjectFlushStatus flush( hx::Null< int >  minDiskSpace);
		Dynamic flush_dyn();

		virtual Void setProperty( ::String propertyName,Dynamic value);
		Dynamic setProperty_dyn();

		virtual int get_size( );
		Dynamic get_size_dyn();

		static Void mkdir( ::String directory);
		static Dynamic mkdir_dyn();

		static ::String getFilePath( ::String name,::String localPath);
		static Dynamic getFilePath_dyn();

		static ::openfl::_v2::net::SharedObject getLocal( ::String name,::String localPath,hx::Null< bool >  secure);
		static Dynamic getLocal_dyn();

		static ::Class resolveClass( ::String name);
		static Dynamic resolveClass_dyn();

};

} // end namespace openfl
} // end namespace _v2
} // end namespace net

#endif /* INCLUDED_openfl__v2_net_SharedObject */ 
