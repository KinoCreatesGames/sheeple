import h3d.Vector;

typedef LvlState = {
  playerPos:Vector,
  reachedCheckpoint:Bool,
  checkpointPos:Vector,
  blockPositions:Array<Vector>
}

typedef LvlSave = {
  playerStart:VectorSave,
  blocks:Array<BlockSave>
}

/**
 * Vector Save Stats
 */
typedef VectorSave = {
  x:Int,
  y:Int,
  z:Int
}

/**
 * Block Save Stats
 */
typedef BlockSave = {
  blockType:BlockType,
  pos:VectorSave
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

enum abstract CollectibleTypes(String) from String to String {
  var BambooR = 'BambooRockets';
  var ShardR = 'Shard';
  var CheckpointR = 'Checkpoint';
  var JLife = 'Life';
  var JetPack = 'JetPack';
}