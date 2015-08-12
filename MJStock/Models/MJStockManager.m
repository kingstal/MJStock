//
//  MJStockManager.m
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import "MJStockManager.h"

@implementation MJStockManager

+ (MJStockManager*)sharedManager
{
    static MJStockManager* _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    if ((self = [super init])) {
        [self loadStocks];
    }
    return self;
}

- (void)saveStocks
{
    NSMutableData* data = [[NSMutableData alloc] init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.stocks forKey:@"Stocks"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadStocks
{
    NSString* path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData* data = [[NSMutableData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.stocks = [unarchiver decodeObjectForKey:@"Stocks"];
        [unarchiver finishDecoding];
    }
    else {
        self.stocks = [[NSMutableArray alloc] initWithCapacity:5];
    }
}

- (NSString*)dataFilePath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:@"Stocks.data"];
}

@end
