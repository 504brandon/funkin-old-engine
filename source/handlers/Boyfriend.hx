package handlers;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import handlers.Character;

using StringTools;

class Boyfriend extends Character {
	public var stunned:Bool = false;

	public function new(x:Float, y:Float, char:String) {
		super(x, y);
		this.curCharacter = char;
	}

	override function update(elapsed:Float) {
		if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode) {
			playAnim('idle', true, false, 10);
		}

		if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished) {
			playAnim('deathLoop');
		}

		super.update(elapsed);
	}
}
