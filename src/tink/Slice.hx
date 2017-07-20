package tink;

import haxe.ds.Vector;
using tink.CoreApi;

@:structInit
private class SliceData<T> {
  public var entries(default, null):Vector<T>;
  public var reversed(default, null):Bool;
  public var start(default, null):Int;
  public var length(default, null):Int;
  public var isShared(default, null):Bool;

  public var reverse(get, null):SliceData<T>;
    function get_reverse() return switch this.reverse {
      case null:
        this.reverse = new SliceData(entries, !reversed, start, length, isShared, this);
      case v: v;
    }  

  public inline function new(entries, reversed:Bool, start:Int, length:Int, isShared:Bool, ?reverse:SliceData<T>) {
    this.entries = entries;
    this.reversed = reversed;
    this.start = start;
    this.length = length;
    this.isShared = isShared;
    this.reverse = reverse;
  }

  public inline function iterator()
    return new SliceIterator(this.entries, this.start, this.length, this.reversed);

}

abstract Slice<T>(SliceData<T>) from SliceData<T> to Iterable<T> {

  public var isShared(get, never):Bool;
    inline function get_isShared()
      return this.isShared;

  public var length(get, never):Int;
    inline function get_length()
      return this.length;

  public function getOverhead()
    return 
      switch this.entries.length {
        case 0: .0;
        case v: (v - length) / length;
      }

  public function compact():Slice<T>
    return 
      if (isShared || this.entries.length > length)
        make({
          var vec = new Vector(length);
          Vector.blit(this.entries, this.start, vec, 0, length);
          vec;
        }, 0, length, false, this.reversed);
      else this;

  public inline function reverse():Slice<T>
    return this.reverse;

  public function peel()
    return 
      if (this.length == 0) null;
      else new Pair(this.entries[this.start], skip(1));

  @:arrayAccess inline function get(index:Int) 
    return 
      if (index < 0 || index >= length) null;
      else this.entries[translate(index)];

  inline function translate(index:Int) 
    return this.start + if (this.reversed) length - index - 1 else index;

  static inline function empty<T>():Slice<T>
    return make(new Vector(0), 0, 0, false);

  public inline function iterator()
    return new SliceIterator(this.entries, this.start, this.length, this.reversed);

  public function skip(count):Slice<T> 
    return 
      if (count > length) empty();
      else if (count <= 0) this;
      else make(this.entries, if (this.reversed) this.start else this.start + count, length - count, this.isShared, this.reversed);

  public function limit(count):Slice<T> 
    return 
      if (count > length) empty();
      else if (count <= 0) this;
      else make(this.entries, if (this.reversed) this.start + length - count else this.start, count, this.isShared, this.reversed);  

  static public inline function make<T>(vec:Vector<T>, start:Int, length:Int, isShared:Bool, reversed:Bool = false):Slice<T> 
    return new SliceData<T>(vec, reversed, start, length, isShared);

  static public inline function withinVector<T>(vec:Vector<T>, start:Int, length:Int) 
    return make(vec, start, length, true);

  static public inline function withinArray<T>(a:Array<T>, start:Int, length:Int) 
    return 
      make(
        {
          var vec = new Vector(length);
          for (i in 0...length)
            vec[i] = a[i + start];
          vec;
        }, start, length,false);

  @:from static public inline function ofArray<T>(a:Array<T>) 
    return make(Vector.fromArrayCopy(a), 0, a.length, false);

  @:from static public function ofIterable<T>(a:Iterable<T>) {
    
    var count = 0;
    for (x in a) 
      count++;
    
    var vec = new Vector(count);
    
    var i = 0;
    for (x in a) 
      vec[i++] = x;
    
    return make(vec, 0, count, false);
  }

  @:from static public function ofSingle<T>(x:T)
    return make({ 
      var vec = new Vector(1); 
      vec[0] = x;
      vec;
    }, 0, 1, false, false);
}

class SliceIterator<T> {
  var pos:Int;
  var step:Int;
  var left:Int;
  var entries:Vector<T>;

  public inline function new(entries, start, length, reversed) {
    this.entries = entries;
    this.left = length;
    if (reversed) {
      this.pos = start + length - 1;
      this.step = -1;
    }
    else {
      this.pos = start;
      this.step = 1;
    }
  }

  public inline function hasNext() 
    return left > 0;

  public inline function next() {
    var old = pos;
    pos += step;
    left--;
    return entries[old];
  }
    
}