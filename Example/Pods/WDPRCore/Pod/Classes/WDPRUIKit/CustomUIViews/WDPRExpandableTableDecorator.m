//
//  WDPRExpandableTableStrategy.m
//  DLR
//
//  Created by Francisco Valbuena on 4/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRExpandableTableDecorator.h"

static const CGFloat kDefaultCellHeight = 44;
static const CGFloat kMinEstimatedCellHeight = 2; // A smaller value causes a crash.
static const NSUInteger kFirstLevelRowPosition = 2;
static const NSUInteger kSecondLevelRowPosition = 3;

@interface WDPRExpandableTableDecorator () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSIndexSet *secondLevelTableRows; // TODO: we are only considering single section scenarios
@property (nonatomic, strong) NSMutableIndexSet *autoExpandedTableRows;
@end

@implementation WDPRExpandableTableDecorator

#pragma mark - NSObject

- (void)dealloc
{
    // Previous to iOS9, UITableView doesn't use 'weak' for those 2 properties.
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString *selector = NSStringFromSelector(aSelector);
    NSString *estimatedHeightSelector = NSStringFromSelector(@selector(tableView:estimatedHeightForRowAtIndexPath:));
    
    if ([selector isEqualToString:estimatedHeightSelector] )
    {
        BOOL reponds = [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForFirstLevelRowAtIndexPath:)];
        
        return reponds;
    }
    
    return [super respondsToSelector:aSelector];
}

#pragma mark - WDPRExpandableTableStrategy

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    
    if (self)
    {
        _tableView = tableView;
        _autoExpandedTableRows = [NSMutableIndexSet new];
        _secondLevelTableRows = [NSIndexSet new];
    }
    
    return self;
}

- (void)reloadData
{
    self.secondLevelTableRows = nil;
    [self.tableView reloadData];
}

- (void)setDelegate:(id<WDPRExpandableTableDecoratorDelegate>)delegate
{
    _delegate = delegate;
    self.tableView.delegate = self;
}

- (void)setDatasource:(id<WDPRExpandableTableDecoratorDatasource>)datasource
{
    _datasource = datasource;
    self.tableView.dataSource = self;
}

- (void)reloadDataAnimated
{
    self.secondLevelTableRows = nil;
    [self.tableView reloadDataAnimated:UITableViewRowAnimationAutomatic];
}

- (void)collapseAllRows
{
    NSMutableIndexSet *firstLevelRows = [NSMutableIndexSet new];
    NSMutableArray *indexPathsToCollapse = [NSMutableArray new];
    
    [self.secondLevelTableRows enumerateIndexesUsingBlock:^(NSUInteger secondLevelTableRow, BOOL *stop)
    {
        [firstLevelRows addIndex:[self computeFirstLevelRowForTableRow:secondLevelTableRow]];
    }];
    
    [firstLevelRows enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop)
    {
        [indexPathsToCollapse addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }];
    [self collapseRowsAtFirstLevelIndexPaths:indexPathsToCollapse];
}

- (BOOL)isRowAtIndexPathExpanded:(NSIndexPath *)indexPath
{
    if (indexPath.secondLevelRow != NSNotFound)
    {
        return NO;
    }
    
    NSIndexPath *tableRow = [self convertToTableIndexPath:indexPath];
    
    return [self.secondLevelTableRows containsIndex:tableRow.row + 1];
}

- (NSIndexPath *)convertToTableIndexPath:(NSIndexPath *)idxPath
{
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:[idxPath indexAtPosition:0]];
    
    indexPath = [indexPath indexPathByAddingIndex:[idxPath indexAtPosition:1]];
    return indexPath;
}

- (id)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableView cellForRowAtIndexPath:[self convertToTableIndexPath:indexPath]];
}

- (NSIndexPath *)expandIndexPath:(NSIndexPath *)indexPath
{
    return [self addLevelRowsToIndexPath:indexPath];
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [self.tableView dequeueReusableCellWithIdentifier:identifier];
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)idxPath
{
    return [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:[self convertToTableIndexPath:idxPath]];
}

- (void)insertRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView insertRowsAtIndexPaths:[self convertFirstLevelIndexPathsForTable:indexPaths]
                          withRowAnimation:animation];
}

- (void)deleteRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView deleteRowsAtIndexPaths:[self convertFirstLevelIndexPathsForTable:indexPaths]
                          withRowAnimation:animation];
}

