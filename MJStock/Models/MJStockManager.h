//
//  MJStockManager.h
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import <Foundation/Foundation.h>

/**
 *  数据管理类，用于整个应用程序过程中的数据管理
 */
@interface MJStockManager : NSObject

@property (nonatomic, strong) NSMutableArray* stocks;

+ (MJStockManager*)sharedManager;

- (void)saveStocks;

@end
