#ifndef INCLUDED_Xml
#define INCLUDED_Xml

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(Type)
HX_DECLARE_CLASS0(Xml)
HX_DECLARE_CLASS0(XmlType)


class HXCPP_CLASS_ATTRIBUTES  Xml_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Xml_obj OBJ_;
		Xml_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Xml_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Xml_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		static void __init__();

		::String __ToString() const { return HX_CSTRING("Xml"); }

		::String _nodeName;
		::String _nodeValue;
		Dynamic _attributes;
		Array< ::Dynamic > _children;
		::Xml _parent;
		::XmlType nodeType;
		virtual ::String get_nodeName( );
		Dynamic get_nodeName_dyn();

		virtual ::String get( ::String att);
		Dynamic get_dyn();

		virtual bool exists( ::String att);
		Dynamic exists_dyn();

		virtual Dynamic elements( );
		Dynamic elements_dyn();

		virtual Dynamic elementsNamed( ::String name);
		Dynamic elementsNamed_dyn();

		virtual ::Xml firstElement( );
		Dynamic firstElement_dyn();

		virtual Void addChild( ::Xml x);
		Dynamic addChild_dyn();

		static ::XmlType Element;
		static ::XmlType PCData;
		static ::XmlType CData;
		static ::XmlType Comment;
		static ::XmlType DocType;
		static ::XmlType ProcessingInstruction;
		static ::XmlType Document;
		static Dynamic _parse;
		static Dynamic &_parse_dyn() { return _parse;}
		static ::Xml parse( ::String str);
		static Dynamic parse_dyn();

};


#endif /* INCLUDED_Xml */ 
