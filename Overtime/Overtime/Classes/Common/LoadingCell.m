//
//  LoadingCell.m
//  Omiai
//
//  Created by Xu Shawn on 8/3/12.
//
//

#import "LoadingCell.h"

@interface LoadingCell ()

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end

@implementation LoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        _activityIndicator.center = CGPointMake(self.frame.size.width-40, self.frame.size.height / 2);
        [self addSubview:_activityIndicator];
        
        [self.textLabel setTextAlignment:UITextAlignmentCenter];
        [self.textLabel setFont:[UIFont systemFontOfSize:18.0]];
        [self.textLabel setText:@"Load More..."];
    }
    return self;
}

- (void)dealloc
{
    [_activityIndicator release];
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(40.0, 0, 240.0, self.frame.size.height);
}

- (void)startAnimation
{
    [self.activityIndicator startAnimating];
    [self.textLabel setText:@"Loading..."];
}

- (void)stopAnimation
{
    [self.activityIndicator stopAnimating];
    [self.textLabel setText:@"Load More..."];
}

@end
