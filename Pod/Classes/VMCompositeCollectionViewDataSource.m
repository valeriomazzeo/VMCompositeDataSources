//
//  VMCompositeCollectionViewDataSource.m
//  Pods
//
//  Created by Valerio Mazzeo on 10/09/2014.
//  Copyright (c) 2014 Valerio Mazzeo. All rights reserved.
//

#import <objc/runtime.h>
#import "VMCompositeCollectionViewDataSource.h"
#import "NSIndexPath+VMCompositeDataSourcesAdditions.h"
#import "NSIndexPath+VMCompositeDataSourcesAdditions_Private.h"

@interface VMCompositeCollectionViewDataSource ()

@property (nonatomic, strong) NSMutableArray *dataSources; // id<UICollectionViewDataSource> objects

@end

@implementation VMCompositeCollectionViewDataSource

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
    id<UICollectionViewDataSource> dataSource = [self dataSourceForSection:indexPath.section];
    
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
    
    [self.dataSources enumerateObjectsUsingBlock:^(id<UICollectionViewDataSource> dataSource, NSUInteger idx, BOOL *stop) {
        
        if ([dataSource respondsToSelector:@selector(indexPathForObject:)]) {
            
            indexPath = [dataSource performSelector:@selector(indexPathForObject:) withObject:object];
            
            *stop = !!indexPath;
        }
        
    }];
    
    return indexPath;
}

#pragma mark - Conversion Methods

- (NSInteger)sectionForDataSource:(id<UICollectionViewDataSource>)dataSource
{
    return [self.dataSources indexOfObject:dataSource];
}

- (id<UICollectionViewDataSource>)dataSourceForSection:(NSInteger)section
{
    return self.dataSources[section];
}

- (NSIndexPath *)indexPathForDataSource:(id<UICollectionViewDataSource>)dataSource compositeDataSourceIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *result = nil;
    
    NSInteger sectionCount = [dataSource numberOfSectionsInCollectionView:nil];
    
    for (// E1
         NSInteger section = 0, rowLocation = 0, itemCount = 0;
         // E2
         section < sectionCount;
         // E3
         section++, rowLocation += itemCount)
    {
        itemCount = [dataSource collectionView:nil numberOfItemsInSection:section];
        
        if (NSLocationInRange(indexPath.row, NSMakeRange(rowLocation, itemCount))) {
            
            result = [NSIndexPath indexPathForRow:indexPath.row - rowLocation inSection:section];
            break;
        }
    }
    
    return result;
}

- (NSIndexPath *)compositeDataSourceIndexPathForDataSource:(id<UICollectionViewDataSource>)dataSource withIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [self sectionForDataSource:dataSource];
    NSInteger row = 0;
    
    NSInteger itemCount = 0;
    
    for (NSInteger i = 0; i < indexPath.section; i++) {

        itemCount += [dataSource collectionView:nil numberOfItemsInSection:i];
    }
    
    row = itemCount + indexPath.row;
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSources.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<UICollectionViewDataSource> dataSource = [self dataSourceForSection:section];
    
    NSInteger sectionCount = [dataSource numberOfSectionsInCollectionView:collectionView];
    
    NSInteger itemCount = 0;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        itemCount += [dataSource collectionView:collectionView numberOfItemsInSection:section];
    };
    
    return itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDataSource> dataSource = [self dataSourceForSection:indexPath.section];
    
    NSIndexPath *dataSourceIndexPath = [self indexPathForDataSource:dataSource compositeDataSourceIndexPath:indexPath];
    
    dataSourceIndexPath.compositeDataSourceIndexPath = indexPath;
    
    return [dataSource collectionView:collectionView cellForItemAtIndexPath:dataSourceIndexPath];
}

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

- (void)addDataSourcesObject:(id<UICollectionViewDataSource>)object
{
    [self insertObject:object inDataSourcesAtIndex:self.dataSources.count];
}

- (id<UICollectionViewDataSource>)objectInDataSourcesAtIndex:(NSUInteger)index
{
    return [self.dataSources objectAtIndex:index];
}

- (NSArray *)dataSourcesAtIndexes:(NSIndexSet *)indexes
{
    return [self.dataSources objectsAtIndexes:indexes];
}

- (void)getDataSources:(id<UICollectionViewDataSource> __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [self.dataSources getObjects:buffer range:inRange];
}

- (void)insertObject:(id<UICollectionViewDataSource>)object inDataSourcesAtIndex:(NSUInteger)index
{
    [self.dataSources insertObject:object atIndex:index];
}

- (void)insertDataSources:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.dataSources insertObjects:array atIndexes:indexes];
}

- (void)replaceObjectInDataSourcesAtIndex:(NSUInteger)index withObject:(id<UICollectionViewDataSource>)object
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

@implementation UICollectionView (VMCompositeCollectionViewDataSource)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(dequeueReusableCellWithReuseIdentifier:forIndexPath:);
        SEL swizzledSelector = @selector(vm_dequeueReusableCellWithReuseIdentifier:forIndexPath:);
        
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

- (id)vm_dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath
{
    if ([self.dataSource isKindOfClass:[VMCompositeCollectionViewDataSource class]]) {
        indexPath = indexPath.compositeDataSourceIndexPath;
    }
    
    return [self vm_dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

@end
