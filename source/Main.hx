package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.TitleState;
#if !mobile
import handlers.ui.FPS;
#end

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(0, 0, TitleState));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
