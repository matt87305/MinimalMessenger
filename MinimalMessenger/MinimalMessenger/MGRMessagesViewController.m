//
//  MGRMessagesViewController.m
//  MinimalMessenger
//
//  Created by Matt Rosemeier on 5/3/14.
//  Copyright (c) 2014 Matt Rosemeier. All rights reserved.
//

#import "MGRMessagesViewController.h"
#import "MGRCoreData.h"
#import "MGRMessageCell.h"
#import "MGRMessage.h"

@interface MGRMessagesViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MGRCoreData *coreData;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIView *keyboardAccessoryView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation MGRMessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.coreData = [[MGRCoreData alloc] initWithStackStoreModelName:@"MinimalMessenger"];
    
    //self.textField.inputAccessoryView = self.keyboardAccessoryView;
    
    
/*if you uncomment this, after you manually insert records into the db, you get stuff*/
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MGRMessage"];
//    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
//    [request setSortDescriptors:@[sort]];
//    
//    NSArray *results = [self.coreData.managedObjectContext executeFetchRequest:request error:nil];
//    for (MGRMessage *message in results) {
//        NSLog(@"message: %@ %@ %@", message.message, message.date, message.type);
//    }
    
    
}

/*this is successfully functioning as a lazy accessor*/
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *moc = self.coreData.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MGRMessage"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"" cacheName:@"Master"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

/*this always returns nil*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

/*this, too, always returns nil*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = self.fetchedResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MGRMessageCell"];
    MGRMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    switch (message.type.integerValue) {
        case MGRMessageTypeReceived:
        {
            cell.receivedMessageLabel.hidden = NO;
            cell.receivedVerticalLineView.hidden = NO;
            cell.sentMessageLabel.hidden = YES;
            cell.sentVerticalLineView.hidden = YES;
            cell.receivedMessageLabel.text = message.message;
            break;
        }
            
        case MGRMessageTypeSent:
        {
            cell.receivedMessageLabel.hidden = YES;
            cell.receivedVerticalLineView.hidden = YES;
            cell.sentMessageLabel.hidden = NO;
            cell.sentVerticalLineView.hidden = NO;
            cell.sentMessageLabel.text = message.message;
            break;
        }
            
        default:
            break;
    }
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGRMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return message.height.integerValue;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
