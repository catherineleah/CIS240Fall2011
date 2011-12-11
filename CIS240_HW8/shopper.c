
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "shopper.h"

/* struct */
struct item{
  char *name;
  int num;
  struct item *link;
};

struct item *find(struct item *first_item, char *searchName){
  if (first_item == NULL)
    return NULL;

  else{
    struct item *tempItem = first_item;
    
    // cycle through items, return the item if the name matches
    while (tempItem->link != NULL){
      if (strcmp(tempItem->name, searchName) == 0) return tempItem;
      tempItem = tempItem->link;
    }

    // check last item
    if (strcmp(tempItem->name, searchName) == 0) return tempItem;
  }

  // if nothing matched, return NULL
  return NULL;
}



struct item *delete(struct item *first_item, char *delName){
  if (first_item == NULL)
    return NULL;

  // if the first item is the one to be removed, 
  // remove it and return its following item to be
  // set as the first node
  else if (strcmp(first_item->name, delName) == 0){
    struct item *tempItem = first_item->link;
    free(first_item->name);
    free(first_item);
    return tempItem;
  }

  // if it's any item apart from the first item
  else{
    struct item *tempItem = first_item->link;
    struct item *prevItem = first_item;
    
    // cycle through items in list, see if any of them match
    while (tempItem->link != NULL){
      if (strcmp(tempItem->name, delName) == 0){
	prevItem->link = tempItem->link;
	free(tempItem->name);
	free(tempItem);
	return first_item;
      }

      prevItem = tempItem;
      tempItem = tempItem->link;
    }

    // check last item - is this one a match?
    // if so, just delete it, then set the link pointer of the previous item to NULL
    if (strcmp(tempItem->name, delName) == 0){
      prevItem->link = tempItem->link;
      free(tempItem->name);
      free(tempItem);
      return first_item;
    }
  }

  // return first_item if item not found
  return first_item;
}



struct item *add(struct item *first_item, char *item_name, int num_update){
  
  // check if the first item exists yet
  // if it doesn't, create it and set the next item to NULL
  // return first item
  if (first_item == NULL){
    first_item = (struct item *)malloc(sizeof(struct item));
   
    // check if malloc fails
    if (first_item == NULL){
      printf("couldn't allocate the first item\n");
      exit (1);
    }

    first_item->name = malloc(strlen(item_name) + 1);
    if (first_item->name == NULL){
      printf("couldn't allocate the first name\n");
      exit(1);
    }

    // copy parameter values to item
    strcpy(first_item->name, item_name);
    first_item->num = first_item->num + num_update;
    first_item->link = NULL;
    return first_item;
  }

  // if the first item DOES exist
  else {
    // set temporary pointer to result of find()
     struct item *tempItem = find(first_item, item_name);
 
    // if the item does not already exist!
    // create struct newItem
    // set values and set next to NULL
    // iterate through current list items until you find the last item
    // link last item to new item
    if (tempItem == NULL){
      struct item *newItem;
      newItem = (struct item *)malloc(sizeof(struct item));

      // check if malloc fails
      if (newItem == NULL){
        printf("couldn't allocate a new item\n");
        exit (1);
      }

      newItem->name = malloc(strlen(item_name) + 1);
      if (newItem->name == NULL){
        printf("couldn't allocate a new name\n");
        exit(1);
      }

      // copy parameter values to item
      strcpy(newItem->name, item_name);
      newItem->num = num_update;
      newItem->link = NULL;

      // set tempItem to first item
      // iterate through all items until the link is NULL
      tempItem = first_item;
      while (tempItem->link != NULL){
	tempItem = tempItem->link;
      }

      // set the previous last item's link to the new item
      tempItem->link = newItem;
      return first_item;
    }

    // if the item is already present in the list 
    // update the number for the item
    // if number <= 0, delete the item
    else{
      tempItem->num = tempItem->num + num_update;
      if (tempItem->num <= 0){
	first_item = delete(first_item,tempItem->name);
      }
      return first_item;
    }
  }

  return first_item;
}


/* MAIN METHOD! */
int main(int argc, char *argv[]){
  if (argc < 2){
    fprintf(stderr,"Not enough arguments. Please try again.\n");
  }
  else if (argc >= 2){
      FILE *fp;
      int c;
      struct item *first = NULL;

      fp = fopen(argv[1], "r");
 
      // if file is not null
      if (fp != NULL){

	// while the end of the file has not yet been reached
	while (feof(fp) == 0){
	  char tempName[120];
	  int numRead;
	  int tempNum;

	  // read next line
	  // store the values of name and number of items
	  // (if they exist)
	  numRead = fscanf(fp,"%s%d",tempName,&tempNum);
	  if (numRead == 2){

	    // make name all caps
	    int x;
	    for (x = 0; x < 120; x++){
	      if (tempName[x] != 0){
		tempName[x] = toupper((int)tempName[x]);
	      }
	      else
		break;
	    }

	    // check if number is negative, and if it is, if the item already exists
	    // if so -- don't add, too inefficient
	    if (tempNum <= 0){
	      if (find(first, tempName) != NULL)
		first = add(first, tempName, tempNum);
	    }
	    else{
	      first = add(first, tempName, tempNum);
	    }
	  }
	  
	  else {
	    fprintf(stderr, "Error: incorrect formatting. Line ignored.\n");
	  } 
	}
      }
      
      // do some printing shiz!
      struct item *currNode = first;
      if (first != NULL){
	printf("%s", "Final Order:\n");

	while (currNode->link != NULL){
	  printf("%s", currNode->name);
	  printf("%s", "\t\t");
	  printf("%i", currNode->num);
	  printf("%s", "\n");
	  struct item *prev = currNode;
	  currNode = currNode->link;
	  free(prev->name);
	  free(prev);
	}

	// print last item
	printf("%s", currNode->name);
        printf("%s", "\t\t");
	printf("%i", currNode->num);
	printf("%s", "\n");
	free(currNode->name);
	free(currNode);
      }

      else{
	printf("%s", "Final Order:\n");
      }

      fclose(fp);
  }
  return 0;
}
