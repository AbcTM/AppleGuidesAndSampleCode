//
//  ViewController.m
//  MultiSelectTableView
//
//  Created by tlc on 2018/4/2.
//  Copyright © 2018年 tlc. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;

// 模型数组
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 允许tableview在编辑是可以多选
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    // 产生数据源
    self.dataArray = [NSMutableArray array];
    NSString *itemFormatString = NSLocalizedString(@"Item %d", @"Format string for item");
    for (unsigned int itemNumber = 1; itemNumber <= 12; itemNumber++) {
        NSString *itemName = [NSString stringWithFormat:itemFormatString, itemNumber];
        [self.dataArray addObject:itemName];
    }
    
    [self updateButtonsToMatchTableState];
}



#pragma mark - Updating button state


/**
 根据tableView更新状态栏按钮
 */
- (void)updateButtonsToMatchTableState {
    // 当tableview处于编辑状态
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        [self updateDeleteButtonTitle];
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    }else{
        self.navigationItem.leftBarButtonItem = self.addButton;
        if (self.dataArray.count > 0) { // 根据当前数据源的数量决定编辑按钮是否可用
            self.editButton.enabled = YES;
        }else{
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)updateDeleteButtonTitle {
    // 获取当前选中的rows
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    // 是否处于全选
    BOOL allItemsAreSelected = selectedRows.count == self.dataArray.count;
    // 是否处于一个没有选中的状态
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    // 当满足上述条件时删除按钮显示【全选】文字
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else // 否则显示 『删除选中的数量』
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
    
}

#pragma mark - Action methods

- (IBAction)editAction:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}


- (IBAction)deleteAction:(id)sender
{
    // Open a dialog with just an OK button.
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:actionTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertVC addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    
    [alertVC addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            // Delete the objects from our data model.
            [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            
            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            // Delete everything, delete the objects from our data model.
            [self.dataArray removeAllObjects];
            
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }]];
    
    [self presentViewController:alertVC animated:true completion:nil];
}

- (IBAction)addAction:(id)sender
{
    // Tell the tableView we're going to add (or remove) items.
    [self.tableView beginUpdates];
    
    // Add an item to the array.
    [self.dataArray addObject:@"New Item"];
    
    // Tell the tableView about the item that was added.
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Tell the tableView we have finished adding or removing items.
    [self.tableView endUpdates];
    
    // Scroll the tableView so the new item is visible
    [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    // Update the buttons if we need to.
    [self updateButtonsToMatchTableState];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

@end
