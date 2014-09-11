//
//  NSIndexPath+VMCompositeDataSourcesAdditions.m
//  Pods
//
//  Created by Valerio Mazzeo on 10/09/2014.
//  Copyright (c) 2014 Valerio Mazzeo. All rights reserved.
//

#import <objc/runtime.h>
#import "NSIndexPath+VMCompositeDataSourcesAdditions.h"

static char kVMCompositeDataSourcesAdditions;

@implementation NSIndexPath (VMCompositeDataSourcesAdditions)

- (NSIndexPath *)compositeDataSourceIndexPath
{
    return objc_getAssociatedObject(self, &kVMCompositeDataSourcesAdditions);
}

- (void)setCompositeDataSourceIndexPath:(NSIndexPath *)compositeDataSourceIndexPath
{
    objc_setAssociatedObject(self, &kVMCompositeDataSourcesAdditions, compositeDataSourceIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
