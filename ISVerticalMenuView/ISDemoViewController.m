//
//  ISDemoViewController.m
//  ISVerticalMenuView
//
//  Created by Meiwin TSC on 23/1/14.
//  Copyright (c) 2014 The Stakeholder Company. All rights reserved.
//

#import "ISDemoViewController.h"
#import "ISVerticalMenuView.h"

#pragma mark - UIImage (ISOverlayColor)
@interface UIImage (ISOverlayColor)
- (UIImage *)IS_imageWithOverlayColor:(UIColor *)color;
@end

@implementation UIImage (ISOverlayColor)
- (UIImage *)IS_imageWithOverlayColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])
            imageScale = self.scale;
        UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(self.size);
    }
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outImage;
}
@end
#pragma mark - ISDemoViewController ()
@interface ISDemoViewController ()
{
    UIButton * _btn;
    ISVerticalMenuView * _menuView;
}
@end

#pragma mark - ISDemoViewController
@implementation ISDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
- (void)loadView
{
    [super loadView];
    
    CGSize s = self.view.bounds.size;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn sizeToFit];
    btn.center = (CGPoint) { s.width/2.f, s.height/2.f };
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [btn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn sizeToFit];
    btn.center = (CGPoint) { 20, 20 };
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [btn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn sizeToFit];
    btn.center = (CGPoint) { s.width-20, 20 };
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [btn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn sizeToFit];
    btn.center = (CGPoint) { 20, s.height-20 };
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [btn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn sizeToFit];
    btn.center = (CGPoint) { s.width-20, s.height-20 };
    btn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [btn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)showMenu:(UIButton *)btn
{
    if (_btn == btn)
    {
        [_menuView hide:YES completion:nil];
        _btn = nil;
        _menuView = nil;
    }
    else
    {
        [_menuView hide:YES completion:nil];
        
        ISVerticalMenuView * menuView = [[ISVerticalMenuView alloc] initWithItems:@[
                                         [ISVerticalMenuItem itemWithImage:[[UIImage imageNamed:@"01.png"] IS_imageWithOverlayColor:[UIColor darkGrayColor]] highlightedImage:[[UIImage imageNamed:@"01.png"] IS_imageWithOverlayColor:[UIColor blueColor]]],
                                          [ISVerticalMenuItem itemWithImage:[[UIImage imageNamed:@"02.png"] IS_imageWithOverlayColor:[UIColor darkGrayColor]] highlightedImage:[[UIImage imageNamed:@"02.png"] IS_imageWithOverlayColor:[UIColor blueColor]]],
                                         [ISVerticalMenuItem itemWithImage:[[UIImage imageNamed:@"03.png"] IS_imageWithOverlayColor:[UIColor darkGrayColor]] highlightedImage:[[UIImage imageNamed:@"03.png"] IS_imageWithOverlayColor:[UIColor blueColor]]],
                                         [ISVerticalMenuItem itemWithImage:[[UIImage imageNamed:@"04.png"] IS_imageWithOverlayColor:[UIColor darkGrayColor]] highlightedImage:[[UIImage imageNamed:@"04.png"] IS_imageWithOverlayColor:[UIColor blueColor]]],
                                         ]];
        [menuView showFromRect:btn.frame inView:btn.superview animated:YES completion:nil];
        
        _menuView = menuView;
        _btn = btn;
    }
}
@end
