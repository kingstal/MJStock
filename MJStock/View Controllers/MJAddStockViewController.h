//
//  MJAddViewController.h
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import <UIKit/UIKit.h>

@class MJAddStockViewController;
@class MJStock;

@protocol MJAddStockViewControllerDelegate <NSObject>

- (void)addStockViewController:(MJAddStockViewController*)controller DidSeletStock:(MJStock*)stock;

@end

@interface MJAddStockViewController : UIViewController

@property (nonatomic, weak) id<MJAddStockViewControllerDelegate> delegate;

@end
