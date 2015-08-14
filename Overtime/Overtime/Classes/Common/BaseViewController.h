//
//  BaseViewController.h
//  ExileTribeMile
//
//  Created by Xu Shawn on 11/18/13.
//  Copyright (c) 2013 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIView *contentView;

- (void)configHeaderTitle:(NSString *)title;
- (void)configHeaderTitle:(NSString *)title separatorLine:(BOOL)separatorLine;
- (void)configSubTitle:(NSString *)subTitle;
- (void)configSilerHeader;
- (void)configBackButton;
- (void)configDismissButton;
- (void)configCancelButton;
- (void)configCloseButton;
- (void)configImage:(NSString *)imageName;
- (void)configImage:(NSString *)imageName offsetX:(CGFloat)x offsetY:(CGFloat)y;
- (void)configHeaderImage:(NSString *)headerName;
- (void)configHeaderImage:(NSString *)headerName andBgImage:(NSString *)bgName;

- (void)baseBackButtonDidClicked:(UIButton *)button;
- (void)baseDismissButtonDidClicked:(UIButton *)button;

@end
