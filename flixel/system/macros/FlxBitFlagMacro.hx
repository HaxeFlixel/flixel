package flixel.system.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Tools;
using haxe.macro.TypeTools;

class FlxBitFlagMacro
{
	macro static public function buildBits():Array<Field>
	{
		final fields = Context.getBuildFields();
		
		var bit = 1;
		final bitFields = new Array<Field>();
		final specialMethods = new Map<String, Field>();
		final specialMethodsList = ['iterator', 'toString'];
		for (i=>field in fields)
		{
			switch field.kind
			{
				case FVar(null, null):
					bitFields.push(field);
					bit = bit << 1;
				case FFun(_) if (specialMethodsList.contains(field.name)):
					specialMethods[field.name] = field;
				case _:
			}
		}
		
		final digits = StringTools.hex(bit >> 1).length;
		bit = 1;
		for (field in bitFields)
		{
			final name = field.name;
			final value:Expr = { expr:EConst(CInt('0x' + bit.hex(digits))), pos:Context.currentPos() };
			field.kind = (macro class TempClass
			{
				var $name = $value;
			}).fields[0].kind;
			
			bit = bit << 1;
		}
		
		final local = Context.getLocalType();
		switch local
		{
			// Extract the type parameter
			case TInst(_.get()=>type, _):
				switch type.kind
				{
					case KAbstractImpl(_.get()=>type):
						// final localCT = TPath({ name: type.name, pack: type.pack});
						final localCT = TPath({ name: type.name, pack: type.pack});
						if (specialMethods.exists("iterator") == false)
						{
							final iterator = buildBitsIterator(type, bitFields);
							// final iterCT = (macro:flixel.graphics.frames.slice.FlxSliceSection.FlxSliceSectionIterator);
							// final iterCT = TPath(iterator);
							// final flags = buildFlags(type, bitFields);
							final newFields = (macro class TempClass
							{
								static public inline function iterator()//:$iterCT
								{
									final result = new $iterator();
									// $type(result);
									return result;
								}
								
							}).fields;
							
							for (field in newFields)
								fields.push(field);
						}
						
						if (specialMethods.exists("toString") == false)
						{
							final cases:Array<Case> = bitFields.map(function (f):Case
							{
								final name = f.name;
								return { values:[macro $i{name}], expr: macro $v{name}};
							});
							
							cases.push({ values:[macro _], expr: macro ""});
							
							// #if (haxe >= version("4.3.0"))
							// final eSwitch:Expr = { expr: ESwitch(macro abstract, cases, null), pos: Context.currentPos() };
							// #else
							// #error "Need to fix this";
							final eSwitch:Expr = { expr: ESwitch(macro ((cast this:$localCT)), cases, null), pos: Context.currentPos() };
							// #end
							
							final field = (macro class TempClass
							{
								public function toString()
								{
									return $eSwitch;
								}
							}).fields[0];
							fields.push(field);
						}
						
					case found:
						throw 'Expected abstract(Int), found: $found';
				}
			case found:
				throw 'Expected TInst, found: $found';
		}
		
		return fields;
	}
	
	macro static public function genericBuildFlags():ComplexType
	{
		final localType = Context.getLocalType();
		return switch localType
		{
			// Extract the type parameter
			case TInst(_, [TAbstract(_.get()=>ab, _)]) if (ab.meta.has(":enum")):
				
				
				// Check whether the generated type already exists
				try
				{
					return Context.getType(ab.name + "Flags").toComplexType();
				}
				catch (e)
				{
					trace(ab.impl.get().statics.get()); // use this to populate
					throw "Internal build order error: The generated type doesn't exist yet";
				}
				
				null;
			case TInst(_, [found]):
				throw 'Expected type param to be an enum abstract, found: $found';
			case found:
				throw 'Expected flixel.util.FlxBits<T> where T is an enum abstract, found: $found';
		}
	}
	
