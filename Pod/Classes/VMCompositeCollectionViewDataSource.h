//
//  VMCompositeCollectionViewDataSource.h
//  Pods
//
//  Created by Valerio Mazzeo on 10/09/2014.
//  Copyright (c) 2014 Valerio Mazzeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol VMCompositeCollectionViewDataSource <UICollectionViewDataSource>

@optional

#pragma mark - Accessing Objects

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

@end

@interface VMCompositeCollectionViewDataSource : NSObject <VMCompositeCollectionViewDataSource>

#pragma mark - Conversion Methods

- (NSInteger)sectionForDataSource:(id<UICollectionViewDataSource>)dataSource;
- (id<UICollectionViewDataSource>)dataSourceForSection:(NSInteger)section;

- (NSIndexPath *)indexPathForDataSource:(id<UICollectionViewDataSource>)dataSource compositeDataSourceIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)compositeDataSourceIndexPathForDataSource:(id<UICollectionViewDataSource>)dataSource withIndexPath:(NSIndexPath *)indexPath;

#pragma mark - KVO Compliance Methods

- (NSUInteger)countOfDataSources;
- (void)addDataSourcesObject:(id<UICollectionViewDataSource>)object;
- (id<UITableViewDataSource>)objectInDataSourcesAtIndex:(NSUInteger)index;
- (NSArray *)dataSourcesAtIndexes:(NSIndexSet *)indexes;
- (void)getDataSources:(id<UICollectionViewDataSource> __unsafe_unretained *)buffer range:(NSRange)inRange;

- (void)insertObject:(id<UICollectionViewDataSource>)object inDataSourcesAtIndex:(NSUInteger)index;
- (void)insertDataSources:(NSArray *)array atIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectInDataSourcesAtIndex:(NSUInteger)index withObject:(id<UICollectionViewDataSource>)object;
- (void)replaceDataSourcesAtIndexes:(NSIndexSet *)indexes withDataSources:(NSArray *)array;

- (void)removeObjectFromDataSourcesAtIndex:(NSUInteger)index;
- (void)removeDataSourcesAtIndexes:(NSIndexSet *)indexes;

@end

@interface UICollectionView (VMCompositeCollectionViewDataSource)

@end
