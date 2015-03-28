#ifndef INCLUDED_openfl__v2_filesystem_File
#define INCLUDED_openfl__v2_filesystem_File

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,filesystem,File)
namespace openfl{
namespace _v2{
namespace filesystem{


class HXCPP_CLASS_ATTRIBUTES  File_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef File_obj OBJ_;
		File_obj();
		Void __construct(::String path);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< File_obj > __new(::String path);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~File_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("File"); }

		::String nativePath;
		::String url;
		virtual ::String set_nativePath( ::String value);
		Dynamic set_nativePath_dyn();

		virtual ::String set_url( ::String value);
		Dynamic set_url_dyn();

		static ::openfl::_v2::filesystem::File applicationDirectory;
		static ::openfl::_v2::filesystem::File applicationStorageDirectory;
		static ::openfl::_v2::filesystem::File desktopDirectory;
		static ::openfl::_v2::filesystem::File documentsDirectory;
		static ::openfl::_v2::filesystem::File userDirectory;
		static int APP;
		static int STORAGE;
		static int DESKTOP;
		static int DOCS;
		static int USER;
		static ::openfl::_v2::filesystem::File get_applicationDirectory( );
		static Dynamic get_applicationDirectory_dyn();

		static ::openfl::_v2::filesystem::File get_applicationStorageDirectory( );
		static Dynamic get_applicationStorageDirectory_dyn();

		static ::openfl::_v2::filesystem::File get_desktopDirectory( );
		static Dynamic get_desktopDirectory_dyn();

		static ::openfl::_v2::filesystem::File get_documentsDirectory( );
		static Dynamic get_documentsDirectory_dyn();

		static ::openfl::_v2::filesystem::File get_userDirectory( );
		static Dynamic get_userDirectory_dyn();

		static Dynamic lime_filesystem_get_special_dir;
		static Dynamic &lime_filesystem_get_special_dir_dyn() { return lime_filesystem_get_special_dir;}
};

} // end namespace openfl
} // end namespace _v2
} // end namespace filesystem

#endif /* INCLUDED_openfl__v2_filesystem_File */ 
