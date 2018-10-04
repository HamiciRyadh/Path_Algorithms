/**
 * This class is used to sotre the x and y positions of an element.
 */
public class IVector {
  int x,y;
  
  public IVector(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  /**
   * Checks the equality between the current object and the given IVector element, returns true if 
   * they have equal values of x and y, false otherwise.
   */
  public boolean iEquals(IVector vector) {
    if (vector == null) return false;
    return this.x == vector.x && this.y == vector.y;
  }
}
