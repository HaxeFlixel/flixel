#ifndef INCLUDED_openfl__v2_utils_IMemoryRange
#define INCLUDED_openfl__v2_utils_IMemoryRange

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
namespace openfl{
namespace _v2{
namespace utils{


class HXCPP_CLASS_ATTRIBUTES  IMemoryRange_obj : public hx::Interface{
	public:
		typedef hx::Interface super;
		typedef IMemoryRange_obj OBJ_;
		HX_DO_INTERFACE_RTTI;
		static void __boot();
virtual ::openfl::_v2::utils::ByteArray getByteBuffer( )=0;
		Dynamic getByteBuffer_dyn();
virtual int getStart( )=0;
		Dynamic getStart_dyn();
virtual int getLength( )=0;
		Dynamic getLength_dyn();
};

#define DELEGATE_openfl__v2_utils_IMemoryRange \
virtual ::openfl::_v2::utils::ByteArray getByteBuffer( ) { return mDelegate->getByteBuffer();}  \
virtual Dynamic getByteBuffer_dyn() { return mDelegate->getByteBuffer_dyn();}  \
virtual int getStart( ) { return mDelegate->getStart();}  \
virtual Dynamic getStart_dyn() { return mDelegate->getStart_dyn();}  \
virtual int getLength( ) { return mDelegate->getLength();}  \
virtual Dynamic getLength_dyn() { return mDelegate->getLength_dyn();}  \


template<typename IMPL>
class IMemoryRange_delegate_ : public IMemoryRange_obj
{
	protected:
		IMPL *mDelegate;
	public:
		IMemoryRange_delegate_(IMPL *inDelegate) : mDelegate(inDelegate) {}
		hx::Object *__GetRealObject() { return mDelegate; }
		void __Visit(HX_VISIT_PARAMS) { HX_VISIT_OBJECT(mDelegate); }
		DELEGATE_openfl__v2_utils_IMemoryRange
};

} // end namespace openfl
} // end namespace _v2
} // end namespace utils

#endif /* INCLUDED_openfl__v2_utils_IMemoryRange */ 