- (void)reloadRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView reloadRowsAtIndexPaths:[self convertFirstLevelIndexPathsForTable:indexPaths]
                          withRowAnimation:animation];
}

- (void)moveRowAtFirstLevelIndexPath:(NSIndexPath *)indexPath toFirstLevelIndexPath:(NSIndexPath *)newIndexPath
{
    [self.tableView moveRowAtIndexPath:[self convertFirstLevelIndexPathToTable:indexPath]
                           toIndexPath:[self convertFirstLevelIndexPathToTable:newIndexPath]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)idxPath
{
    NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
    
    if (indexPath.secondLevelRow != NSNotFound)
    {
        if ([self.datasource respondsToSelector:@selector(tableView:cellForSecondLevelRowAtIndexPath:)])
        {
            return [self.datasource tableView:self cellForSecondLevelRowAtIndexPath:indexPath];
        }
    }
    
    return [self.datasource tableView:self cellForFirstLevelRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfRows = [self.datasource tableView:self numberOfFirstLevelRowsInSection:section];
    
    numberOfRows += [self.secondLevelTableRows count];
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    id<WDPRExpandableTableDecoratorDatasource> datasource = self.datasource;
    
    if ([datasource respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [datasource numberOfSectionsInTableView:self];
    }
    
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)idxPath
{
    BOOL canExpand = [self canExpandRowAtIndexPath:idxPath];
    BOOL isSecondLevelRow = [self isSecondLevelRowAtIndexPath:idxPath];
    
    [tableView deselectRowAtIndexPath:idxPath animated:YES];
    
    if (isSecondLevelRow || !canExpand)
    {
        id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
        
        if ([delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
            
            [delegate tableView:self didSelectRowAtIndexPath:indexPath];
        }
        
        return;
    }
    
    if (!isSecondLevelRow)
    {
        [self toggleExpandRowAtIndexPath:idxPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
    
    if ([self isSecondLevelRowAtIndexPath:idxPath])
    {
        if ([delegate respondsToSelector:@selector(tableView:heightForSecondLevelRowAtIndexPath:)])
        {
            return [delegate tableView:self heightForSecondLevelRowAtIndexPath:indexPath];
        }
    }
    
    if ([delegate respondsToSelector:@selector(tableView:heightForFirstLevelRowAtIndexPath:)])
    {
        return [delegate tableView:self heightForFirstLevelRowAtIndexPath:indexPath];
    }
    
    return self.tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
    
    if ([self isSecondLevelRowAtIndexPath:idxPath])
    {
        if ([delegate respondsToSelector:@selector(tableView:estimatedHeightForSecondLevelRowAtIndexPath:)])
        {
            return MAX([delegate tableView:self estimatedHeightForSecondLevelRowAtIndexPath:indexPath], kMinEstimatedCellHeight);
        }
        else if ([delegate respondsToSelector:@selector(tableView:heightForSecondLevelRowAtIndexPath:)])
        {
            return MAX([delegate tableView:self heightForSecondLevelRowAtIndexPath:indexPath], kMinEstimatedCellHeight);
        }
    }
    
    if ([delegate respondsToSelector:@selector(tableView:estimatedHeightForFirstLevelRowAtIndexPath:)])
    {
        return MAX([delegate tableView:self estimatedHeightForFirstLevelRowAtIndexPath:indexPath], kMinEstimatedCellHeight);
    }
    else if ([delegate respondsToSelector:@selector(tableView:heightForFirstLevelRowAtIndexPath:)])
    {
        return MAX([delegate tableView:self heightForFirstLevelRowAtIndexPath:indexPath], kMinEstimatedCellHeight);
    }
    
    return self.tableView.rowHeight > 0 ? self.tableView.rowHeight : kDefaultCellHeight;
}

#pragma mark - UIScrollVieDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tableViewDidScroll:)])
    {
        [delegate tableViewDidScroll:self];
    }
}

#pragma mark - WDPRExpandableTableStrategy Private

- (NSArray *)convertFirstLevelIndexPathsForTable:(NSArray *)indexPaths
{
    NSMutableArray *convertedIndexPaths = [NSMutableArray new];
    
    for (NSIndexPath *idxPath in indexPaths)
    {
        [convertedIndexPaths addObject:[self convertFirstLevelIndexPathToTable:idxPath]];
    }
    
    return [convertedIndexPaths copy];
}

- (NSIndexPath *)convertFirstLevelIndexPathToTable:(NSIndexPath *)idxPath
{
    NSUInteger firstLevelRow = idxPath.firstLevelRow != NSNotFound ? idxPath.firstLevelRow : idxPath.row;
    NSUInteger tableRow = [self computeTableRowForFirstLevelRow:firstLevelRow];
    
    return [NSIndexPath indexPathForRow:tableRow inSection:idxPath.section];;
}

- (BOOL)isSecondLevelRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.secondLevelTableRows containsIndex:indexPath.row];
}

- (BOOL)canExpandRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tableView:canExpandRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
        
        return [delegate tableView:self canExpandRowAtIndexPath:indexPath];
    }
    
    return YES;
}

- (NSUInteger)computeFirstLevelRowForTableRow:(NSUInteger)tableRow
{
    NSUInteger firstLevelRow = tableRow;
    
    firstLevelRow -= [self.secondLevelTableRows countOfIndexesInRange:NSMakeRange(0, tableRow + 1)];
    return MAX(firstLevelRow, 0);
}

- (NSUInteger)computeSecondLevelRowForTableRow:(NSUInteger)tableRow
{
    if (![self.secondLevelTableRows containsIndex:tableRow])
    {
        return NSNotFound;
    }
    
    NSUInteger firstLevelRow = [self computeFirstLevelRowForTableRow:tableRow];
    NSUInteger firstLevelTableRow = [self computeTableRowForFirstLevelRow:firstLevelRow];
    
    return tableRow - firstLevelTableRow - 1;
}

- (NSUInteger)computeTableRowForFirstLevelRow:(NSUInteger)firstLevelRow
{
    NSUInteger tableRow = firstLevelRow;
    
    for (NSUInteger row = 0; row <= tableRow; row++)
    {
        tableRow += [self.secondLevelTableRows containsIndex:row] ? 1 : 0;
    }
    
    return tableRow;
}

- (NSUInteger)numberOfSecondLevelRowsForFirstLevelRowAtIndexPath:(NSIndexPath *)indexpath
{
    if ([self isRowAtIndexPathExpanded:indexpath])
    {
        __block NSUInteger numberOfSecondLevelRows = 0;
        
        [self.secondLevelTableRows enumerateIndexesUsingBlock:^(NSUInteger secondLevelRow, BOOL *stop)
        {
            if ([self computeFirstLevelRowForTableRow:secondLevelRow] == indexpath.firstLevelRow)
            {
                numberOfSecondLevelRows++;
            }
        }];
        return numberOfSecondLevelRows;
    }
    
    return [self numberOfSecondLevelRowsInRowAtIndexPath:indexpath];

}

- (NSIndexPath *)addLevelRowsToIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.length > 2)
    {
        return indexPath;
    }
    
    NSUInteger indexes[indexPath.length];
    NSIndexPath *levelRowsIndexPath;
    
    // XXX: This is a workaround - The indexPath is actually an UIMutableIndexPath, a subclass of NSIndexPath.
    // However, when indexing, its behavior is not as expected as an NSIndexPath.
    // Hence the code of obtaining indexes and assigning them to a new variable.
    [indexPath getIndexes:indexes];
    levelRowsIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:indexPath.length];    
    levelRowsIndexPath = [levelRowsIndexPath indexPathByAddingIndex:[self computeFirstLevelRowForTableRow:indexPath.row]];
    
    if ([self.secondLevelTableRows containsIndex:indexPath.row])
    {
        levelRowsIndexPath = [levelRowsIndexPath indexPathByAddingIndex:[self computeSecondLevelRowForTableRow:indexPath.row]];
    }
    
    return levelRowsIndexPath;
}

- (void)collapseRowsAtFirstLevelIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *firstLevelIndexPath in indexPaths)
    {
        NSIndexPath *tableIndexPath = [self convertFirstLevelIndexPathToTable:firstLevelIndexPath];
        
        if ([self isRowAtIndexPathExpanded:tableIndexPath])
        {
            [self toggleExpandRowAtIndexPath:tableIndexPath];
        }
    }
}

- (void)toggleExpandRowAtIndexPath:(NSIndexPath *)idxPath
{
    NSMutableArray *secondLevelIndexPaths = [NSMutableArray new];
    NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
    NSUInteger numOfSecondLevelRows = [self numberOfSecondLevelRowsForFirstLevelRowAtIndexPath:indexPath];
    NSRange range = NSMakeRange(idxPath.row + 1, numOfSecondLevelRows);
    
    [[NSIndexSet indexSetWithIndexesInRange:range] enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop)
    {
         NSIndexPath *secondLevelIndexPath = [NSIndexPath indexPathForRow:row inSection:idxPath.section];
         
         [secondLevelIndexPaths addObject:secondLevelIndexPath];
    }];
    
    if ([self.secondLevelTableRows containsIndex:idxPath.row + 1] || [self.autoExpandedTableRows containsIndex:idxPath.row])
    {
        [self willCollapseRowAtIndexPath:idxPath];
        [self.tableView beginUpdates];
        
        if (range.length == 0)
        {
            [self.autoExpandedTableRows removeIndex:idxPath.row];
        }
        else
        {
            [self removeSecondLevelTableRowsInRange:range];
            [self.tableView deleteRowsAtIndexPaths:secondLevelIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self didCollapseRowAtIndexPath:idxPath];
        [self.tableView scrollToRowAtIndexPath:idxPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:YES];
    }
    else
    {
        [self willExpandRowAtIndexPath:idxPath];
        [self.tableView beginUpdates];
        
        if (range.length == 0)
        {
            [self.autoExpandedTableRows addIndex:idxPath.row];
        }
        else
        {
            [self insertSecondLevelTableRowsInRange:range];
            [self.tableView insertRowsAtIndexPaths:secondLevelIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self didExpandRowAtIndexPath:idxPath];
        
        if (self.scrollToShowLastAddedRow)
        {

            [self.tableView scrollToRowAtIndexPath:idxPath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
    }
}

- (void)insertSecondLevelTableRowsInRange:(NSRange)range
{
    NSMutableIndexSet *newIndexes = [NSMutableIndexSet new];
    
    [[self.secondLevelTableRows copy] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        if (range.location <= idx)
        {
            [newIndexes addIndex:idx + range.length];
        }
        else
        {
            [newIndexes addIndex:idx];
        }
    }];
    
    [newIndexes addIndexesInRange:range];
    self.secondLevelTableRows = newIndexes;
}

- (void)removeSecondLevelTableRowsInRange:(NSRange)range
{
    NSMutableIndexSet *newIndexes = [NSMutableIndexSet new];
    
    [[self.secondLevelTableRows copy] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        if (!NSLocationInRange(idx, range))
        {
            if (NSMaxRange(range) <= idx)
            {
                [newIndexes addIndex:idx - range.length];
            }
            else
            {
                [newIndexes addIndex:idx];
            }
        }
    }];
    self.secondLevelTableRows = newIndexes;
}

- (void)willExpandRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tableView:willExpandRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
        
        [delegate tableView:self willExpandRowAtIndexPath:indexPath];
    }
}

