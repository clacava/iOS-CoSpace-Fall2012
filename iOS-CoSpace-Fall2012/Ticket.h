//
//  Ticket.h
//  iOS-CoSpace-Fall2012
//
//  Created by Chris LaCava on 11/12/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ticket : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * closed_at;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * title;

@end
