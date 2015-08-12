//
//  MJChartViewController.m
//
//
//  Created by WangMinjun on 15/8/11.
//
//

#import "MJChartViewController.h"
#import "PNChart.h"
#import "MJFetcher.h"
#import "MBProgressHUD.h"

@interface MJChartViewController () <MBProgressHUDDelegate>

@end

@implementation MJChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@ 价格走势", self.stock.name];

    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Loading";

    // myProgressTask uses the HUD instance to update progress
    [HUD showWhileExecuting:@selector(addTrendChart) onTarget:self withObject:nil animated:YES];
}

- (void)addTrendChart
{
    __weak __typeof(self) weakSelf = self;
    [[MJFetcher sharedFetcher] fetchStockTrendDataWithID:self.stock.ID
        success:^(MJFetcher* fetcher, id data) {
            [weakSelf addChartWithDataArray:data];
        }
        failure:^(MJFetcher* fetcher, NSError* error) {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"出现问题，返回重试。";
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
        }];
}

- (void)addChartWithDataArray:(NSArray*)dataArray
{
    //For Line Chart
    PNLineChart* lineChart
        = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 135.0, SCREEN_WIDTH, SCREEN_WIDTH * 2 / 3)];

    PNLineChartData* data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = dataArray.count;
    data01.getData = ^(NSUInteger index) {
        NSString* data = dataArray[index];
        CGFloat yValue = [[data componentsSeparatedByString:@" "][1] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    lineChart.chartData = @[ data01 ];
    [lineChart strokeChart];

    [self.view addSubview:lineChart];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD*)hud
{
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}

@end
