package ;

import tink.Slice;
import haxe.unit.*;

class RunTests extends TestCase {
  function test() {
    
    inline function add(upto:Int)
      return (upto * (upto - 1)) >> 1;

    var s = Slice.ofArray([for (i in 0...100) i]);
    var sum = 0;
    
    for (x in s.iterator())
      sum += x;

    assertEquals(add(100), sum);

    var sum = 0;
    
    for (x in s.skip(25).iterator())
      sum += x;

    assertEquals(add(100) - add(25), sum);
        
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
        assertFalse(c.isShared);
        assertEquals(c.compact(), c);
        assertEquals(c.getOverhead(), .0);
      }

      assertEquals(50, slice.length);
      var sum = 0;
        
      for (x in slice) 
        sum += x;
        
      assertEquals(add(80) - add(30), sum);  

      var sum = 0;
        
      for (x in slice.iterator()) 
        sum += x;
        
      assertEquals(add(80) - add(30), sum);  
    }

    var sum = 0;
    
    for (x in s.reverse().iterator())
      sum += x;

    assertEquals(add(100), sum);

    assertEquals(add(100), fold(s, 0, function (a, b) return a + b));

    s = 42;

    var sum = 0;
    
    for (x in s)
      sum += x;

    assertEquals(42, sum);
    
  }
  
  function fold<T, R>(s:Slice<T>, init:R, f:R->T->R) 
    return switch s.peel() {
      case null: init;
      case { a: x, b: rest }: f(fold(rest, init, f), x);
    }  
    
  static function main() {
    var runner = new TestRunner();
    
    runner.add(new RunTests());
    
    travix.Logger.exit(
      if (runner.run()) 0
      else 500
    ); 
  }
  
}