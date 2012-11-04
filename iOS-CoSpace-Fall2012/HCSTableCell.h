//
//  HCSTableCell.h
//  iOS-CoSpace-Fall2012
//
//  Created by Chris LaCava on 11/2/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCSTableCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *state;
@property (nonatomic, retain) IBOutlet UILabel *created;
@property (nonatomic, retain) IBOutlet UILabel *username;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;



@end
