package flixel.system;

import haxe.macro.TypeTools;
#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

class BufferMacro
{
	public static function build(isVector:Bool, includeGetters = true):ComplexType
	{
		final local = Context.getLocalType();
		switch local {
			// Extract the type parameter
			case TInst(local, [type]):
				return buildBuffer(getFields(type, includeGetters), type, isVector);
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
	
	static function buildBuffer(fields:Array<ClassField>, type:Type, isVector:Bool)
	{
		// Sort fields by pos to ensure order is maintained (weird that this is needed)
		fields.sort((a, b)->a.pos.getInfos().max - b.pos.getInfos().max);
		
		// Distinguish getters from actual fields
		final getters:Array<ClassField> = fields.copy();
		var i = fields.length;
		while (i-- > 0)
		{
			// TODO: Prevent double adds for getters over typedef fields?
			final field = fields[i];
			if (field.kind.match(FVar(AccCall, _)))
			{
				fields.remove(field);
			}
		}
		
		// Generate unique name for each type
		final arrayType = fields[0].type;
		final arrayTypeName = getTypeName(arrayType);
		final prefix = (isVector ? "" : "Array_") + arrayTypeName + "_" + getTypeIdentifier(type);
		final name = "Buffer_" + prefix;
		final iterName = "BufferIterator_" + prefix;
		final kvIterName = "BufferKeyValueIterator_" + prefix;
		final complexType = type.toComplexType();
		
		// Check whether the generated type already exists
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
		
		// Make sure all fields use the same type
		for (i in 1...length)
		{
			if (arrayType.toString() != fields[i].type.toString())
			{
				throw 'Cannot build buffer for type: { ${fields.map((f)->f.type.toString()).join(", ")} }';
			}
		}
		
		// An easy way to instantiate the type from an index
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
				args: fields.map(function (f):FunctionArg return { type: f.type.toComplexType(), name: f.name }),
				expr:macro {
					$b{[for (field in fields)
					{
						macro this.push($i{field.name});
					}]}
					return length;
				}
			})
		}
		
		final bufferCt = TPath({pack: [], name: name});
		// Get the iterator complex types (which are actually created later)
		final iterCt = { name: iterName, pack: [] };
		final kvIterCt = { name: kvIterName, pack: [] };
		final itemTypeName = getTypeName(type);
		final arrayCT = arrayType.toComplexType();
		
		// define the buffer
		final def = macro class $name
		{
			static inline var FIELDS:Int = $v{length};
			
			/** The number of items in this buffer */
			public var length(get, never):Int;
			inline function get_length() return Std.int(this.length / FIELDS);
			
			public inline function new ()
			{
				$e{ isVector
					? macro this = new openfl.Vector()
					: macro this = []
				}
			}
			
			/** Fetches the item at the desired index */
			@:arrayAccess
			public inline function get(i:Int):$complexType
			{
				final iReal = i * FIELDS;
				return $e{objectDecl};
			}
			
			/** Fetches the item at the desired index */
			@:arrayAccess
			public inline function set(pos:Int, item:$complexType):$complexType
			{
				$b{[
					for (i=>field in fields)
					{
						final name = field.name;
						macro this[pos * FIELDS + $v{i}] = item.$name;
					}
				]}
				return item;
			}
			
			/**
			 * Adds the item at the end of this Buffer and returns the new length of this Array
			 * 
			 * This operation modifies this Array in place
			 * 
			 * `this.length` increases by `1`
			 */
			public overload extern inline function push(item:$complexType):Int
			{
				$b{[
					for (field in fields)
					{
						final name = field.name;
						macro this.push(item.$name);
					}
				]}
				return length;
			}
			
			/**
			 * Creates an item with the given values and adds it at the end of this Buffer and returns the new length of this Array
			 * 
			 * This operation modifies this Array in place
			 * 
			 * `this.length` increases by `1`
			 */
			// public overload extern inline function push($a{???}):Int
			// {
			// 	$b{[fields.map((f)->macro this.push($i{f.name}))]}
			// 	return length;
			// }
			
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
			* Inserts the element x at the position pos.
			* 
			* This operation modifies this Array in place.
			* 
			* The offset is calculated like so:
			* 
			* If pos exceeds this.length, the offset is this.length.
			* If pos is negative, the offset is calculated from the end of this Array, i.e. this.length + pos. If this yields a negative value, the offset is 0.
			* Otherwise, the offset is pos.
			* If the resulting offset does not exceed this.length, all elements from and including that offset to the end of this Array are moved one index ahead.
			*/
			public inline function insert(pos:Int, item:$complexType)
			{
				$b{[
					for (i=>field in fields)
					{
						final name = field.name;
						if (isVector)
						{
							macro this.insertAt(pos * FIELDS + $v{i}, item.$name);
						}
						else
						{
							macro this.insert(pos * FIELDS + $v{i}, item.$name);
						}
					}
				]}
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
				$e{isVector
					? macro this.length = length * FIELDS
					: macro this.resize(length * FIELDS)
				}
			}
			
			/**
			* Creates a shallow copy of the range of this Buffer, starting at and including pos,
			* up to but not including end.
			* 
			* This operation does not modify this Buffer.
			* 
			* The elements are not copied and retain their identity.
			* 
			* If end is omitted or exceeds this.length, it defaults to the end of this Buffer.
			* 
			* If pos or end are negative, their offsets are calculated from the end of this
			* Buffer by this.length + pos and this.length + end respectively. If this yields
			* a negative value, 0 is used instead.
			* 
			* If pos exceeds this.length or if end is less than or equals pos, the result is [].
			*/
			public inline function slice(pos:Int, ?end:Int):$bufferCt
			{
				return this.slice(pos * FIELDS, (end != null ? end : length) * FIELDS);
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
		
		// Generate unique doc, but with static example
		def.doc = 'An `${isVector ? "openfl.Vector" : "Array"}<$arrayTypeName>` disguised as an `Array<$itemTypeName>`.'
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
			+ "\nfor that reason it is recommended to use final vars"
			+ "\n- all retrieved items must be handled via inline functions to avoid ever actually"
			+ "\ninstantiating an anonymous structure. This includes `Std.string(item)`";
		
		// Add our overloaded push methods from before
		def.fields.push(pushEachFunc);
		
		for (i => field in getters)
		{
			final fieldName = field.name;
			final funcName = "get" + fieldName.charAt(0).toUpperCase() + fieldName.substr(1);
			// Create the field in another class (for easy reification) then move it over
			def.fields.push((macro class TempClass
			{
				/** Helper for `get(item).$name` */
				public inline function $funcName(index:Int)
				{
					return get(index).$fieldName;
				}
			}).fields[0]);
		}
		
		// `macro class` gives a TDClass, so that needs to be replaced
		// Determine our buffer's base
		final listType = (isVector ? macro:openfl.Vector<$arrayCT> : macro:Array<$arrayCT>);
		def.kind = TDAbstract(listType, [listType], [listType]);
		Context.defineType(def);
		
		// Make our iterator
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
		
		// Make our key-value iterator
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
		return bufferCt;
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

@:genericBuild(flixel.system.FlxBuffer.BufferMacro.build(true))
class FlxBuffer<T> {}

@:genericBuild(flixel.system.FlxBuffer.BufferMacro.build(false))
class FlxBufferArray<T> {}
#end