package ;

import tink.testrunner.Runner.*;
import tink.Slice;

@:asserts
class RunTests {
  public function new() {}
  public function test() {

    inline function add(upto:Int)
      return (upto * (upto - 1)) >> 1;

    var s = Slice.ofArray([for (i in 0...100) i]);
    var sum = 0;

    for (x in s.iterator())
      sum += x;

    asserts.assert(sum == add(100));

    var sum = 0;

    for (x in s.skip(25).iterator())
      sum += x;

    asserts.assert(sum == add(100) - add(25));

    for (slice in [
      s.skip(30).reverse().skip(20),
      s.reverse().skip(20).reverse().skip(30),
      s.reverse().skip(20).reverse().skip(30).reverse(),
      s.skip(30).limit(50),
      s.skip(30).limit(50).reverse(),
      s.reverse().skip(20).limit(50).reverse(),
      s.reverse().limit(70).skip(20),
      s.limit(80).skip(30),
      s.limit(80).skip(30).reverse(),
      s.limit(80).skip(30).compact()
    ]) {
      {
        var c = slice.compact();
        asserts.assert(!c.isShared);
        asserts.assert(c.compact() == c);
        asserts.assert(c.getOverhead() == .0);
      }

      asserts.assert(slice.length == 50);
      var sum = 0;

      for (x in slice)
        sum += x;

      asserts.assert(add(80) - add(30) == sum);

      var sum = 0;

      for (x in slice.iterator())
        sum += x;

      asserts.assert(add(80) - add(30) == sum);
    }

    var sum = 0;

    for (x in s.reverse().iterator())
      sum += x;

    asserts.assert(add(100) == sum);

    asserts.assert(add(100) == fold(s, 0, function (a, b) return a + b));

    s = 42;

    var sum = 0;

    for (x in s)
      sum += x;

    asserts.assert(sum == 42);

    return asserts.done();
  }

  function fold<T, R>(s:Slice<T>, init:R, f:R->T->R)
    return switch s.peel() {
      case null: init;
      case { a: x, b: rest }: f(fold(rest, init, f), x);
    }

  static function main()
    run(tink.unit.TestBatch.make(new RunTests())).handle(exit);

}