- (void)willCollapseRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tableView:willCollapseRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
        
        [delegate tableView:self willCollapseRowAtIndexPath:indexPath];
    }
}

- (void)didExpandRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tableView:didExpandRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
        
        [delegate tableView:self didExpandRowAtIndexPath:indexPath];
    }
    executeOnMainThread(^{ // Main thread is needed to ensure VoiceOver fires the notification
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:idxPath.row + 1 inSection:idxPath.section];
        UITableViewCell *focusCell = [self.tableView cellForRowAtIndexPath:nextPath];
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, focusCell);
    });
}

- (void)didCollapseRowAtIndexPath:(NSIndexPath *)idxPath
{
    id<WDPRExpandableTableDecoratorDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(tableView:didCollapseRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = [self addLevelRowsToIndexPath:idxPath];
        
        [delegate tableView:self didCollapseRowAtIndexPath:indexPath];
    }
    executeOnMainThread(^{ // Main thread is needed to ensure VoiceOver fires the notification
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, [self.tableView cellForRowAtIndexPath:idxPath]);
    });
}

- (NSUInteger)numberOfSecondLevelRowsInRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.datasource respondsToSelector:@selector(tableView:numberOfSecondLevelRowsInRowAtIndexPath:)])
    {
        return [self.datasource tableView:self numberOfSecondLevelRowsInRowAtIndexPath:indexPath];
    }
    return 0;
}

@end

@implementation NSIndexPath (WDPRExpandableTable)

- (NSUInteger)firstLevelRow
{
    return [self indexAtPosition:kFirstLevelRowPosition];
}

- (NSUInteger)secondLevelRow
{
    return [self indexAtPosition:kSecondLevelRowPosition];
}

@end
