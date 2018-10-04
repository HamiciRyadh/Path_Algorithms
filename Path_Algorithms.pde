final int EMPTY = 0, WALL = 1, START = 2, GOAL = 3, VISITED = 4, PATH = 5, TESTED = 6; //Cells values. //<>//
final int WAIT_TIME = 150; //Time to wait while drawing the path.
final int BREADTH_FIRST = 0, DEPTH_FIRST = 1, MANHATAN = 2, DIAGONAL = 3, EUCLIDEAN = 4; //Algorithm values.

int i,j, w, h;
int visitedI, pathI, testedI, nbreSteps, algorithm;

ArrayList<Mix> queue;
ArrayList<Mix> visitedNodes;
ArrayList<Mix> testedNodes;
ArrayList<Tree> path;

IVector start, goal;
Tree tree;

boolean drawPath, goalFound, pathDrawn;
float r,g,b;
int [][]obst = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,START,0,0,0,0,0,0,1,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1},
        {1,1,0,0,1,0,0,1,0,0,0,0,0,0,0,1},
        {1,0,0,0,1,0,0,1,1,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,GOAL,0,0,0,0,0,0,1,0,0,1},
        {1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1},
        {1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1},
        {1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
      }; 

void setup() {
  size(512, 512);
  w = 512;
  h = 512;
  start = new IVector(6, 1); //Default start position
  goal = new IVector(5, 7); //Default goal position
  obst[start.y][start.x] = START;
  obst[goal.y][goal.x] = GOAL;
  algorithm = MANHATAN;
  init();
  loadPixels();
}

/**
 * Initializes the variables.
 */
void init() {
  visitedI = 0;
  pathI = 0;
  testedI = 0;
  drawPath = false;
  goalFound = false;
  pathDrawn = false;
  tree = new Tree(start, estimate(start, goal));
  queue = new ArrayList<Mix>();
  path = new ArrayList<Tree>();
  visitedNodes = new ArrayList<Mix>();
  testedNodes = new ArrayList<Mix>();
  //Empty the cells.
  for (int y = 0; y < 16; y++) {
    for (int x = 0; x < 16; x++) {
      if (obst[y][x] >= VISITED) obst[y][x] = 0;
    }
  }
  obst[start.y][start.x] = START;
  obst[goal.y][goal.x] = GOAL;
}

void draw() {
  handleMouseClick();
  handleKeyPressed();
  int loc, stepX, stepY, val;
  for (int x = 0; x < w; x++ ) {
    for (int y = 0; y < h; y++ ) {
      loc = x + y*w;
      stepX = w/16;
      stepY = h/16;
      i = y/stepY;
      j = x/stepX;
      
      if (x % stepX == 0 || y % stepY == 0) {//Border
        val = 7;
      } else {
        val = obst[i][j];
      }
      
      switch (val) {
        case EMPTY: r = 100; g = 100; b = 100; break; //Unused Cell
        case WALL: r = 0; g = 0; b = 200; break; //Wall
        case START: r = 255; g = 0; b = 0; break; //Start
        case GOAL: r = 0; g = 255; b = 0; break; //Goal
        case VISITED: r = 255; g = 255; b = 255; break; //Visited
        case PATH: r = 255; g = 100; b = 0; break; //Path
        case TESTED: r = 255; g = 100; b = 157; break; //Tested
        case 7: r = 0; g = 0; b = 0; break; //Borders
      }      
      color c = color(r, g, b);
      pixels[loc] = c;      
    }
  }
  updatePixels(); 
  
  if (!drawPath) {
    drawPath = true;
    nbreSteps = 0;
    if (!start.iEquals(goal)) {
      switch (this.algorithm) {
        case BREADTH_FIRST: drawPathBreadthFirst(); break;
        case DEPTH_FIRST: drawPathDepthFirst(); break;
        default: drawPathA();
      }
      if (goalFound) println("Visited cells : " + nbreSteps+".");
    }
  }
  
  //Handles the change in the cells' color.
  if (visitedI < visitedNodes.size()) {
      for (int i = 0; i < testedNodes.size(); i++)
      if (obst[testedNodes.get(i).node.value.y][testedNodes.get(i).node.value.x] != VISITED && isNeighbour(testedNodes.get(i).node.value, visitedNodes.get(visitedI).node.value)) {
        obst[testedNodes.get(i).node.value.y][testedNodes.get(i).node.value.x] = TESTED;
      }
      obst[visitedNodes.get(visitedI).node.value.y][visitedNodes.get(visitedI).node.value.x] = VISITED;
      visitedI++;
      delay(WAIT_TIME);
  } else {
      if (!pathDrawn) {
        for (Tree node : path) {
          obst[node.value.y][node.value.x] = PATH;
        }
        obst[start.y][start.x] = START;
        obst[goal.y][goal.x] = GOAL;
        pathDrawn = true;
      }
  }
}

