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
    maxSize = members.length;
  }

  public inline function pop() {
    var result = members.pop();
    maxSize = members.length;
    return result;
  }

  public inline function remove(el:T) {
    var result = members.remove(el);
    maxSize -= 1;
    return result;
  }

  public inline function contains(el:T) {
    return members.contains(el);
  }

  public inline function hasNext():Bool {
    var result = index < members.length;
    if (result) {
      return result;
    } else {
      index = 0;
      return result;
    }
  }

  /**
   * Removes all elements from the group
   */
  public inline function clear() {
    members.resize(0);
  }

  public inline function next() {
    var result = members[index++];
    return result;
  }
}