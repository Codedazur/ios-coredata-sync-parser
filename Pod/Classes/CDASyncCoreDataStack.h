//
//  CDASyncCoreDataStack.h
//  Pods
//
//  Created by Tamara Bernad on 29/01/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol CDASyncCoreDataStack <NSObject>
+ (NSManagedObjectContext *)mainManagedObjectContext;
+ (NSManagedObjectContext *)independentManagedObjectContext;
+ (NSManagedObject *)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
@end
