/**
 * This class represents an element of a Tree.
 */
public class Tree {
  int estimation;
  IVector value;
  ArrayList<Tree> nodes;
  
  public Tree(IVector vector, int estimation) {
    this.value = vector;
    this.nodes = new ArrayList<Tree>();
    this.estimation = estimation;
  }
  
  public Tree(IVector vector) {
    this.value = vector;
    this.nodes = new ArrayList<Tree>();
  }
  
  public Tree() {
    this(new IVector(0, 0), 0);
  }
  
  /**
   * Adds a node to the list of nodes.
   */
  public Tree addNode(IVector newVector, int estimation) {
    final Tree tree = new Tree(newVector, estimation);
    this.nodes.add(tree);
    return tree;
  }
  
  /**
   * Adds a node to the list of nodes.
   */
  public Tree addNode(Tree node) {
    this.nodes.add(node);
    return node;
  }
  
  /**
   * Recurcively checks if the given position exists within the tree formed 
   * by the current node and his direct and undirect sons.
   */
  public boolean contains(IVector position) {
    if (this.value.iEquals(position)) return true;
    boolean returnValue = false;
    for (Tree tree : nodes) {
      returnValue = returnValue || tree.contains(position);
      if (returnValue == true) return true;
    }
    return returnValue || false;
  }
  
  /**
   * Checks the equality between the current object and the given Tree element, returns true if 
   * they have equal values for the value property, false otherwise.
   */
  public boolean iEquals(Tree tree) {
    if (tree == null) return false;
    return this.value.iEquals(tree.value);
  }
}
