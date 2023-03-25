package extra;

import handlers.MusicBeatState;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

class NotifyFnfFlash extends MusicBeatState {
    var textCool:FlxText;

    override public function create() {
        FlxG.sound.playMusic('assets/music/fpsplusmusicthatsabanger.ogg');

        var bg = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xff252525;
		add(bg);

        textCool = new FlxText(0, 0, 0, 'Hey fnf has flashing lights\nIf you dont like those press esc otherwize you should be good.');
        textCool.scale.set(3.1, 3.1);
        textCool.screenCenter();
        add(textCool);
    }

    override public function update(elapsed:Float) {
        coolAlphaThing();
    }

    function coolAlphaThing() {
        FlxTween.tween(textCool, {alpha: 0}, 0.8, {onComplete: function(tween) {
            FlxTween.tween(textCool, {alpha: 1}, 0.8);
        }});
    }
}