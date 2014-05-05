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

@interface MGRMessagesViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MGRCoreData *coreData;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIView *keyboardAccessoryDummyView;
@property (weak, nonatomic) IBOutlet UITextField *dummyTextField;
@property (strong, nonatomic) UITextField *realTextField;
@property (strong, nonatomic) UIButton *realSendButton;
@property (nonatomic) BOOL lastMessageWasOfTypeSent;
@property (strong, nonatomic) UIView *realIAView;
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
    
    [self prepareAccessoryView];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInBackground) name:@"AppInBackground" object:nil];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Can't fetch");
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height-50, 50, 50) animated:NO];
}

- (void)appInBackground {
    NSError *saveError;
    [self.coreData.managedObjectContext save:&saveError];
    if (saveError) {
        NSLog(@"There was an error saving: %@", saveError.localizedDescription);
    }
}


- (void)sendMessage {
    NSLog(@"Sending");
    self.realSendButton.titleLabel.textColor = [UIColor blueColor];
    MGRMessage *message = [NSEntityDescription insertNewObjectForEntityForName:@"MGRMessage" inManagedObjectContext:self.coreData.managedObjectContext];
    message.message = self.realTextField.text;
    message.date = [NSDate date];

    
    if (self.lastMessageWasOfTypeSent) {
        message.type = @(MGRMessageTypeReceived);
        self.lastMessageWasOfTypeSent = NO;
    } else {
        message.type = @(MGRMessageTypeSent);
        self.lastMessageWasOfTypeSent = YES;
    }
    
    message.height = [self calculateLabelHeightForText:self.realTextField.text];
    [self.realTextField setText:@""];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSArray *newArray;
    if (newIndexPath) {
        newArray = [NSArray arrayWithObject:newIndexPath];
    }
    
    NSArray *oldArray;
    if (indexPath) {
        oldArray = [NSArray arrayWithObject:indexPath];
    }
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:oldArray withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"no.");
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self scrollTableToBottom:self.tableView animated:YES];

}

- (NSNumber *)calculateLabelHeightForText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 286, 19)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = text;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.f];
    [label sizeToFit];
    
    return @(label.frame.size.height + 36);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyboardAccessoryDummyView.hidden = YES;
    self.keyboardAccessoryDummyView.frame = CGRectMake(0, self.view.frame.size.height, self.keyboardAccessoryDummyView.frame.size.width, self.keyboardAccessoryDummyView.frame.size.height);
    [self.realTextField becomeFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *userInfoDict = [notification userInfo];
    CGRect rect = [userInfoDict[UIKeyboardFrameEndUserInfoKey] CGRectValue];


    NSInteger padding = 0;
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, rect.size.height+padding, 0)];
    }];
    
    [self scrollTableToBottom:self.tableView animated:YES];
}

- (void)keyboardDidHide {
    
    self.keyboardAccessoryDummyView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.keyboardAccessoryDummyView.frame = CGRectMake(0, self.view.frame.size.height - self.keyboardAccessoryDummyView.frame.size.height, self.keyboardAccessoryDummyView.frame.size.width, self.keyboardAccessoryDummyView.frame.size.height);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    }];
    
    
}

- (void)prepareAccessoryView {
    self.realIAView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.realIAView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.realIAView.layer.borderWidth = 0.5f;
    self.realIAView.backgroundColor = [UIColor lightTextColor];
    
    self.realTextField = [[UITextField alloc] initWithFrame:CGRectMake(7, 7, 250, 30)];
    self.realTextField.delegate = self;
    self.realTextField.enablesReturnKeyAutomatically = NO;
    self.realTextField.returnKeyType = UIReturnKeyDone;
    self.realTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.realIAView addSubview:self.realTextField];
    
    self.realSendButton = [[UIButton alloc] initWithFrame:CGRectMake(258, 8, 62, 30)];
    [self.realSendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.realSendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    self.realSendButton.titleLabel.textColor = [UIColor blueColor];
    [self.realSendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.realIAView addSubview:self.realSendButton];
    
    
    self.dummyTextField.inputAccessoryView = self.realIAView;
    
    
    self.keyboardAccessoryDummyView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.keyboardAccessoryDummyView.layer.borderWidth = 0.5f;
}



- (void)scrollTableToBottom:(UITableView *)tableView animated:(BOOL)animated {
    NSInteger numberOfRows = [tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.dummyTextField becomeFirstResponder];
    [self.dummyTextField resignFirstResponder];
    return YES;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *moc = self.coreData.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MGRMessage"];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Master"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

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
    return message.height.floatValue;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
