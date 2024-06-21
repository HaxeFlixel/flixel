package flixel.system;

import haxe.macro.TypeTools;
#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

class BufferMacro
{
	public static function build(includeGetters = true):ComplexType
	{
		final local = Context.getLocalType();
		switch local {
			// Extract the type parameter
			case TInst(local, [type]):
				return buildBuffer(getFields(type, includeGetters), type);
			default:
				throw "Expected TInst";
		}
	}
	
	static function getFields(type:Type, includeGetters:Bool):Array<ClassField>
	{
		// Follow it to get the underlying anonymous structure
		switch type.follow()
		{
			case TAbstract(abType, []):
				final fields = getFields(abType.get().type, includeGetters).copy();
				// add abstract fields too
				if (includeGetters && (abType.get().impl != null || abType.get().impl.get() != null))
				{
					final statics = abType.get().impl.get().statics.get();
					for (field in statics)
					{
						if (field.kind.match(FVar(AccCall, _)))
						{
							fields.push(field);
						}
					}
				}
				return fields;
			case TAnonymous(type):
				return type.get().fields;
			case TInst(found, _):
				throw 'Expected type parameter to be an anonymous structure, got ${found.get().name}';
			case TEnum(found, _):
				throw 'Expected type parameter to be an anonymous structure, got ${found.get().name}';
			case found:
				throw 'Expected type parameter to be an anonymous structure, got ${found.getName()}';
		}
	}
	
