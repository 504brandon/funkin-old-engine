package handlers;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite {
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var char:String = '';

	var isPlayer:Bool = false;
	var iconData:Array<String>;

	public function new(char:String = 'bf', isPlayer:Bool = false) {
		super();

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function changeIcon(path:String):Void {
		if (path != char) {
			if (animation.getByName(path) == null) {
				if (Assets.exists('assets/images/$path.png'))
					loadGraphic('assets/images/$path.png', true, 150, 150);
				else
					loadGraphic('assets/images/face.png', true, 150, 150);
			}

			if (Assets.exists('assets/images/$path.png') && Assets.exists('assets/images/$path.xml'))
				frames = FlxAtlasFrames.fromSparrow('assets/images/$path.png', 'assets/images/$path.xml');

			if (Assets.exists('assets/images/$path.xml'))
				iconData = CoolUtil.loadText('assets/images/$path.txt');

			if (!Assets.exists('assets/images/$path.xml')) {
				animation.add(path, [0, 1], 0, false, isPlayer);

				animation.play(path);
			} else {
				if (options.OptionsConfigs.iconAnimed)
					animation.addByPrefix(iconData[0], iconData[0], Std.parseInt(iconData[1]));
				else
					animation.addByIndices(iconData[0], iconData[0], [0], '.png');

				animation.play(iconData[0], true);
			}
			char = path;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
