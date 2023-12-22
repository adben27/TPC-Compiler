/* tree.c */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
extern int lineno;       /* from lexer */

static const char *StringFromLabel[] = {
  "ident",
  "declaration",
  "declarations",
  "fonctions",
  "fonction",
  "parametres",
  "instruction",
  "instructions",
  "arguments",
  "program",
  "body",
  "heading",
  "array"
  /* list all other node labels, if any */
  /* The list must coincide with the label_t enum in tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

Node *makeLabelNode(label_t value) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(3);
  }
  node->type = LABEL;
  node->value.label = value;
  node-> firstChild = node->nextSibling = NULL;
  node->lineno=lineno;
  return node;
}


Node *makeByteNode(char byte, LexType type){
  if(type != OPERATION || type != CHARAC) {  
    Node *node = malloc(sizeof(Node));
    if (!node) {
      printf("Run out of memory\n");
      exit(3);
    }
    node->type = type;
    node->value.byte = byte;
    node-> firstChild = node->nextSibling = NULL;
    node->lineno=lineno;
    return node;
  }
  exit(1);
}

Node *makeNumNode(int num) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(3);
  }
  node->type = NUMERIC;
  node->value.num = num;
  node-> firstChild = node->nextSibling = NULL;
  node->lineno=lineno;
  return node;
}

Node *makeStringNode(char* string, LexType type) {
  if(type != IDENTIFIER || type != COMPARATOR) {
    Node *node = malloc(sizeof(Node));
    if (!node) {
      printf("Run out of memory\n");
      exit(3);
    }
    if(type == IDENTIFIER) {
      node->type = type;
      strcpy(node->value.ident, string);
    } else if(type == COMPARATOR) {
      node->type = type;
      strcpy(node->value.comp, string);
    }
    node-> firstChild = node->nextSibling = NULL;
    node->lineno=lineno;
    return node;
  }
  exit(3);
}

void addSibling(Node *node, Node *sibling) {
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node);
}

void printNode(Node node) {
  switch(node.type) {
    case LABEL:
      printf("%s", StringFromLabel[node.value.label]);
      break;
    case OPERATION:
      printf("%c", node.value.byte);
      break;
    case CHARAC:
      printf("'%c'", node.value.byte);
      break;
    case NUMERIC:
      printf("%d", node.value.num);
      break;
    case IDENTIFIER:
      printf("%s", node.value.ident);
      break;
    case COMPARATOR:
      printf("%s", node.value.comp);
      break;
  }
}

void printTree(Node *node) {
  static bool rightmost[128]; // tells if node is rightmost sibling
  static int depth = 0;       // depth of current node
  for (int i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = L form; 2500 = horizontal line; 251c = vertical line and right horiz 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }
  printNode(*node);
  //printf("%s", StringFromLabel[node->label]);
  printf("\n");
  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}
