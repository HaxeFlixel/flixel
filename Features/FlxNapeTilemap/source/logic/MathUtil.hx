package logic;

@:final
class MathUtil
{
    public static function sortRandomly<T>(collection:Array<T>)
    {
        collection.sort(FakeRndCmp);
    }

    private static function FakeRndCmp<T>(x: T, y: T)
    {
        return if (Math.random()<0.5) -1 else 1;
    }
}