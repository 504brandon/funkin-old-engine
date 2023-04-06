// creds to luckydog7
package handlers.ui;

import flixel.ui.FlxVirtualPad;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.util.FlxSignal;
import flixel.input.IFlxInputManager;
import flixel.util.typeLimit.OneOfTwo;
import flixel.input.actions.FlxActionInput;
import flixel.input.FlxInput.FlxInputState;
import flixel.ui.FlxButton;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

// import Config;

class MobileControlsCool extends FlxSpriteGroup {
	public var _hitbox:HitboxControls.Hitbox;

	var cHandler:ControlHandler;

	public static var isEnabled:Bool;

	// var config:Config;

	public function new() {
		super();

		_hitbox = new Hitbox();
		add(_hitbox);
		cHandler = new ControlHandler(_hitbox);
		cHandler.bind();
	}
}

@:access(Controls)
class ControlHandler {
	var isPad:Bool = true;
	var trackedinputs:Array<FlxActionInput>;

	public var virtualPad(default, null):FlxVirtualPad;
	public var hitbox(default, null):Hitbox;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public function new(obj:OneOfTwo<FlxVirtualPad, Hitbox>) {
		if (obj is FlxVirtualPad) {
			isPad = true;
			virtualPad = obj;
		} else if (obj is Hitbox) {
			isPad = false;
			hitbox = obj;
		} else {
			trace("unknown control type");
		}

		FlxG.signals.preGameReset.add(forceUnBind);
		FlxG.signals.preStateSwitch.add(forceUnBind);
	}

	// bind to controls class
	public function bind() {
		trackedinputs = [];
		if (isPad)
			setVirtualPad();
		else
			setHitBox();
	}

	public function unBind() {
		removeFlxInput(trackedinputs);
		trackedinputs = null;
	}

	function forceUnBind() {
		FlxG.signals.preGameReset.remove(forceUnBind);
		FlxG.signals.preStateSwitch.remove(forceUnBind);

		if (trackedinputs != null)
			unBind();
	}

	public function setVirtualPad() {
		var upActions = [Control.UP, Control.UP];
		var downActions = [Control.DOWN, Control.DOWN];
		var leftActions = [Control.LEFT, Control.LEFT];
		var rightActions = [Control.RIGHT, Control.RIGHT];
		var aActions = [Control.ACCEPT];
		var bActions = [Control.BACK];

		for (button in virtualPad.members) {
			var name = button.frames.frames[0].name;

			switch (name) {
				case 'up':
					for (up in upActions)
						inline controls.forEachBound(up, (action, state) -> addbutton(action, cast button, state));
				case 'down':
					for (down in downActions)
						inline controls.forEachBound(down, (action, state) -> addbutton(action, cast button, state));
				case 'left':
					for (left in leftActions)
						inline controls.forEachBound(left, (action, state) -> addbutton(action, cast button, state));
				case 'right':
					for (right in rightActions)
						inline controls.forEachBound(right, (action, state) -> addbutton(action, cast button, state));

				case 'a':
					for (a in aActions)
						inline controls.forEachBound(a, (action, state) -> addbutton(action, cast button, state));
				case 'b':
					for (b in bActions)
						inline controls.forEachBound(b, (action, state) -> addbutton(action, cast button, state));
			}
		}
	}

	public function setHitBox() {
		var up = Control.UP;
		var down = Control.DOWN;
		var left = Control.LEFT;
		var right = Control.RIGHT;

		inline controls.forEachBound(up, (action, state) -> addbutton(action, hitbox.buttonUp, state));
		inline controls.forEachBound(down, (action, state) -> addbutton(action, hitbox.buttonDown, state));
		inline controls.forEachBound(left, (action, state) -> addbutton(action, hitbox.buttonLeft, state));
		inline controls.forEachBound(right, (action, state) -> addbutton(action, hitbox.buttonRight, state));
	}

	public function addbutton(action:FlxActionDigital, button:FlxButton, state:FlxInputState) {
		var input = new FlxActionInputDigitalIFlxInput(button, state);
		trackedinputs.push(input);

		action.add(input);
		// action.addInput(button, state);
	}

	public function removeFlxInput(Tinputs:Array<FlxActionInput>) {
		for (action in controls.digitalActions) {
			var i = action.inputs.length;

			while (i-- > 0) {
				// uhhhhhhhhhhh
				var input = action.inputs[i];
				/*if (input.device == IFLXINPUT_OBJECT)
					action.remove(input); */

				var x = Tinputs.length;
				while (x-- > 0)
					if (Tinputs[x] == input) {
						action.remove(input);
						input.destroy();
					}
			}
		}
	}
}

enum abstract ControlsGroup(Int) to Int from Int {
	var HITBOX = 0;
	var VIRTUALPAD_RIGHT = 1;
	var VIRTUALPAD_LEFT = 2;
	var VIRTUALPAD_CUSTOM = 3;
	var KEYBOARD = 4;
}
