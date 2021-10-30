/**
 * Groups elements together.
 * Useful convenience purposes.
 */
class Group<T> {
  public var members:Array<T>;
  public var index:Int = 0;

  public function new(?elements:Array<T>) {
    members = [];
    if (elements != null) {
      for (element in elements) {
        add(element);
      }
    }
  }

  public inline function add(el:T) {
    members.push(el);
  }

  public inline function remove(el:T) {
    return members.remove(el);
  }

  public inline function contains(el:T) {
    return members.contains(el);
  }

  public inline function hasNext():Bool {
    return index < members.length;
  }

  public inline function next() {
    return members[index++];
  }
}