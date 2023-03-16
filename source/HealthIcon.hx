package;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var char:String = '';
	var isPlayer:Bool = false;
	var iconData:Array<String>;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function changeIcon(newChar:String):Void
	{
		if (newChar != 'bf-pixel' && newChar != 'bf-old')
			newChar = newChar.split('-')[0].trim();

		if (newChar != char)
		{
			if (animation.getByName(newChar) == null)
			{
                if (Assets.exists('assets/images/icons/icon-$newChar.png'))
				    loadGraphic('assets/images/icons/icon-$newChar.png', true, 150, 150);
                else
                    loadGraphic('assets/images/icons/icon-face.png', true, 150, 150);
			}

			if (Assets.exists('assets/images/icons/icon-$newChar.png') && Assets.exists('assets/images/icons/icon-$newChar.xml'))
				frames = FlxAtlasFrames.fromSparrow('assets/images/icons/icon-$newChar.png', 'assets/images/icons/icon-$newChar.xml');

			if (Assets.exists('assets/images/icons/icon-$newChar.xml'))
				iconData = CoolUtil.loadText('assets/images/icons/icon-$newChar.txt');

			if (!Assets.exists('assets/images/icons/icon-$newChar.xml')){
				animation.add(newChar, [0, 1], 0, false, isPlayer);

				animation.play(newChar);
			}else{
				if (options.OptionsConfigs.iconAnimed)
					animation.addByPrefix(iconData[0], iconData[0], Std.parseInt(iconData[1]));
				else
					animation.addByIndices(iconData[0], iconData[0], [0], '.png');

				animation.play(iconData[0], true);
			}
			char = newChar;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}