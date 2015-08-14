//
//  SettingHolidayViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingHolidayViewController.h"
#import "SettingQAViewController.h"

@interface SettingHolidayViewController ()
{
    UIButton *weekendInButton1;
    UIButton *weekendOutButton1;
    UIButton *weekendInButton2;
    UIButton *weekendOutButton2;
}

@property (nonatomic, assign) BOOL firstWeekendIn;
@property (nonatomic, strong) NSArray *weekArray;

@end

@implementation SettingHolidayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *weekend = [Master valueForKey:MSTKeyHoliday];
        _weekArray = [weekend componentsSeparatedByString:@","];
        
        NSString *week = [Master valueForKey:MSTKeyWeekendIn];
        if ([_weekArray[0] isEqualToString:week]) {
            _firstWeekendIn = YES;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configDismissButton];
    [self configSubTitle:@"法定内/法定外休日設定"];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45.0, self.contentView.width, 25.0)];
    [categoryLabel setText:@"休日の種類を選択できます。"];
    [categoryLabel setTextColor:[UIColor whiteColor]];
    [categoryLabel setTextAlignment:NSTextAlignmentCenter];
    [categoryLabel setFont:[UIFont systemFontOfSize:18.0]];
    [categoryLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:categoryLabel];
    
    UIImage *cellImage1 = [UIImage imageNamed:@"weekend_cell_top"];
    UIImageView *cellBgImageView1 = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(cellImage1, (self.contentView.width - cellImage1.size.width) / 2, 92.0)];
    [cellBgImageView1 setImage:cellImage1];
    [cellBgImageView1 setUserInteractionEnabled:YES];
    [self.contentView addSubview:cellBgImageView1];
    
    UILabel *weekendLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0, 50.0, cellBgImageView1.height)];
    [weekendLabel1 setTextColor:[UIColor whiteColor]];
    [weekendLabel1 setFont:[UIFont systemFontOfSize:14.0]];
    [weekendLabel1 setBackgroundColor:[UIColor clearColor]];
    [cellBgImageView1 addSubview:weekendLabel1];
    
    UIImage *weekendInImage1 = [UIImage imageNamed:@"weekend_in_on"];
    weekendInButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [weekendInButton1 setFrame:CGRectOffsetFromImage(weekendInImage1, 90.0, (cellBgImageView1.height - weekendInImage1.size.height) / 2)];
    [weekendInButton1 setImage:weekendInImage1 forState:UIControlStateNormal];
    [weekendInButton1 addTarget:self action:@selector(weekendInButton1DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cellBgImageView1 addSubview:weekendInButton1];
    
    UIImage *weekendOutImage1 = [UIImage imageNamed:@"weekend_out_off"];
    weekendOutButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [weekendOutButton1 setFrame:CGRectOffsetFromImage(weekendOutImage1, 190.0, (cellBgImageView1.height - weekendOutImage1.size.height) / 2)];
    [weekendOutButton1 setImage:weekendOutImage1 forState:UIControlStateNormal];
    [weekendOutButton1 addTarget:self action:@selector(weekendOutButton1DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cellBgImageView1 addSubview:weekendOutButton1];
    
    UIImage *cellImage2 = [UIImage imageNamed:@"weekend_cell_bottom"];
    UIImageView *cellBgImageView2 = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(cellImage2, (self.contentView.width - cellImage2.size.width) / 2, cellBgImageView1.bottom)];
    [cellBgImageView2 setImage:cellImage2];
    [cellBgImageView2 setUserInteractionEnabled:YES];
    [self.contentView addSubview:cellBgImageView2];
    
    UILabel *weekendLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0, 50.0, cellBgImageView1.height)];
    [weekendLabel2 setTextColor:[UIColor whiteColor]];
    [weekendLabel2 setFont:[UIFont systemFontOfSize:14.0]];
    [weekendLabel2 setBackgroundColor:[UIColor clearColor]];
    [cellBgImageView2 addSubview:weekendLabel2];
    
    UIImage *weekendInImage2 = [UIImage imageNamed:@"weekend_in_off"];
    weekendInButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [weekendInButton2 setFrame:CGRectOffsetFromImage(weekendInImage2, 90.0, (cellBgImageView2.height - weekendInImage2.size.height) / 2)];
    [weekendInButton2 setImage:weekendInImage2 forState:UIControlStateNormal];
    [weekendInButton2 addTarget:self action:@selector(weekendInButton2DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cellBgImageView2 addSubview:weekendInButton2];
    
    UIImage *weekendOutImage2 = [UIImage imageNamed:@"weekend_out_on"];
    weekendOutButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [weekendOutButton2 setFrame:CGRectOffsetFromImage(weekendOutImage2, 190.0, (cellBgImageView2.height - weekendOutImage2.size.height) / 2)];
    [weekendOutButton2 setImage:weekendOutImage2 forState:UIControlStateNormal];
    [weekendOutButton2 addTarget:self action:@selector(weekendOutButton2DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cellBgImageView2 addSubview:weekendOutButton2];
    
    if (self.weekArray.count == 2) {
        NSString *week1 = [NSString stringWithFormat:@"%@曜日", [AppManager weekTextAtIndex:[self.weekArray[0] integerValue]]];
        NSString *week2 = [NSString stringWithFormat:@"%@曜日", [AppManager weekTextAtIndex:[self.weekArray[1] integerValue]]];
        [weekendLabel1 setText:week1];
        [weekendLabel2 setText:week2];
    }
    
    UILabel *whatLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 250.0, 200.0, 20.0)];
    [whatLabel setText:@"￼法定内/法定外休日って何？"];
    [whatLabel setTextColor:[UIColor whiteColor]];
    [whatLabel setFont:[UIFont systemFontOfSize:14.0]];
    [whatLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:whatLabel];
    
    UIImage *qaImage = [UIImage imageNamed:@"weekend_qa"];
    UIButton *qaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [qaButton setFrame:CGRectOffsetFromImage(qaImage, 203.0, 237.0)];
    [qaButton setImage:qaImage forState:UIControlStateNormal];
    [qaButton addTarget:self action:@selector(qaButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:qaButton];
    
    UIImage *saveImage = [UIImage imageNamed:@"save_change"];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectOffsetFromImage(saveImage, (self.view.width - saveImage.size.width) / 2.0, (self.view.height - 95.0))];
    [saveButton setImage:saveImage forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
    [self updateInOutButtonStatus:self.firstWeekendIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)qaButtonDidClicked:(UIButton *)button
{
    SettingQAViewController *settingQAViewController = [[SettingQAViewController alloc] init];
    [self.navigationController pushViewController:settingQAViewController animated:YES];
}

- (void)saveButtonDidClicked:(UIButton *)button
{
    if (self.firstWeekendIn) {
        if (self.weekArray.count == 2) {
            [Master saveValue:self.weekArray[0] forKey:MSTKeyWeekendIn];
            [Master saveValue:self.weekArray[1] forKey:MSTKeyWeekendOut];
            
            [[AppManager sharedInstance] setSettingNeedReload:YES];
        }
    } else {
        if (self.weekArray.count == 2) {
            [Master saveValue:self.weekArray[1] forKey:MSTKeyWeekendIn];
            [Master saveValue:self.weekArray[0] forKey:MSTKeyWeekendOut];
            
            [[AppManager sharedInstance] setSettingNeedReload:YES];
        }
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)updateInOutButtonStatus:(BOOL)firstWeekendInflag
{
    if (firstWeekendInflag) {
        [weekendInButton1 setImage:[UIImage imageNamed:@"weekend_in_on"] forState:UIControlStateNormal];
        [weekendOutButton1 setImage:[UIImage imageNamed:@"weekend_out_off"] forState:UIControlStateNormal];
        [weekendInButton2 setImage:[UIImage imageNamed:@"weekend_in_off"] forState:UIControlStateNormal];
        [weekendOutButton2 setImage:[UIImage imageNamed:@"weekend_out_on"] forState:UIControlStateNormal];
    } else {
        [weekendInButton1 setImage:[UIImage imageNamed:@"weekend_in_off"] forState:UIControlStateNormal];
        [weekendOutButton1 setImage:[UIImage imageNamed:@"weekend_out_on"] forState:UIControlStateNormal];
        [weekendInButton2 setImage:[UIImage imageNamed:@"weekend_in_on"] forState:UIControlStateNormal];
        [weekendOutButton2 setImage:[UIImage imageNamed:@"weekend_out_off"] forState:UIControlStateNormal];
    }
    
}

- (void)weekendInButton1DidClicked:(UIButton *)button
{
    if (!self.firstWeekendIn) {
        [self setFirstWeekendIn:YES];
        [self updateInOutButtonStatus:self.firstWeekendIn];
    }
}

- (void)weekendOutButton1DidClicked:(UIButton *)button
{
    if (self.firstWeekendIn) {
        [self setFirstWeekendIn:NO];
        [self updateInOutButtonStatus:self.firstWeekendIn];
    }
}

- (void)weekendInButton2DidClicked:(UIButton *)button
{
    if (self.firstWeekendIn) {
        [self setFirstWeekendIn:NO];
        [self updateInOutButtonStatus:self.firstWeekendIn];
    }
}

- (void)weekendOutButton2DidClicked:(UIButton *)button
{
    if (!self.firstWeekendIn) {
        [self setFirstWeekendIn:YES];
        [self updateInOutButtonStatus:self.firstWeekendIn];
    }
}

@end
