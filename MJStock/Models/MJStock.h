//
//  MJStock.h
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import <Foundation/Foundation.h>

@interface MJStock : NSObject <NSCoding>

@property (nonatomic, copy) NSString* ID;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* price;

@end