	#if macro
	static function buildBitsIterator(type:AbstractType, bitFields:Array<Field>):TypePath
	{
		final name = '${type.name}Iterator';
		// final path = { pack: type.pack, sub: name, name: type.module.split(".").pop() };
		// final path:TypePath = { pack: type.pack, name: type.name, sub: name };
		final path:TypePath = { pack: [], name: name };
		// Check whether the generated type already exists
		try
		{
			Context.getType('${name}');
			
			// Return a `ComplexType` for the generated type
			return path;
		}
		catch (e) {} // The generated type doesn't exist yet
		
		final length = bitFields.length;
		// define the type
		final names = bitFields.map((f)->macro $p{[type.name, f.name]});
		final def = (macro class $name
		{
			static final order = [$a{names}];
			static inline var LENGTH = $v{length};
			var iter:IntIterator;
			
			public inline function new() { this.iter = 0...LENGTH; }
			
			public inline function hasNext() { return iter.hasNext(); }
			
			public inline function next() { return order[iter.next()]; }
		});
		
		def.pack = type.pack;
		Context.defineType(def, type.module);
		return path;
	}
	
	static function buildFlags(type:AbstractType, bitFields:Array<Field>):TypePath
	{
		final name = '${type.name}Flags';
		// final path = { pack: type.pack, sub: name, name: type.module.split(".").pop() };
		final path:TypePath = { pack: type.pack, name: name };
		// Check whether the generated type already exists
		try
		{
			Context.getType(name);
			
			// Return a `ComplexType` for the generated type
			return path;
		}
		catch (e) {} // The generated type doesn't exist yet
		
		final bitsCT = TPath({ pack: type.pack, name: type.module.split(".").pop(), sub: type.name });
		final flagsCT = (macro: flixel.util.FlxBits<$bitsCT>);//TPath(path);
		final bitsPath = [type.module, type.name];
		// define the type
		final def = (macro class $name
		{
			inline public function new ()
			{
				this = 0;
			}
			
			/**
			 * Returns true if this contains **all** of the supplied flags.
			 */
			public inline function has(bits:$flagsCT):Bool
			{
				return this & bits.toInt() == bits.toInt();
			}
			
			/**
			 * Returns true if this contains **any** of the supplied flags.
			 */
			public inline function hasAny(bits:$flagsCT)
			{
				return this & bits.toInt() > 0;
			}
			
			public inline function with(bits:$flagsCT)
			{
				return fromInt(this | bits.toInt());
			}
			
			public inline function without(bits:$flagsCT)
			{
				return fromInt(this & ~bits.toInt());
			}
			
			public function toString()
			{
				final bits = [];
				for (bit in $p{bitsPath})
				{
					if (has(bit))
						bits.push(bit.toString());
				}
				
				return bits.join(" | ");
			}
			
			inline function toInt():Int
			{
				return this;
			}
			
			inline static function fromInt(value:Int):$flagsCT
			{
				return cast value;
			}
			
			@:from
			inline static function fromBits(value:$bitsCT)
			{
				return fromInt((cast value:Int));
			}
			
			// @:op(A | B) static function or(a:$flagsCT, b:$flagsCT):$flagsCT;
			
			// @:commutative
			// @:op(A | B) static function orBits(a:$flagsCT, b:$bitsCT):$flagsCT
			// {
			// 	return fromInt(a.toInt() | (cast b:Int));
			// }
		});
		
		for (field in bitFields)
		{
			// trace(field);
			final name = field.name.toLowerCase();
			final getterName = 'get_$name';
			final setterName = 'set_$name';
			final doc = field.doc;
			final newFields = (macro class TempClass
			{
				public var $name(get, set):Bool;
				
				inline function $getterName():Bool
				{
					return has($i{field.name});
				}
				
				inline function $setterName(value:Bool):Bool
				{
					this = (value ? with($i{field.name}).toInt() : without($i{field.name}).toInt());
					return value;
				}
			}).fields;
			
			newFields[0].doc = field.doc;
			
			// for (field in newFields)
			// 	def.fields.push(field);
		}
		
		def.kind = TDAbstract((macro: Int), null, [], []);
		Context.defineType(def);
		return path;
	}
	#end
}