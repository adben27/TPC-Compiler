/* tree.h */

typedef enum {
  ident,
  declaration,
  declarations,
  fonctions,
  fonction,
  parametres,
  instruction,
  instructions,
  arguments,
  program,
  body,
  heading,
  array
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef enum LexType {
  LABEL,
  BYTE,
  NUMERIC,
  IDENTIFIER,
  COMPARATOR,
} LexType;

typedef union {
  label_t label;    
	char byte;
	int num;
	char ident[64];
	char comp[3];
} NodeValue;

typedef struct Node {
  LexType type;
  NodeValue value;
  struct Node *firstChild, *nextSibling;
  int lineno;
} Node;

Node *makeLabelNode(label_t value);
Node *makeByteNode(char byte);
Node *makeNumNode(int num);
Node *makeStringNode(char* string, LexType type);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printNode(Node node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
