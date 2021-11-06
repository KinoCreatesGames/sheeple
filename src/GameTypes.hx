import h3d.Vector;

typedef LvlState = {
  playerPos:Vector,
  blockPositions:Array<Vector>
}

/**
 * The different types of block
 * available for the user to use within the
 * game.
 */
enum abstract BlockType(String) from String to String {
  var BlockB:String = 'RegularBlock';
  var BounceB:String = 'BounceBlock';
  var CrackedB:String = 'CrackedBlock';
  var IceB:String = 'IceBlock';
  var MysteryB:String = 'MysteryBlock';
  var StaticB:String = 'StaticBlock';
  var SpikeB:String = 'SpikeBlock';
  var GoalB:String = 'GoalBlock';
  var BlackHoleB:String = 'BlackHoleBlock';
  var HeavyB:String = 'HeavyBlock';
}