//
//  MGRMessageCell.h
//  MinimalMessenger
//
//  Created by Matt Rosemeier on 5/3/14.
//  Copyright (c) 2014 Matt Rosemeier. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MGRMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *receivedVerticalLineView;
@property (weak, nonatomic) IBOutlet UIView *sentVerticalLineView;
@property (weak, nonatomic) IBOutlet UILabel *receivedMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentMessageLabel;
@end
