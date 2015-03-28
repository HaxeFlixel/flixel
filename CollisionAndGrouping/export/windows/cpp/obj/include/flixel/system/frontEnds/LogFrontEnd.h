#ifndef INCLUDED_flixel_system_frontEnds_LogFrontEnd
#define INCLUDED_flixel_system_frontEnds_LogFrontEnd

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,debug,LogStyle)
HX_DECLARE_CLASS3(flixel,system,frontEnds,LogFrontEnd)
namespace flixel{
namespace system{
namespace frontEnds{


class HXCPP_CLASS_ATTRIBUTES  LogFrontEnd_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef LogFrontEnd_obj OBJ_;
		LogFrontEnd_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< LogFrontEnd_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~LogFrontEnd_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("LogFrontEnd"); }

		bool redirectTraces;
		Dynamic _standardTraceFunction;
		virtual Void add( Dynamic Data);
		Dynamic add_dyn();

		virtual Void warn( Dynamic Data);
		Dynamic warn_dyn();

		virtual Void error( Dynamic Data);
		Dynamic error_dyn();

		virtual Void notice( Dynamic Data);
		Dynamic notice_dyn();

		virtual Void advanced( Dynamic Data,::flixel::system::debug::LogStyle Style,hx::Null< bool >  FireOnce);
		Dynamic advanced_dyn();

		virtual Void clear( );
		Dynamic clear_dyn();

		virtual bool set_redirectTraces( bool Redirect);
		Dynamic set_redirectTraces_dyn();

		virtual Void processTraceData( Dynamic Data,Dynamic Info);
		Dynamic processTraceData_dyn();

};

} // end namespace flixel
} // end namespace system
} // end namespace frontEnds

#endif /* INCLUDED_flixel_system_frontEnds_LogFrontEnd */ 
