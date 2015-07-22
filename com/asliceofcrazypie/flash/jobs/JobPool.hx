package com.asliceofcrazypie.flash.jobs;

import flash.display.BlendMode;

/**
 * ...
 * @author Zaphod
 */
class JobPool<T>
{
	public static inline var NUM_JOBS_TO_POOL:Int = 25;
	
	private var _class:Class<T>;
	private var _pool:Array<T>;
	
	public function new(classObj:Class<T>) 
	{
		_class = classObj;
		init();
	}
	
	public function getJob():T
	{
		var job:T = (_pool.length > 0) ? _pool.pop() : Type.createInstance(_class, []);
		return job;
	}
	
	public inline function returnJob(renderJob:T):Void
	{
		_pool.push(renderJob);
	}
	
	public function init():Void
	{
		_pool = new Array<T>();
		for (i in 0...JobPool.NUM_JOBS_TO_POOL)
		{
			_pool.push(Type.createInstance(_class, []));
		}
	}
	
}