/**
 * Handles the mouse click events, if the selected cell is empty changes the goal's position if 
 * a right click occurs, and the start position when it is a left click.
 */
void handleMouseClick() {
  if (mousePressed) {
    int newX = mouseX/(w/16);
    int newY = mouseY/(h/16);
    if (newX>0 && newX<16 && newY>0 && newY<16 && obst[newY][newX] != WALL) {
      if (mouseButton == LEFT) {
        obst[start.y][start.x] = EMPTY;
        start.y = newY;
        start.x = newX;
        init();
      }
      if (mouseButton == RIGHT) {
        obst[goal.y][goal.x] = EMPTY;
        goal.y = newY;
        goal.x = newX;
        init();
      }
    }
  }
}

/**
 * Handles the key events to change the used algorithm and resets the display.
 */
void handleKeyPressed() {
  if (keyPressed) {
    if (key == 'b' || key == 'B') {
      this.algorithm = BREADTH_FIRST;
    } else if (key == 'd' || key == 'D') {
      this.algorithm = DEPTH_FIRST;
    } else if (key == 'm' || key == 'M') {
      this.algorithm = MANHATAN;
    } else if (key == 'l' || key == 'L') {
      this.algorithm = DIAGONAL;
    } else if (key == 'e' || key == 'E') {
      this.algorithm = EUCLIDEAN;
    }
    init();
  }
}

/*********************************Breadth-first***********************************/

/**
 * Looks for a path between the start point and the goal using the Breadth-first algorithm.
 */
void drawPathBreadthFirst() {
  final Tree tGoal = findGoalBreadthFirst();
  if (tGoal == null) {
    println("Goal unreachable, visited cells : " + nbreSteps +".\n");
    return;
  }
  this.path.add(tGoal);
  Mix currentNode = findFirstOccurenceMix(this.visitedNodes, tGoal.value);
  while (!currentNode.node.value.iEquals(this.start)) {
    currentNode = findFirstOccurenceMix(this.visitedNodes, currentNode.father.value);
    if (currentNode == null) {
      return;
    }
    this.path.add(currentNode.node);
  }
}

/**
 * Searched for the goal using the Breadth-first algorithm.
 */
Tree findGoalBreadthFirst() {
  enqueue(this.queue, tree, null);
  Mix temps = dequeue(this.queue);
  do {
    temps.node.nodes.addAll(findNeighbours(temps.node.value));
    for (Tree node : temps.node.nodes) {
      if (!existsInList(this.visitedNodes, node.value)) {
        visitedNodes.add(new Mix(node, temps.node));
        nbreSteps++;
        if (node.value.iEquals(this.goal)) {
          return node;
        }
        enqueue(this.queue, node, temps.node);
      }
    }
    temps = dequeue(this.queue);
  } while (temps != null);
  return null;
}

/***********************************Depth-first*********************************/

/**
 * Uses the Depth-first algorithm.
 */
void drawPathDepthFirst() {
  //Code Profondeur
  if (!findGoalDepthFirst(tree)) {
    println("Goal unreachable, visited cells : " + nbreSteps +".\n");
    return;
  }
}

