//
//  UserLoginViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/11/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "UserLoginViewController.h"

@interface UserLoginViewController ()

@end

@implementation UserLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self != nil)
    {
        self.title = @"登陆";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
    }
    return self;
}

-(void) loadView{
    
    // applicationFrame是整个可见区域，不包括状态栏
    UIView* view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    //设置view的颜色
    view.backgroundColor = [UIColor greenColor];
    
    //添加一个标签
    UILabel* label = [[UILabel alloc] init];
    label.text=@"Hello World!";
    
    UIButton *button = [[UIButton alloc] init];
    
    
    //居中
    label.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    button.center = CGPointMake(50,200);
    //添加到view
    [view addSubview:label];
    [view addSubview:button];
    //设置self.view = view这样视图控制器就可以管理这个视图了，如果实现了loadView那么就必须设置self.view
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    

}

@end
