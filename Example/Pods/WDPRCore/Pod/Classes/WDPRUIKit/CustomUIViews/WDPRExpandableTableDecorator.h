//
//  WDPRExpandableTableStrategy.h
//  DLR
//
//  Created by Francisco Valbuena on 4/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import <Foundation/Foundation.h>

@protocol WDPRExpandableTableDecoratorDatasource, WDPRExpandableTableDecoratorDelegate;

@interface WDPRExpandableTableDecorator : NSObject

@property (nonatomic, assign) BOOL scrollToShowLastAddedRow;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, weak) id<WDPRExpandableTableDecoratorDelegate> delegate;
@property (nonatomic, weak) id<WDPRExpandableTableDecoratorDatasource> datasource;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (void)reloadData;
- (void)reloadDataAnimated;
- (void)collapseAllRows;
- (BOOL)isRowAtIndexPathExpanded:(NSIndexPath *)indexPath;
- (id)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)expandIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)convertToTableIndexPath:(NSIndexPath *)idxPath;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (void)insertRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)moveRowAtFirstLevelIndexPath:(NSIndexPath *)indexPath toFirstLevelIndexPath:(NSIndexPath *)newIndexPath;

- (void)toggleExpandRowAtIndexPath:(NSIndexPath *)idxPath;
@end

@interface NSIndexPath (WDPRExpandableTable)
@property (nonatomic, readonly) NSUInteger firstLevelRow;
@property (nonatomic, readonly) NSUInteger secondLevelRow;
@end

@protocol WDPRExpandableTableDecoratorDatasource <NSObject>

@required
- (NSInteger)tableView:(WDPRExpandableTableDecorator *)tableView numberOfFirstLevelRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(WDPRExpandableTableDecorator *)tableView cellForFirstLevelRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)tableView:(WDPRExpandableTableDecorator *)tableView numberOfSecondLevelRowsInRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(WDPRExpandableTableDecorator *)tableView cellForSecondLevelRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(WDPRExpandableTableDecorator *)tableView;

@end

@protocol WDPRExpandableTableDecoratorDelegate <NSObject>

@optional
- (void)tableViewDidScroll:(WDPRExpandableTableDecorator *)tableView;
- (BOOL)tableView:(WDPRExpandableTableDecorator *)tableView canExpandRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(WDPRExpandableTableDecorator *)tableView willExpandRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(WDPRExpandableTableDecorator *)tableView willCollapseRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(WDPRExpandableTableDecorator *)tableView didExpandRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(WDPRExpandableTableDecorator *)tableView didCollapseRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(WDPRExpandableTableDecorator *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(WDPRExpandableTableDecorator *)tableView estimatedHeightForFirstLevelRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(WDPRExpandableTableDecorator *)tableView estimatedHeightForSecondLevelRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(WDPRExpandableTableDecorator *)tableView heightForFirstLevelRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(WDPRExpandableTableDecorator *)tableView heightForSecondLevelRowAtIndexPath:(NSIndexPath *)indexPath;

@end
