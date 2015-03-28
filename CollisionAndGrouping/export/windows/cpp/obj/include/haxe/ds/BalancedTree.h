#ifndef INCLUDED_haxe_ds_BalancedTree
#define INCLUDED_haxe_ds_BalancedTree

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(haxe,ds,BalancedTree)
HX_DECLARE_CLASS2(haxe,ds,TreeNode)
namespace haxe{
namespace ds{


class HXCPP_CLASS_ATTRIBUTES  BalancedTree_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef BalancedTree_obj OBJ_;
		BalancedTree_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< BalancedTree_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~BalancedTree_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("BalancedTree"); }

		::haxe::ds::TreeNode root;
		virtual Void set( Dynamic key,Dynamic value);
		Dynamic set_dyn();

		virtual Dynamic get( Dynamic key);
		Dynamic get_dyn();

		virtual ::haxe::ds::TreeNode setLoop( Dynamic k,Dynamic v,::haxe::ds::TreeNode node);
		Dynamic setLoop_dyn();

		virtual ::haxe::ds::TreeNode balance( ::haxe::ds::TreeNode l,Dynamic k,Dynamic v,::haxe::ds::TreeNode r);
		Dynamic balance_dyn();

		virtual int compare( Dynamic k1,Dynamic k2);
		Dynamic compare_dyn();

};

} // end namespace haxe
} // end namespace ds

#endif /* INCLUDED_haxe_ds_BalancedTree */ 
