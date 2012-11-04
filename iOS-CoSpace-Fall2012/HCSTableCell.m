//
//  HCSTableCell.m
//  iOS-CoSpace-Fall2012
//
//  Created by Chris LaCava on 11/2/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "HCSTableCell.h"



@implementation HCSTableCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