	static function buildBuffer(fields:Array<ClassField>, type:Type)
	{
		// Distinguish getters from actual fields
		final getters:Array<ClassField> = fields.copy();
		var i = fields.length;
		while (i-- > 0)
		{
			// todo: Prevent double adds for getters over
			final field = fields[i];
			if (field.kind.match(FVar(AccCall, _)))
			{
				fields.remove(field);
			}
		}
		
		final arrayType = fields[0].type;
		final arrayTypeName = getTypeName(arrayType);
		final prefix = arrayTypeName + "_" + getTypeIdentifier(type);
		final name = "Buffer_" + prefix;
		final iterName = "BufferIterator_" + prefix;
		final kvIterName = "BufferKeyValueIterator_" + prefix;
		final complexType = type.toComplexType();
		
		// First check whether the generated type already exists
		try
		{
			Context.getType(name);
			Context.getType(iterName);
			Context.getType(kvIterName);
			
			// Return a `ComplexType` for the generated type
			return TPath({pack: [], name: name});
		}
		catch (e) {} // The generated type doesn't exist yet
		
		final length = fields.length;
		if (length < 2)
			throw "Just use an array";
		
		for (i in 1...length)
		{
			if (arrayType.toString() != fields[i].type.toString())
			{
				throw 'Cannot build buffer for type: { ${fields.map((f)->f.type.toString()).join(", ")} }';
			}
		}
		
		final objectDecl:Expr =
		{
			pos: Context.currentPos(),
			expr: EObjectDecl([
				for (i => field in fields)
				{
					{
						field: field.name,
						expr: macro this[iReal + $v{i}],
					}
				}
			])
		}
		
		final pushEachBody =
		[
			for (field in fields)
			{
				macro this.push($i{field.name});
			}
		];
		pushEachBody.push(macro return length);
		final pushEachFunc:Field =
		{
			doc:"Creates an item with the given values and adds it at the end of this Buffer and returns the new length of this Array.\n\n"
				+ "This operation modifies this Array in place.\n\n"
				+ "this.length increases by 1.",
			pos: Context.currentPos(),
			name: "push",
			access: [APublic, AOverload, AExtern, AInline],
			kind:FFun
			({
				args:
				[
					for (field in fields)
					{
						{
							type: field.type.toComplexType(),
							name: field.name
						}
					}
				],
				expr:macro $b{pushEachBody}
			})
		}
		
		final pushItemBody =
		[
			for (field in fields)
			{
				final name = field.name;
				macro this.push(item.$name);
			}
		];
		pushItemBody.push(macro return length);
		
		final pushItemFunc:Field =
		{
			doc:"Adds the item at the end of this Buffer and returns the new length of this Array.\n\n"
				+ "This operation modifies this Array in place.\n\n"
				+ "this.length increases by 1.",
			pos: Context.currentPos(),
			name: "push",
			access: [APublic, AOverload, AExtern, AInline],
			kind:FFun
			({
				args: [{name: "item", type: complexType}],
				expr:macro $b{pushItemBody}
			})
		}
		
		final iterCt = { name: iterName, pack: [] };
		final kvIterCt = { name: kvIterName, pack: [] };
		
		final def = macro class $name
		{
			static inline var FIELDS:Int = $v{length};
			
			/** The number of items in this buffer */
			public var length(get, never):Int;
			inline function get_length() return Std.int(this.length / FIELDS);
			
			public inline function new ()
			{
				this = new openfl.Vector();
			}
			
			/** Fetches the item at the desired index */
			@:arrayAccess
			public inline function get(i:Int):$complexType
			{
				final iReal = i * FIELDS;
				return $e{objectDecl};
			}
			
			/** Removes and returns the first item */
			public inline function shift():$complexType
			{
				final iReal = 0;
				final item = $e{objectDecl};
				$b{[
					for (field in fields)
					{
						macro this.shift();
					}
				]}
				return item;
			}
			
			/** Removes and returns the last item */
			public inline function pop():$complexType
			{
				final iReal = this.length - FIELDS;
				final item = $e{objectDecl};
				$b{[
					for (field in fields)
					{
						macro this.pop();
					}
				]}
				return item;
			}
			
			/**
			 * Set the length of the Array.
			 * If len is shorter than the array's current size, the last length - len elements will
			 * be removed. If len is longer, the Array will be extended
			 * 
			 * **Note:** Since FlxBuffers are actually Arrays of some primitive, often `Float`, it
			 * will likely add all zeros
			 * 
			 * @param   length  The desired length
			 */
			public inline function resize(length:Int)
			{
				this.length = length * FIELDS;
			}
			
			/** Returns an iterator of the buffer's items */
			public inline function iterator()
			{
				return new $iterCt(this);
			}
			
			/** Returns an iterator of the buffer's indices and items */
			public inline function keyValueIterator()
			{
				return new $kvIterCt(this);
			}
		};
		
		def.fields.push(pushEachFunc);
		def.fields.push(pushItemFunc);
		for (i => field in getters)
		{
			final getter:Field =
			{
				pos: Context.currentPos(),
				name: "get" + field.name.charAt(0).toUpperCase() + field.name.substr(1),
				access: [APublic, AInline],
				kind:FFun
				({
					args: [{name: "index", type: (macro:Int)}],
					expr:macro this[index * FIELDS + $v{i}]
				})
			};
			def.fields.push(getter);
		}
		
		final itemTypeName = getTypeName(type);
		def.doc = 'An `openfl.Vector<$arrayTypeName>` disguised as an `Array<$itemTypeName>`.'
			+ "\nOften used in under-the-hood Flixel systems, like rendering,"
			+ "\nwhere creating actual instances of objects every frame would balloon memory."
			+ "\n"
			+ "\n## Example"
			+ "\nIn the following example, see how it behaves quite similar to an Array"
			+ "\n```haxe"
			+ "\n	var buffer = new FlxBuffer<{final x:Float; final y:Float;}>();"
			+ "\n	for (i in 0...100)"
			+ "\n		buffer.push({ x: i % 10, y: Std.int(i / 10) });"
			+ "\n	"
			+ "\n	buffer.shift();"
			+ "\n	buffer.pop();"
			+ "\n	"
			+ "\n	for (i=>item in buffer)"
			+ "\n	{"
			+ "\n		trace('$i: $item');"
			+ "\n	}"
			+ "\n```"
			+ "\n"
			+ "\n## Caveats"
			+ "\n- Can only be modified via `push`, `pop`, `shift` and `resize`. Missing notable"
			+ "\nfeatures like `insert` and setting via array access operator, these can be"
			+ "\nimplemented but are low priority"
			+ "\n- Editing items retrieved from the buffer will not edit the corresponding indicies,"
			+ "\nfor that reason it is recommended to use final vars";
		// `macro class` gives a TDClass, so that needs to be replaced
		final arrayCT = arrayType.toComplexType();
		def.kind = TDAbstract((macro:openfl.Vector<$arrayCT>), [macro:openfl.Vector<$arrayCT>], [macro:openfl.Vector<$arrayCT>]);
		Context.defineType(def);
		
		final bufferCt = Context.getType(name).toComplexType();
		final iterDef = macro class $iterName
		{
			var list:$bufferCt;
			var length:Int;
			var i:Int;
			
			inline public function new(list:$bufferCt)
			{
				this.list = list;
				this.length = list.length;
				i = 0;
			}
			
			inline public function hasNext()
			{
				return i < length;
			}
			
			inline public function next()
			{
				return list[i++];
			}
		}
	
		// `macro class` gives a TDClass, so that needs to be replaced
		// iterDef.kind = TDClass(null, [], false, false, false);
		Context.defineType(iterDef);
		
		final kvIterDef = macro class $kvIterName
		{
			var list:$bufferCt;
			var length:Int;
			var i:Int;
			
			inline public function new(list:$bufferCt)
			{
				this.list = list;
				this.length = list.length;
				i = 0;
			}
			
			inline public function hasNext()
			{
				return i < length;
			}
			
			inline public function next()
			{
				final key = i++;
				return { key:key, value:list.get(key) };
			}
		}
	
		// `macro class` gives a TDClass, so that needs to be replaced
		// iterDef.kind = TDClass(null, [], false, false, false);
		Context.defineType(kvIterDef);
		
		// Return a `ComplexType` for the generated type
		return TPath({pack: [], name: name});
	}
	
	static function getTypeIdentifier(type:Type)
	{
		return switch(type)
		{
			case TAnonymous(type): type.get().fields.map((f)->'${f.name}').join("_");
			default: getTypeName(type);
		}
	}
	
	static function getTypeName(type:Type)
	{
		return switch(type)
		{
			case TAbstract(type, []): type.get().name;
			case TAnonymous(type): 
				'{ ${type.get().fields.map((f)->'${f.name}: ${getTypeName(f.type)}').join(", ")} }';
			case TInst(type, []): type.get().name;
			case TType(type, []): type.get().name;
			default: type.getName();
		}
	}
}
#else

@:genericBuild(flixel.system.FlxBuffer.BufferMacro.build())
class FlxBuffer<T> {}
#end