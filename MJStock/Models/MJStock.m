//
//  MJStock.m
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import "MJStock.h"

@implementation MJStock

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if ((self = [super init])) {
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.price forKey:@"price"];
}
@end
