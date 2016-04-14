/*
 
 Copyright (c) 2015 Code d'Azur <info@codedazur.nl>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CDAAbstractCoreDataParser.h"
#import <objc/runtime.h>

@interface CDAAbstractCoreDataParser()
/*!
 * @brief identify the parser, should be set to the entity that is being parsed
 */
@property (nonatomic, strong) NSString *uid;
/*!
 * @brief the name of the Core Data entity that is going to be istanciated
 */
@property (nonatomic, strong) NSString *entityName;
/*!
 * @brief the key of the id value retrieved from the imported data
 */
@property (nonatomic, strong) NSString *uidKey;
/*!
 * @brief how many rows we want to process before saving, autoreleasing and resetting the context
 */
@property (nonatomic) NSInteger batchSize;
/*!
 * @brief progress of current parsing
 */
@property (nonatomic) double progress;
/*!
 * @brief if the parsing has finished
 */
@property (nonatomic) BOOL finished;
/*!
 * @brief context used to create and update the entities
 */
@property (nonatomic, strong) NSManagedObjectContext *context;
/*!
 * @brief to map attributes that are different in the internal database than the data that comes externally
 */
@property (nonatomic, strong) NSDictionary *attributesMapping;
/*!
 * @brief describes the conversions needed to do between internal and external data, for example NSNumber to NSString
 */
@property (nonatomic, strong) NSArray *attributesConversions;

@property (nonatomic, strong) Class<CDASyncCoreDataStack> coreDataStack;
@end
@implementation CDAAbstractCoreDataParser

#pragma mark - init
- (instancetype)initWithUid:(NSString *)uid
                 entityName:(NSString *)entityName
                 dataUidKey:(NSString *)uidKey
                  batchSize:(NSInteger)batchSize
          attributesMapping:(NSDictionary *)attributesMapping
      attributesConversions:(NSArray *)attributesConversions{
    
    if(!(self = [self initWithUid:uid entityName:entityName dataUidKey:uidKey batchSize:batchSize attributesMapping:attributesMapping]))return self;
    self.attributesConversions = attributesConversions;
    return self;
}
- (instancetype)initWithUid:(NSString *)uid
                 entityName:(NSString *)entityName
                 dataUidKey:(NSString *)uidKey
                  batchSize:(NSInteger)batchSize
          attributesMapping:(NSDictionary *)attributesMapping{
    
    if(!(self = [self initWithUid:uid entityName:entityName dataUidKey:uidKey batchSize:batchSize]))return self;
    self.attributesMapping = attributesMapping;
    return self;
}
- (instancetype)initWithUid:(NSString *)uid
                 entityName:(NSString *)entityName
                 dataUidKey:(NSString *)uidKey
                  batchSize:(NSInteger)batchSize{

    if(!(self = [self initWithUid:uid entityName:entityName dataUidKey:uidKey]))return self;
    self.batchSize = batchSize;
    return self;
}
- (instancetype)initWithUid:(NSString *)uid
                 entityName:(NSString *)entityName
                 dataUidKey:(NSString *)uidKey{
    if(!(self = [super init]))return self;
    self.uid = uid;
    self.entityName = entityName;
    self.uidKey = uidKey;
    self.batchSize = 50;
    return self;
}

#pragma mark - CDASyncParserProtocol
- (void)parseData:(id)data AndCompletion:(void (^)(id))completion{
    [self.context performBlock:^{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onManagedObjectContextSave:) name:NSManagedObjectContextDidSaveNotification object:_context];
    
    self.finished = NO;
    
    NSArray *inputData = [data sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:self.uidKey ascending:YES]]];
    NSArray *entityInputIds = [inputData valueForKey:self.uidKey];
    NSArray *entitiesToRemove = [self dataIncluded:NO InArrayOfIds:entityInputIds WithEntityName:self.entityName];
    [self removeItems:entitiesToRemove];
    
    NSArray *storedEntitiesInInput = [self dataIncluded:YES InArrayOfIds:entityInputIds WithEntityName:self.entityName];
    NSArray *storedIds = [storedEntitiesInInput valueForKey:@"uid"];
    [self.context reset];
    
    for (int i=0; i<((NSArray *)inputData).count;) {
        @autoreleasepool
        {
            for (NSUInteger j = 0; j < self.batchSize && i < ((NSArray *)inputData).count; j++, i++)
            {
                NSManagedObject *storedObject;
                NSDictionary *record;
                NSString *inputUid;
                NSUInteger storedIdIndex;
                
                record = [inputData objectAtIndex:i];
                
                if (![[record valueForKey:self.uidKey] isKindOfClass:[NSString class]]) {
                    inputUid = [[record valueForKey:self.uidKey] stringValue];
                }else{
                    inputUid = [record valueForKey:self.uidKey];
                }
                storedIdIndex = [storedIds indexOfObject:inputUid];
                if (storedIdIndex != NSNotFound) {
                    storedObject = [self.coreDataStack fetchEntity:self.entityName WithPredicate:[NSPredicate predicateWithFormat:@"uid == %@",inputUid] InContext:self.context];
                }else{
                    storedObject = [self createObjectOfEntitiy:self.entityName];
                }
                
                
                [self updateValuesOfRecord:record IntoEntity:storedObject];
                
                _progress = (double)i/(double)((NSArray *)inputData).count;
            }
            
            [self save];
            [self.context reset];
        }
    }
    
    [self save];
    [self.context reset];
    self.finished = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.context];
        completion(nil);//TODO inside the block?
    }];
}

