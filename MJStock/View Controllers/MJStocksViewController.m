//
//  MJStocksViewController.m
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import "MJStocksViewController.h"
#import "MJStockCell.h"
#import "MJFetcher.h"
#import "MJStock.h"
#import "MJStockManager.h"
#import "MJAddStockViewController.h"
#import "MJChartViewController.h"

@interface MJStocksViewController () <MJAddStockViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray* stocks;

@end

@implementation MJStocksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 清除多余的行
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    // 设置 view 的背景颜色
    [self.view setBackgroundColor:[UIColor colorWithRed:0.20f green:0.17f blue:0.18f alpha:1.0f]];

    // 添加定时器用于刷新获取实时数据，添加到NSRunLoopCommonModes是为了防止滑动 tableView 的时候 timer 失效
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

/**
 *  懒加载
 *
 */
- (NSMutableArray*)stocks
{
    if (!_stocks) {
        _stocks = [MJStockManager sharedManager].stocks;
    }
    return _stocks;
}

/**
 *  刷新数据，有股票的时候才开始刷新
 */
- (void)refresh
{
    //没有股票
    if ([self.stocks count] <= 0) {
        return;
    }

    NSDateComponents* currentDateComponents = [self getCurrentDateComponents];

    // 不是周一~周五
    if (![self weekIsBetweenMondayAndFridayWithDateComponets:currentDateComponents]) {
        return;
    }

    /**
     *  上下午的开闭市时间
     */
    NSDate* AMStart = [self getDateWithHour:9 minute:30 dateComponents:currentDateComponents];
    NSDate* AMEnd = [self getDateWithHour:11 minute:30 dateComponents:currentDateComponents];
    NSDate* PMStart = [self getDateWithHour:13 minute:00 dateComponents:currentDateComponents];
    NSDate* PMEnd = [self getDateWithHour:15 minute:00 dateComponents:currentDateComponents];
    NSDate* currentDate = [NSDate date];

    // 不在开市时间段
    if (![self date:currentDate isBetweenDate:AMStart andDate:AMEnd] && ![self date:currentDate isBetweenDate:PMStart andDate:PMEnd]) {
        return;
    }

    NSString* url = @"";
    for (MJStock* stock in self.stocks) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@,", stock.ID]];
    }

    __weak __typeof(self) weakSelf = self;
    [[MJFetcher sharedFetcher] fetchPriceWithName:url
        success:^(MJFetcher* fetcher, id data) {
            NSArray* prices = (NSArray*)data;
            for (int i = 0; i < [prices count]; i++) {
                ((MJStock*)weakSelf.stocks[i]).price = prices[i];
            }
            [weakSelf.tableView reloadData];
        }
        failure:^(MJFetcher* fetcher, NSError* error) {
            NSLog(@"%@", error);
        }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stocks.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    MJStockCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MJStockCell" forIndexPath:indexPath];
    cell.stock = self.stocks[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.stocks removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MJAddStockViewControllerDelegate

/**
 *  添加股票之后的回调
 *
 *  @param controller MJAddStockViewController
 *  @param stock      添加的股票
 */
- (void)addStockViewController:(MJAddStockViewController*)controller DidSeletStock:(MJStock*)stock
{
    NSString* ID = stock.ID;
    for (MJStock* s in self.stocks) {
        if ([s.ID isEqualToString:ID]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }

    [self.stocks addObject:stock];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.tableView reloadData];
                             }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    /**
     *  设置MJAddStockViewController的代理
     */
    if ([segue.identifier isEqualToString:@"addStock"]) {
        MJAddStockViewController* controller = segue.destinationViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"trend"]) {
        MJChartViewController* controller = segue.destinationViewController;
        controller.stock = self.stocks[[self.tableView indexPathForSelectedRow].row];
    }
}

#pragma mark - local

/**
 *  获得当前时间的年、月、日、时、分、秒和 weekday
 *
 */
- (NSDateComponents*)getCurrentDateComponents
{
    NSDate* currentDate = [NSDate date];
    NSCalendar* currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents* currentComps = [[NSDateComponents alloc] init];

    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];

    return currentComps;
}

/**
 *  根据传入dateComponents的设置为某个时间点
 *
 *  @param hour   时
 *  @param minute 分
 *  @param dateComponents 
 *
 */
- (NSDate*)getDateWithHour:(NSInteger)hour minute:(NSInteger)minute dateComponents:(NSDateComponents*)dateComponents
{
    NSDateComponents* resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[dateComponents year]];
    [resultComps setMonth:[dateComponents month]];
    [resultComps setDay:[dateComponents day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];

    NSCalendar* resultCalendar = [NSCalendar currentCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}

/**
 *  判断日期是否在两个日期之间
 *
 *  @param date      要判断的日期
 *  @param beginDate 开始日期
 *  @param endDate   结束日期
 *
 */
- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;

    if ([date compare:endDate] == NSOrderedDescending)
        return NO;

    return YES;
}

/**
 *  根据dateCompnents判断是否在周一到周五之间
 *
 */
- (BOOL)weekIsBetweenMondayAndFridayWithDateComponets:(NSDateComponents*)dateCompnents
{
    NSInteger weekDay = dateCompnents.weekday;
    if (weekDay > 1 && weekDay < 7) {
        return YES;
    }
    return NO;
}

@end
