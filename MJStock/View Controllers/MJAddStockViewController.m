//
//  MJAddViewController.m
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import "MJAddStockViewController.h"
#import "MJStock.h"
#import "MJStockCell.h"
#import "MJFetcher.h"
#import "MBProgressHUD.h"

@interface MJAddStockViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) MJStock* stock;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;

- (IBAction)cancelBtnTapped;

@end

@implementation MJAddStockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //修改searchBar输入框的颜色
    for (UIView* subview in [[self.searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField* textField = (UITextField*)subview;
            [textField setBackgroundColor:[UIColor colorWithRed:0.16f green:0.16f blue:0.17f alpha:1.0f]];
            [textField setTextColor:[UIColor whiteColor]];
        }
    }

    // 设置 view 的背景颜色
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.20f green:0.17f blue:0.18f alpha:1.0f]];

    [self.searchBar becomeFirstResponder];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stock ? 1 : 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    MJStockCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MJStockCell" forIndexPath:indexPath];
    cell.stock = self.stock;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([self.delegate respondsToSelector:@selector(
                                              addStockViewController:
                                                       DidSeletStock:)]) {
        [self.delegate addStockViewController:self DidSeletStock:self.stock];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [searchBar resignFirstResponder];

    NSString* name = searchBar.text;
    if ([name length] > 0) {

        __weak __typeof(self) weakself = self;
        [[MJFetcher sharedFetcher] fetchStockWithID:name.lowercaseString
            success:^(MJFetcher* fetcher, id data) {
                weakself.stock = (MJStock*)data;
                [weakself.tableView reloadData];
            }
            failure:^(MJFetcher* fetcher, NSError* error) {
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"股票代码不正确，请输入正确的股票代码。";
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:2];
            }];
    }
}

#pragma mark : IBAction
/**
 *  取消添加股票
 */
- (IBAction)cancelBtnTapped
{
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
