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

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

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
            NSArray* dataArray = [self dealWithData:data];
            [weakSelf addChartWithDataArray:dataArray];
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

- (NSArray*)dealWithData:(NSArray*)dataArray
{
    NSMutableArray* result = [NSMutableArray new];
    for (NSString* s in dataArray) {
        NSNumber* yValue = [NSNumber numberWithFloat:[[s componentsSeparatedByString:@" "][1] floatValue]];
        [result addObject:yValue];
    }
    return result;
}

- (void)addChartWithDataArray:(NSArray*)dataArray
{
    //For Line Chart
    PNLineChart* lineChart
        = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH, SCREEN_HEIGHT - 70)];

    NSInteger max = ceilf([[dataArray valueForKeyPath:@"@max.self"] floatValue]);
    NSInteger min = floorf([[dataArray valueForKeyPath:@"@min.self"] floatValue]);

    lineChart.yFixedValueMax = max;
    lineChart.yFixedValueMin = min;
    lineChart.yLabelColor = [UIColor colorWithRed:0.22f green:0.57f blue:0.89f alpha:1.0f];
    lineChart.yLabelFormat = @"%1.02f";
    lineChart.yLabelNum = 10; //具体指的是 Y 轴有几个间隔

    PNLineChartData* data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = dataArray.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [dataArray[index] floatValue];
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
