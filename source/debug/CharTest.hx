package debug;

class CharTest extends MusicBeatState {
	var char:Character;

	override function create() {
		char = new Character(0, 0);
		add(char);
	}
}
