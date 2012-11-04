//
//  HCSViewController.m
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "HCSViewController.h"
#import "HCSTableCell.h"
#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface HCSViewController ()

@end

@implementation HCSViewController

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog( @"Block Says Reachable");
         });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog( @"Block Says Unreachable");
            [self stopReceiveWithStatus:@"Lost Connctivity"];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Connectivity"
                                                              message:@"There is no internet connection. Airplane mode may be activated."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];

         });
    };
    
    [reach startNotifier];
    [self startReceive];
    
   
 }

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


/***************************************************************************************************
 Note to Carl: There is still a bug here where the "unreachable" state with erroneously be tripped when resuming network connection.  I'll continue to try and track that down but I wanted to get this checked in for review.
 **************************************************************************************************/
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
       NSLog(@"Notification Says Reachable");
        [self stopReceiveWithStatus:nil];
        [self startReceive];
    }
    else
    {
    NSLog(@"Notification Says Unreachable");
     [self stopReceiveWithStatus:@"Lost Connctivity"];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Connectivity"
                                                          message:@"There is no internet connection. Airplane mode may be activated."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        
    }
}



- (void)startReceive
{
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/repos/mojombo/jekyll/issues?state=closed"];
      
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"request:%@", request);
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@"connection:%@", self.connection);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    NSLog(@"error! %@", error);
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    
    NSLog(@"Stop Recevied: %@", statusString);
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    
    [self receiveDidStopWithStatus:statusString];
 
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx and that the Content-Type is acceptable.  If these checks
// fail, we give up on the transfer.
{
    NSLog(@"Response Started.");
    

    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    
     httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    
    if ((httpResponse.statusCode / 100) != 2 && (httpResponse.statusCode / 100) != 3) {
        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
         contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            [self stopReceiveWithStatus:@"No Content-Type!"];
        } else if(![contentTypeHeader isEqual:@"application/json"] ){
            NSLog(@"Response not JSON. MIMEType is: %@", contentTypeHeader.lowercaseString);
        } else {
            NSLog(@"Response OK. MIMEType is: %@", contentTypeHeader.lowercaseString);
            
        }
    }
}

/***************************************************************************************************
 Note to Carl:  I could not get the fileStream in Apple's example to wrok here but I was able to stick the response in an NSData Object.  Is this a legit way of doing this?
**************************************************************************************************/ 
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.
{

    if(nil == self.dataContainer){
        self.dataContainer = [[NSMutableData alloc]initWithData:data];
    }else{
        [self.dataContainer appendData:data];
    }
}


- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    NSLog(@"Receive Stopped with Status: %@", statusString);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [self stopReceiveWithStatus:@"Received"];
    
    NSError *e = nil;
    self.responseItemsArray = [NSJSONSerialization JSONObjectWithData:self.dataContainer options:NSJSONReadingMutableContainers error:&e];
    
    if (!self.responseItemsArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        for(NSDictionary *item in self.responseItemsArray) {
            //   NSLog(@"Item: %@", item);
        }
    }
    
    [self.tableView reloadData];

}

//UITable Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.responseItemsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  HCSTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    
    if (cell == nil) {
        
        NSDictionary *responseItem = [[NSDictionary alloc] initWithDictionary: [self.responseItemsArray objectAtIndex:indexPath.row]];
        
         //NSLog(@"Response Item: %@", responseItem);
       
        NSDictionary *user = [responseItem objectForKey:@"user"];
        
        
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"HCSTableCell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell = (HCSTableCell *)temporaryController.view;
        
       UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"avatar_url"]]]];
        
        cell.avatar.image = avatar;
        cell.username.text = [user objectForKey:@"login"];
        cell.title.text = [responseItem objectForKey:@"title"];
        cell.state.text = [responseItem objectForKey:@"state"];
        cell.created.text = [responseItem objectForKey:@"closed_at"];
        

      }
    
    return cell;
}




@end
