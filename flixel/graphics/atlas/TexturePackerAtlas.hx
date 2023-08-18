package flixel.graphics.atlas;

import flixel.graphics.atlas.AtlasBase;

typedef TexturePackerAtlasFrame = AtlasFrame &
{
	?duration:Int
}

typedef TexturePackerAtlasHash = AtlasBase<AtlasBase.Hash<TexturePackerAtlasFrame>>;
typedef TexturePackerAtlas = AtlasBase<HashOrArray<TexturePackerAtlasFrame>>;
typedef TexturePackerAtlasArray = AtlasBase<Array<TexturePackerAtlasFrame>>;
