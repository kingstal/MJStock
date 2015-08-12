//
//  MJStockCell.m
//
//
//  Created by WangMinjun on 15/8/10.
//
//

#import "MJStockCell.h"
#import "MJStock.h"

@interface MJStockCell ()
@property (weak, nonatomic) IBOutlet UILabel* IDLabel;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* priceLabel;

@end

@implementation MJStockCell

- (void)setStock:(MJStock*)stock
{
    _stock = stock;
    self.IDLabel.text = stock.ID;
    self.nameLabel.text = stock.name;
    self.priceLabel.text = stock.price;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