/**
 * Searches for the goal and builds the path to it using the Depth-first algorithm (recurcive mode).
 */
boolean findGoalDepthFirst(final Tree node) {
  nbreSteps++;
  if (node.value.iEquals(this.goal)) return true;
  node.nodes.addAll(findNeighbours(node.value));
  for (Tree subTree : node.nodes) {
    if (existsInList(this.visitedNodes, subTree.value)) continue;
    visitedNodes.add(new Mix(subTree, node));
    if (subTree.value.iEquals(this.goal)) return true;
    if (findGoalDepthFirst(subTree)) {
      this.path.add(subTree);
      return true;
    }
  }
  return false;
}

/*************************************A*****************************************/

/**
 * Looks for a path between the start point and the goal using the A algorithm.
 */
void drawPathA() {
  Mix latestMix = findGoalA();
  if (latestMix == null) {
    println("Goal unreachable, visited cells : " + nbreSteps +".\n");
    return;
  }
  boolean pathFound = false;
  while (!pathFound) {
    latestMix = findFatherInList(this.visitedNodes, latestMix);
    if (latestMix == null) {
      println("Goal unreachable, visited cells : " + nbreSteps +".\n");
      return;
    }
    path.add(latestMix.node);
    if (latestMix.father.value.iEquals(this.start)) pathFound = true;
  }
}

/**
 * Searches for the goal using the A algorithm.
 */
Mix findGoalA() {
  tree.nodes.addAll(findNeighbours(tree.value));
  estimateAndTestNodes(tree);
  Mix mix;
  while (!goalFound && this.testedNodes.size() != 0) {
    mix = findMinEstimation(this.testedNodes);
    nbreSteps++;
    this.visitedNodes.add(mix);
    if (mix.node.value.iEquals(this.goal)) {
      goalFound = true;
      return mix;
    }
    mix.node.nodes.addAll(findNeighbours(mix.node.value));
    estimateAndTestNodes(mix.node);
  }
  return null;
}

/**
 * Browse through the direct sons of the given tree, if a node has never been tested or visited, 
 * calculates an estimation and adds it to the list of testedNodes.
 */
void estimateAndTestNodes(final Tree tree) {
  for (Tree subTree : tree.nodes) {
    if (!existsInList(testedNodes, subTree.value) && !existsInList(visitedNodes, subTree.value)) {
      subTree.estimation = estimate(subTree.value, this.goal);
      this.testedNodes.add(new Mix(subTree, tree));
    }
  }
}

/**
 * Returns the element with the lowest estimation in the given ArrayList, may be null if the list is
 * empty or null.
 */
Mix findMinEstimation(final ArrayList<Mix> list) {
  Mix returnValue = null;
  if (list != null) {
    for (Mix mix : list) {
      if (returnValue == null) returnValue = mix;
      if (mix.node.estimation < returnValue.node.estimation) returnValue = mix;
    }
    list.remove(returnValue);
  }
  return returnValue;
}

/**
 * Calculates an estimation about the proximity to the goal.
 */
int estimate(final IVector pos, final IVector relativeTo) {
  switch (this.algorithm) {
    case MANHATAN: return abs(pos.x - relativeTo.x) + abs(pos.y - relativeTo.y);
    case DIAGONAL: return max(abs(pos.x - relativeTo.x), abs(pos.y - relativeTo.y));
    case EUCLIDEAN: return floor(sqrt(pow(pos.x - relativeTo.x,2) + pow(pos.y - relativeTo.y,2)));
    default: return 0;
  }
}


/*******************************Common functions*********************************/

/**
 * Returns an ArrayList of Tree containing the neighbours of the given position.
 */
