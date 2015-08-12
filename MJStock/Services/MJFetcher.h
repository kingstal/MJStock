//
//  MJFetcher.h
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import <Foundation/Foundation.h>
@class MJFetcher;

typedef void (^MJFetcherErrorBlock)(MJFetcher* fetcher, NSError* error);
typedef void (^MJFetcherSuccessBlock)(MJFetcher* fetcher, id data);

@interface MJFetcher : NSObject

/**
 *  单例
 */
+ (MJFetcher*)sharedFetcher;

/**
 *  根据公司列表获取数据
 *
 *  @param name         公司列表
 *  @param successBlock 成功之后的回调
 *  @param errorBlock   失败之后的回调
 */
- (void)fetchPriceWithName:(NSString*)name success:(MJFetcherSuccessBlock)successBlock failure:(MJFetcherErrorBlock)errorBlock;

/**
 *  根据股票编号查询股票
 *
 *  @param ID           股票编号
 *  @param successBlock 成功之后的回调
 *  @param errorBlock   失败之后的回调
 */
- (void)fetchStockWithID:(NSString*)ID success:(MJFetcherSuccessBlock)successBlock failure:(MJFetcherErrorBlock)errorBlock;

/**
 *  获取股票的走势数据
 *
 *  @param ID           股票编号
 *  @param successBlock 成功之后的回调
 *  @param errorBlock   失败之后的回调
 */
- (void)fetchStockTrendDataWithID:(NSString*)ID success:(MJFetcherSuccessBlock)successBlock failure:(MJFetcherErrorBlock)errorBlock;
@end
