module AnnotationDemo 

import IO;
import Node;

// Define AnnotationDemo with red and blue nodes and integer leaves
data RootNode = root(Leaf left, Leaf right);
data Leaf = leaf(int N);

// Add annotations 
anno str Leaf@note1;
anno str Leaf@note2;
   
// Transform red nodes into green nodes
public RootNode switchLR(RootNode t){
  return visit(t) {
    //case x:root(l, r) => root(r, l) 
    case l:leaf(i) => setAnnotations(leaf(i+1), getAnnotations(l)) 
  };
}

public void main(){
  RootNode t1 = root(leaf(1), leaf(2)[@note1="this is an annotation on root"][@note2="aapje"]);
  RootNode t2 = switchLR(t1);
  
  iprintln(t1);
  iprintln(t2);
  
  /* Results in:
  
    rascal>main();
    
    root(
      leaf(1),
      leaf(2))[
      @note="this is an annotation on root"
    ]
    
    root(
      leaf(2),
      leaf(1))
      
  */
}