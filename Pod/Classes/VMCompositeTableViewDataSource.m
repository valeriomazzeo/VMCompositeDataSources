//
//  VMCompositeTableViewDataSource.m
//  Pods
//
//  Created by Valerio Mazzeo on 10/09/2014.
//  Copyright (c) 2014 Valerio Mazzeo. All rights reserved.
//

#import <objc/runtime.h>
#import "VMCompositeTableViewDataSource.h"
#import "VMCompositeIndexPath.h"

@interface VMCompositeTableViewDataSource ()

@property (nonatomic, strong) NSMutableArray *dataSources; // id<UITableViewDataSource> objects

@end

@implementation VMCompositeTableViewDataSource

#pragma mark - Properties

- (NSMutableArray *)dataSources
{
    if (!_dataSources) {
        _dataSources = [NSMutableArray new];
    }
    return _dataSources;
}

/*
#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        
        // In case we need to observe changes to the mutable array
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(dataSources)) options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

#pragma mark - Finalization

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(dataSources)) context:nil];
}
*/

#pragma mark - VMCompositeTableViewDataSource Objects

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDataSource> dataSource = [self dataSourceForSection:indexPath.section];
    
    id object = nil;
    
    if ([dataSource respondsToSelector:@selector(objectAtIndexPath:)]) {
        
        object = [dataSource performSelector:@selector(objectAtIndexPath:)
                                  withObject:[self indexPathForDataSource:dataSource compositeDataSourceIndexPath:indexPath]];
    }
    
    return object;
}

- (NSIndexPath *)indexPathForObject:(id)object
{
    __block NSIndexPath *indexPath = nil;
    
    [self.dataSources enumerateObjectsUsingBlock:^(id<UITableViewDataSource> dataSource, NSUInteger idx, BOOL *stop) {
        
        if ([dataSource respondsToSelector:@selector(indexPathForObject:)]) {
            
            indexPath = [dataSource performSelector:@selector(indexPathForObject:) withObject:object];
            
            *stop = !!indexPath;
        }
        
    }];
    
    return indexPath;
}

#pragma mark - Conversion Methods

- (NSInteger)sectionForDataSource:(id<UITableViewDataSource>)dataSource
{
    return [self.dataSources indexOfObject:dataSource];
}

- (id<UITableViewDataSource>)dataSourceForSection:(NSInteger)section
{
    return self.dataSources[section];
}

- (NSIndexPath *)indexPathForDataSource:(id<UITableViewDataSource>)dataSource compositeDataSourceIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *result = nil;
    
    NSInteger sectionCount = [dataSource numberOfSectionsInTableView:nil];
    
    for (// E1
         NSInteger section = 0, rowLocation = 0, itemCount = 0;
         // E2
         section < sectionCount;
         // E3
         section++, rowLocation += itemCount)
    {
        itemCount = [dataSource tableView:nil numberOfRowsInSection:section];
        
        if (NSLocationInRange(indexPath.row, NSMakeRange(rowLocation, itemCount))) {
            
            result = [NSIndexPath indexPathForRow:indexPath.row - rowLocation inSection:section];
            break;
        }
    }
    
    return result;
}

- (NSIndexPath *)compositeDataSourceIndexPathForDataSource:(id<UITableViewDataSource>)dataSource withIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [self sectionForDataSource:dataSource];
    NSInteger row = 0;
    
    NSInteger itemCount = 0;
    
    for (NSInteger i = 0; i < indexPath.section; i++) {

        itemCount += [dataSource tableView:nil numberOfRowsInSection:i];
    }
    
    row = itemCount + indexPath.row;
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<UITableViewDataSource> dataSource = [self dataSourceForSection:section];
    
    NSInteger sectionCount = [dataSource numberOfSectionsInTableView:tableView];
    
    NSInteger itemCount = 0;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        itemCount += [dataSource tableView:tableView numberOfRowsInSection:section];
    };
    
    return itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDataSource> dataSource = [self dataSourceForSection:indexPath.section];
    
    NSIndexPath *dataSourceIndexPath = [self indexPathForDataSource:dataSource compositeDataSourceIndexPath:indexPath];
    
    NSUInteger dataSourceIndexPathIndexes[dataSourceIndexPath.length];
    [dataSourceIndexPath getIndexes:dataSourceIndexPathIndexes];
    
    VMCompositeIndexPath *compositeIndexPath = [[VMCompositeIndexPath alloc] initWithIndexes:dataSourceIndexPathIndexes length:2];
    compositeIndexPath.compositeDataSourceIndexPath = indexPath;
    
    return [dataSource tableView:tableView cellForRowAtIndexPath:compositeIndexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEditRowAtIndexPath = YES;
    
    id<UITableViewDataSource> dataSource = [self dataSourceForSection:indexPath.section];
    
    if ([dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        
        NSIndexPath *dataSourceIndexPath = [self indexPathForDataSource:dataSource compositeDataSourceIndexPath:indexPath];
        
        canEditRowAtIndexPath = [dataSource tableView:tableView canEditRowAtIndexPath:dataSourceIndexPath];
    }
    
    return canEditRowAtIndexPath;
}

/* TODO: forward these methods to the internal data sources
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
 - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
 
 // Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
 
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))
 
 // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
 
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
 */

/*
#pragma mark - KVO Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataSources))]) {
        NSLog(@"Something changed");
    }
}
*/

#pragma mark - KVO Compliance Methods

- (NSUInteger)countOfDataSources
{
    return self.dataSources.count;
}

- (void)addDataSourcesObject:(id<UITableViewDataSource>)object
{
    [self insertObject:object inDataSourcesAtIndex:self.dataSources.count];
}

- (id<UITableViewDataSource>)objectInDataSourcesAtIndex:(NSUInteger)index
{
    return [self.dataSources objectAtIndex:index];
}

- (NSArray *)dataSourcesAtIndexes:(NSIndexSet *)indexes
{
    return [self.dataSources objectsAtIndexes:indexes];
}

- (void)getDataSources:(id<UITableViewDataSource> __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [self.dataSources getObjects:buffer range:inRange];
}

- (void)insertObject:(id<UITableViewDataSource>)object inDataSourcesAtIndex:(NSUInteger)index
{
    [self.dataSources insertObject:object atIndex:index];
}

- (void)insertDataSources:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.dataSources insertObjects:array atIndexes:indexes];
}

- (void)replaceObjectInDataSourcesAtIndex:(NSUInteger)index withObject:(id<UITableViewDataSource>)object
{
    [self.dataSources replaceObjectAtIndex:index withObject:object];
}

- (void)replaceDataSourcesAtIndexes:(NSIndexSet *)indexes withDataSources:(NSArray *)array
{
    [self.dataSources replaceObjectsAtIndexes:indexes withObjects:array];
}

- (void)removeObjectFromDataSourcesAtIndex:(NSUInteger)index
{
    [self.dataSources removeObjectAtIndex:index];
}

- (void)removeDataSourcesAtIndexes:(NSIndexSet *)indexes
{
    [self.dataSources removeObjectsAtIndexes:indexes];
}

@end

@implementation UITableView (VMCompositeTableViewDataSource)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(dequeueReusableCellWithIdentifier:forIndexPath:);
        SEL swizzledSelector = @selector(vm_dequeueReusableCellWithIdentifier:forIndexPath:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (id)vm_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource isKindOfClass:[VMCompositeTableViewDataSource class]] && [indexPath isKindOfClass:[VMCompositeIndexPath class]]) {
        indexPath = [(VMCompositeIndexPath *)indexPath compositeDataSourceIndexPath];
    }
    
    return [self vm_dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

@end
