//
//  HCSViewController.m
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "HCSViewController.h"
#import "HCSTableCell.h"
#import "HCSAppDelegate.h"
#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"
#define AppDelegate (HCSAppDelegate *)[[UIApplication sharedApplication] delegate]



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
            [self startReceive];
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
   
 }

- (void)viewDidUnload
{
     // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:[AppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"closed_at" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDelegate managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

//reachability
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
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );// if return here, this is recoverable - would maek the app crash
    
    
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
    
    NSLog(@"Array count: %d",self.responseItemsArray.count);
    
    if (!self.responseItemsArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        // NSManagedObjectContext *context =  self.managedObjectContext;
        
        NSLog(@"Context: %@", [AppDelegate managedObjectContext]);
        
        for(NSDictionary *item in self.responseItemsArray) {
         
            Ticket * newTicket = [NSEntityDescription insertNewObjectForEntityForName:@"Ticket"
                                 inManagedObjectContext:[AppDelegate managedObjectContext]];
            
             NSLog(@"Item: %@", item);
            
            newTicket.state = [item objectForKey:@"state"];
            newTicket.title = [item objectForKey:@"title"];
            newTicket.closed_at = [item objectForKey:@"closed_at"];
            newTicket.login = [item valueForKeyPath:@"user.login"];
            newTicket.avatar = [item valueForKeyPath:@"user.avatar_url"];
        
           //No Worky
          // NSData *userAvatar = [NSData dataWithContentsOfURL:[NSURL URLWithString:[item valueForKeyPath:@"user.avatar_url"]]];
          // [newTicket setValue:userAvatar forKey:@"avatar"];
            
         //   NSLog(@"Ticket: %@", newTicket);
                        
        }
        
        [AppDelegate saveContext];
    }
    
    [self.tableView reloadData];
    
   /*
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error%@",error);
        abort();
    }*/


}

//UITable Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.responseItemsArray.count;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  
    
    //Old JSON based table cell
    HCSTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if (cell == nil) {
               
       
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"HCSTableCell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell = (HCSTableCell *)temporaryController.view;
        
      
        
        Ticket *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
         cell.username.text = object.login;
         cell.state.text = object.state;
         cell.created.text = object.closed_at;
         cell.title.text = object.title;
        
        //if you put this on a seperate thread, lag would disipate, perform selector
       
        UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:                                                                             object.avatar]]];
        cell.avatar.image = avatar;
    }
    
    return cell;
}


//CORE DATA




@end
