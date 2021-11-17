/**
 * Groups elements together.
 * Useful convenience purposes.
 */
class Group<T> {
  public var members:Array<T>;
  public var index:Int = 0;
  public var maxSize:Int = 0;

  public function new(?elements:Array<T>) {
    members = [];
    if (elements != null) {
      for (element in elements) {
        add(element);
      }
      maxSize = elements.length;
    }
  }

  public inline function maxCount() {
    return maxSize;
  }

  public inline function add(el:T) {
    members.push(el);
  }

  public inline function pop() {
    return members.pop();
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

  /**
   * Removes all elements from the group
   */
  public inline function clear() {
    members.resize(0);
  }

  public inline function next() {
    return members[index++];
  }
}