ArrayList<Tree> findNeighbours(final IVector position) {
  final ArrayList<Tree> neighbours = new ArrayList<Tree>();
  Tree newNode;
  IVector newVector;

  if (position.x-1 > 0) {
    if (obst[position.y][position.x-1] != WALL) {
      //Case Vide
      newVector = new IVector(position.x-1, position.y);
      newNode = findFirstOccurence(this.visitedNodes, newVector);
      if (newNode == null) {
         newNode = new Tree(newVector);
      }
      neighbours.add(newNode);
    }
  }
  if (position.x+1 < 16) {
    if (obst[position.y][position.x+1] != WALL) {
      //Case Vide
      newVector = new IVector(position.x+1, position.y);
      newNode = findFirstOccurence(this.visitedNodes, newVector);
      if (newNode == null) {
         newNode = new Tree(newVector);
      }
      neighbours.add(newNode);
    }
  }
  if (position.y-1 > 0) {
    if (obst[position.y-1][position.x] != WALL) {
      //Case Vide
      newVector = new IVector(position.x, position.y-1);
      newNode = findFirstOccurence(this.visitedNodes, newVector);
      if (newNode == null) {
         newNode = new Tree(newVector);
      }
      neighbours.add(newNode);
    }
  }
  if (position.y+1 < 16) {
    if (obst[position.y+1][position.x] != WALL) {
      //Case Vide
      newVector = new IVector(position.x, position.y+1);
      newNode = findFirstOccurence(this.visitedNodes, newVector);
      if (newNode == null) {
         newNode = new Tree(newVector);
      }
      neighbours.add(newNode);
    }
  }
  
  return neighbours;
}


/**
 * Checks if the given IVector is present in the given ArrayList, returns true if found, false 
 * otherwise or if one of the parameters is equal to null.
 */
boolean existsInList(final ArrayList<Mix> list, final IVector iVector) {
  if (list == null || iVector == null) return false;
  for (Mix mix : list) {
    if (mix.node.value.iEquals(iVector)) return true;
  }
  return false;
}

/**
 * Browse through the given ArrayList and returns the first occurence found of a Tree element 
 * whose value corresponds to the given IVector, if it does not exist or one of the parameters
 * is equal to null, returns null.
 */
Tree findFirstOccurence(final ArrayList<Mix> source, final IVector iVector) {
  if (iVector == null || source == null) return null;
  for (Mix mix : source) {
    if (mix.node.value.iEquals(iVector)) return mix.node;
  }
  return null;
}

/**
 * Browse through the given ArrayList and returns the first occurence found of a Tree element 
 * whose value corresponds to the given IVector, if it does not exist or one of the parameters
 * is equal to null, returns null.
 */
Mix findFirstOccurenceMix(final ArrayList<Mix> source, final IVector iVector) {
  if (iVector == null || source == null) return null;
  for (Mix mix : source) {
    if (mix.node.value.iEquals(iVector)) return mix;
  }
  return null;
}

/**
 * Checks if pos1 and pos2 are neighbours.
 */
boolean isNeighbour(final IVector pos1, final IVector pos2) {
  if (pos1.x == pos2.x  && (abs(pos1.y - pos2.y) <= 1)) return true;
  if (pos1.y == pos2.y  && (abs(pos1.x - pos2.x) <= 1)) return true;
  return false;
}

/**
 * Searches for the direct father of the given son in the source ArrayList, returns the a mix element
 * whose node is the father if found, null otherwise.
 */
Mix findFatherInList(final ArrayList<Mix> source, final Mix son) {
  if (source == null || son == null || son.father == null) return null;
  for (Mix mix : source) {
    if (mix.node.iEquals(son.father)) return mix;
  }
  return null;
}

/*******************************Queues functions*********************************/

/**
 * Adds an element at the end of the given queue.
 */
void enqueue(final ArrayList<Mix> queue, final Tree node, final Tree father) {
  if (queue != null && tree != null) queue.add(new Mix(node, father));
}

/**
 * Removes and returns the element at the top of the given queue.
 */
Mix dequeue(final ArrayList<Mix> queue) {
  if (queue == null || queue.size() == 0) return null;
  final Mix mix = queue.get(0);
  queue.remove(0);
  return mix;
}