#pragma mark - helpers
- (void) updateValuesOfRecord:(NSDictionary *)record IntoEntity:(NSManagedObject *)storedObject{

    for (NSString *key in [record allKeys]) {
        BOOL wasAutomated = [self tryAutomaticValuesUpdate:record IntoEntity:storedObject ForKey:key];
        if (!wasAutomated) {
            BOOL wasMapped = [self tryMappingValuesUpdate:record IntoEntity:storedObject ForKey:key];
            if (!wasMapped) {
                NSLog(@"Parser with id %@ could not store key %@", self.uid, key);
            }
        }
    }

}
- (BOOL) tryMappingValuesUpdate:(NSDictionary *)record IntoEntity:(NSManagedObject *)storedObject ForKey:(NSString *)key{
    if([[self.attributesMapping allKeys] containsObject:key]){
        NSString *mappedKey = [self.attributesMapping objectForKey:key];
        [storedObject setValue:[record valueForKey:key] forKey:mappedKey];
        return YES;
    }else{
        return NO;
    }
}
- (BOOL) tryAutomaticValuesUpdate:(NSDictionary *)record IntoEntity:(NSManagedObject *)storedObject ForKey:(NSString *)key{
    if ([storedObject respondsToSelector:NSSelectorFromString(key)] ) {
        if([[record valueForKey:key] isEqual:[NSNull null]]){
            [storedObject setValue:nil forKey:key];
        }else{
            
            objc_property_t theProperty = class_getProperty([storedObject class], key.UTF8String);
            const char * propertyAttrs = property_getAttributes(theProperty);
            NSString *property = [NSString stringWithUTF8String:propertyAttrs];
            property = [[property componentsSeparatedByString:@","] firstObject];
            
            property = [self stringBetweenString:@"\"" andString:@"\"" WithString:property];
            if([[record valueForKey:key] isKindOfClass:NSClassFromString(property)]){
                [storedObject setValue:[record valueForKey:key] forKey:key];
            }
            else{
                NSLog(@"Parser with id %@ found incompatible data types for key %@ trying with attributes conversion", self.uid, key);
                [self tryAttributesConversion:record IntoEntity:storedObject ForKey:key];
            }
        }
        return YES;
    }
    return NO;
}
- (void) tryAttributesConversion:(NSDictionary *)record IntoEntity:(NSManagedObject *)storedObject ForKey:(NSString *)key{
    NSInteger index = [[self.attributesConversions valueForKeyPath:@"key"] indexOfObject:key];

    if(index != NSNotFound){
        NSDictionary *property = [self.attributesConversions objectAtIndex:index];
        NSString *className = [property valueForKey:@"className"];
        if(![[record valueForKey:key] isKindOfClass:NSClassFromString(className)]){
            
            // if what comes from server is a number but we expect a string
            if ([[storedObject valueForKey:key] isKindOfClass:[NSString class]] &&
                [[record valueForKey:key] isKindOfClass:[NSNumber class]]) {
                
                [storedObject setValue:[[record valueForKey:key] stringValue] forKey:key];
                
            }
            // if what comes from server is a string but we expect a number
            else if([[storedObject valueForKey:key] isKindOfClass:[NSNumber class]] &&
                    [[record valueForKey:key] isKindOfClass:[NSString class]]) {
                
                [storedObject setValue:[NSNumber numberWithDouble:[[record valueForKey:key] doubleValue]] forKey:key];
                
            }else{
                NSLog(@"Parser with id %@ can't convert %@ to %@ feel free to add this implementation", self.uid, NSStringFromClass([[record valueForKey:key] class]) ,className);
            }
        }
    }
}
- (NSString*) stringBetweenString:(NSString*)start andString:(NSString*)end WithString:(NSString *)initString {
    NSScanner* scanner = [NSScanner scannerWithString:initString];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}
- (BOOL) save{
    if ([self.context hasChanges]) {
        
        [self.context performBlockAndWait:^{
            NSError *error;
            if (![self.context save:&error])
            {
                NSLog(@"Parser with id %@ error saving context %@",self.uid,error);
            }
        }];
    }
    return YES;
}
- (NSManagedObjectContext *)context{
    if(!_context){
        _context = [self.coreDataStack independentManagedObjectContext];
    }
    return _context;
}
-(NSManagedObject *)createObjectOfEntitiy:(NSString *)entity{
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:entity
                                                         inManagedObjectContext:self.context];
    
    return obj;
    
}
-(void)removeItems:(NSArray *)items{
    [self.context performBlockAndWait:^{
        for (NSManagedObject *managedObject in items) {
            [self.context deleteObject:managedObject];
        }
        [self save];
        [self.context reset];
    }];
}
- (NSArray *)dataIncluded:(BOOL)included InArrayOfIds:(NSArray *)ids WithEntityName:(NSString *)entity{
    
    NSPredicate *predicate = included ? [NSPredicate predicateWithFormat:@"uid IN %@", ids]:[NSPredicate predicateWithFormat:@"NOT (uid IN %@)", ids];
    return [self.coreDataStack fetchEntities:entity WithSortKey:@"uid" Ascending:YES WithPredicate:predicate InContext:self.context];
}
- (void)onManagedObjectContextSave:(NSNotification *)notification{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[self.coreDataStack mainManagedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
    });
}
@end
