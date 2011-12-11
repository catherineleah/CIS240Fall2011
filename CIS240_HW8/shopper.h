/*
 * shopper.h
 */

struct item;
struct item *find(struct item *first_item, char *searchName);
struct item *delete(struct item *first_item, char *delName);
struct item *add(struct item *first_item, char *item_name, int num_update);
