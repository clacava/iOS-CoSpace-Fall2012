//
//  HCSViewController.h
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface HCSViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>

//@property (nonatomic, copy,   readwrite) NSString * filePath;
//@property (nonatomic, strong, readwrite) NSOutputStream * fileStream;


@property (nonatomic, retain, readwrite) NSMutableData * dataContainer;
@property (nonatomic, strong, readwrite) NSURLConnection *  connection;
@property (nonatomic, strong, readwrite) NSArray *responseItemsArray;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
