#include <stdio.h>
#include <stdlib.h>


typedef  datatype Tree  Tree;
datatype Tree {
    Fork (Tree*, Tree*, const char*);
    Leaf (const char*);
};

int count_matches (Tree *t) {
  match (t) {
     Fork(t1,t2,str) -> {
        int res_t1, res_t2, res_str;
        res_t1 = count_matches(t1);
	res_t2 = count_matches(t2);
        res_str = 1;
        return res_t1 + res_t2 + res_str;
	}
    Leaf(s) -> { return 1; }
   } ;
}

int main (int argc, char **argv) {
    Tree *tree = Fork(Fork(Leaf("b"), Leaf("c"), "x"), Leaf("a"),"y");

    int result = count_matches(tree);

    printf ("Number of matches = %d\n", result);

    return (result == 5) ? 0 : 1;
}