//
//  MJFetcher.m
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import "MJFetcher.h"
#import "AFNetworking.h"
#import "MJStock.h"

@implementation MJFetcher

+ (MJFetcher*)sharedFetcher
{
    static MJFetcher* _sharedFetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFetcher = [[self alloc] init];
    });
    return _sharedFetcher;
}

/**
 *  实例化一个AFHTTPRequestOperationManager，用于解析 json
 */
- (AFHTTPRequestOperationManager*)JSONRequestOperationManager
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // fixed server text/html issue
    NSSet* acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    [manager.responseSerializer setAcceptableContentTypes:acceptableContentTypes];
    return manager;
}

- (void)fetchPriceWithName:(NSString*)name success:(MJFetcherSuccessBlock)successBlock failure:(MJFetcherErrorBlock)errorBlock
{
    [[self JSONRequestOperationManager] GET:[NSString stringWithFormat:@"http://mjdedouban.sinaapp.com/stockPrice?name=%@", name]
        parameters:nil
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            successBlock(self, responseObject);
        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            errorBlock(self, error);
        }];
}

- (void)fetchStockWithID:(NSString*)ID success:(MJFetcherSuccessBlock)successBlock failure:(MJFetcherErrorBlock)errorBlock
{
    [[self JSONRequestOperationManager] GET:[NSString stringWithFormat:@"http://mjdedouban.sinaapp.com/stock?name=%@", ID]
        parameters:nil
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dict = (NSDictionary*)responseObject;
            MJStock* stock = [MJStock new];
            stock.ID = dict[@"ID"];
            stock.name = dict[@"name"];
            stock.price = dict[@"price"];
            successBlock(self, stock);
        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            errorBlock(self, error);
        }];
}

- (void)fetchStockTrendDataWithID:(NSString*)ID success:(MJFetcherSuccessBlock)successBlock failure:(MJFetcherErrorBlock)errorBlock
{
    [[self JSONRequestOperationManager] GET:[NSString stringWithFormat:@"http://ifzq.gtimg.cn/appstock/app/minute/query?code=%@", ID]
        parameters:nil
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            NSDictionary* dict = (NSDictionary*)responseObject;
            NSArray* result = dict[@"data"][ID][@"data"][@"data"];
            successBlock(self, result);
        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            errorBlock(self, error);
        }];
}
@end
