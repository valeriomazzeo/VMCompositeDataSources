//
//  VMCompositeTableViewDataSource.h
//  Pods
//
//  Created by Valerio Mazzeo on 10/09/2014.
//  Copyright (c) 2014 Valerio Mazzeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol VMCompositeTableViewDataSource <UITableViewDataSource>

@optional

#pragma mark - Accessing Objects

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

@end

@interface VMCompositeTableViewDataSource : NSObject <VMCompositeTableViewDataSource>

#pragma mark - Conversion Methods

- (NSInteger)sectionForDataSource:(id<UITableViewDataSource>)dataSource;
- (id<UITableViewDataSource>)dataSourceForSection:(NSInteger)section;

- (NSIndexPath *)indexPathForDataSource:(id<UITableViewDataSource>)dataSource compositeDataSourceIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)compositeDataSourceIndexPathForDataSource:(id<UITableViewDataSource>)dataSource withIndexPath:(NSIndexPath *)indexPath;

#pragma mark - KVO Compliance Methods

- (NSUInteger)countOfDataSources;
- (void)addDataSourcesObject:(id<UITableViewDataSource>)object;
- (id<UITableViewDataSource>)objectInDataSourcesAtIndex:(NSUInteger)index;
- (NSArray *)dataSourcesAtIndexes:(NSIndexSet *)indexes;
- (void)getDataSources:(id<UITableViewDataSource> __unsafe_unretained *)buffer range:(NSRange)inRange;

- (void)insertObject:(id<UITableViewDataSource>)object inDataSourcesAtIndex:(NSUInteger)index;
- (void)insertDataSources:(NSArray *)array atIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectInDataSourcesAtIndex:(NSUInteger)index withObject:(id<UITableViewDataSource>)object;
- (void)replaceDataSourcesAtIndexes:(NSIndexSet *)indexes withDataSources:(NSArray *)array;

- (void)removeObjectFromDataSourcesAtIndex:(NSUInteger)index;
- (void)removeDataSourcesAtIndexes:(NSIndexSet *)indexes;

@end

@interface UITableView (VMCompositeTableViewDataSource)

@end
