//
//  CoreDataStack.h
//  CoreDataExample
//
//  Created by Tamara Bernad on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDASyncCoreDataStack.h"


@interface CoreDataStack : NSObject<CDASyncCoreDataStack>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (NSInteger)countWithEntity:(NSString *)entity AndPredicate:(NSPredicate *)predicate;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)childManagedObjectContext;
- (NSManagedObjectContext *)independentManagedObjectContext;
+ (CoreDataStack *)coreDataStack;
#pragma mark - main context
+ (NSManagedObject *)createdEntityWithName:(NSString *)entityName;
+ (NSArray *)fetchMainContextEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate;

#pragma mark - specific context
+ (NSManagedObject *) fetchEntity:(NSString *)entityName withUID:(NSString *)uid;
+ (NSManagedObject *)fetchMainContextEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate;
+ (NSManagedObject *)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntities:(NSString *)entity WithSortDescriptors:(NSArray *)sortDescriptors WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (NSManagedObject *) createNewObject:(NSString *)entity inContext:(NSManagedObjectContext *)context;
+ (NSManagedObject *) fetchEntity:(NSString *)entityName withUID:(NSString *)uid inContext:(NSManagedObjectContext *)context;
+ (NSInteger) countEntitiesInMainContext:(NSString *)entity WithPredicate:(NSPredicate *)predicate;
+ (NSInteger) countEntities:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;

@end
