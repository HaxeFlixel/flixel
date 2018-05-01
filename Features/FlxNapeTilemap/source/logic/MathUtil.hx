package logic;

class MathUtil
{
	public static function sortRandomly<T>(collection:Array<T>)
	{
		collection.sort(fakeRandomCompare);
	}

	static function fakeRandomCompare<T>(x:T, y:T)
	{
		return if (Math.random() < 0.5) -1 else 1;
	}
}