package flixel.overlap;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxLinkedList;

class FlxOverlap {
	
	public static var listA : FlxLinkedList = null;
	public static var listB : FlxLinkedList = null;
	
	private static var A_LIST : Int = 0;
	private static var B_LIST : Int = 1;
	
	/**
	 * Call this function to see if one FlxObject's hitbox overlaps another one's hitbox.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 * NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with FlxOverlapData parameter - e.g. myOverlapFunction(overlapData : FlxOverlapData) - that is called if two objects overlap.
	 * @param	ProcessCallback	A function with FlxOverlapData parameter - e.g. myOverlapFunction(overlapData : FlxOverlapData) - that is called if two objects overlap.  If a ProcessCallback is provided, then NotifyCallback will only be called if ProcessCallback returns true for those objects!
	 * @return	Whether any overlaps were detected.
	 */
	public static function hitboxOverlap(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:FlxOverlapData->Void, ?ProcessCallback:FlxOverlapData->Bool):Bool
	{
		add(ObjectOrGroup1, A_LIST);
		if (ObjectOrGroup2 != null)
			add(ObjectOrGroup2, B_LIST);
		
		var listAIterator : FlxLinkedList = listA;
		var listBIterator : FlxLinkedList;
		if (listB != null)
			listBIterator = listB
		else
			if (listA.next != null)
				listBIterator = listA.next;
			else
				listBIterator = null;
		
		var overlapData : FlxOverlapData = new FlxOverlapData();
		var result = false;
		
		while (listAIterator != null)
		{
			var spriteA : FlxSprite = cast listAIterator.object;
			if (spriteA != null && spriteA.hitbox != null)
			{
				while (listBIterator != null)
				{
					var spriteB : FlxSprite = cast listBIterator.object;
					if (spriteB != null && spriteB.hitbox != null)
					{
						if (spriteA.hitbox.test(spriteB.hitbox, overlapData))
						{
							if ((ProcessCallback == null || ProcessCallback(overlapData)) && NotifyCallback != null)
								NotifyCallback(overlapData);
							result = true;
						}
					}
					listBIterator = listBIterator.next;
				}
				if(listB != null)
					listBIterator = listB;
				else if (listAIterator.next != null)
					listBIterator = listAIterator.next.next;
				else
					listBIterator = null;
			}
			listAIterator = listAIterator.next;
		}
		
		while (listA != null)
		{
			var temp = listA.next;
			listA.destroy();
			listA = temp;
		}
		
		while (listB != null)
		{
			var temp = listB.next;
			listB.destroy();
			listB = temp;
		}
		
		return result;
	}
	
	public static function castRay(ray : FlxRay, ObjectorGroup : FlxBasic, ?rayData : FlxRayData) : Bool
	{
		add(ObjectorGroup, A_LIST);
		var listIterator : FlxLinkedList = listA;
		var result = false;
		var tempRay : FlxRayData = null;
		if (rayData != null)
		{
			tempRay = new FlxRayData();
			rayData.start = Math.POSITIVE_INFINITY;
		}
			
		
		while (listIterator != null)
		{
			var sprite : FlxSprite = cast listIterator.object;
			if (sprite != null && sprite.hitbox != null)
			{
				if (sprite.hitbox.testRay(ray, tempRay))
				{
					if (rayData == null)
						return true;
					else
					{
						result = true;
						if (tempRay.start < rayData.start)
						{
							rayData.start = tempRay.start;
							rayData.end = tempRay.end;
							rayData.hitbox = tempRay.hitbox;
						}
					}
				}
			}
			listIterator = listIterator.next;
		}
		
		while (listA != null)
		{
			var temp = listA.next;
			listA.destroy();
			listA = temp;
		}
		
		return result;
	}
	
	private static function add (ObjectOrGroup:FlxBasic, ListID : Int)
	{	
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null)
		{
			for (basic in group.members)
			{
				if (basic != null && basic.exists)
				{
					group = FlxTypedGroup.resolveGroup(basic);
					if (group != null)
					{
						add(group, ListID);
					}
					else
					{
						var object = cast(basic, FlxObject);
						if (object.exists)
						{
							var node = FlxLinkedList.recycle();
							node.object = object;
							if (ListID == A_LIST)
							{
								node.next = listA;
								listA = node;
							}
							else
							{
								node.next = listB;
								listB = node;
							}
						}
					}
				}
			}
		}
		else
		{
			var object = cast(ObjectOrGroup, FlxObject);
			if (object.exists)
			{
				var node = FlxLinkedList.recycle();
				node.object = object;
				if (ListID == A_LIST)
				{
					node.next = listA;
					listA = node;
				}
				else
				{
					node.next = listB;
					listB = node;
				}
			}
		}
	}
}