//
//  ISVerticalMenuView.h
//  ISVerticalMenuView
//
//  Created by Meiwin TSC on 23/1/14.
//  Copyright (c) 2014 The Stakeholder Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISVerticalMenuItem : NSObject
@property (nonatomic,strong) UIImage * image;
@property (nonatomic,strong) UIImage * highlightedImage;
+ (id)itemWithImage:(UIImage *)image;
+ (id)itemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;
@end

@class ISVerticalMenuView;
@protocol ISVerticalMenuViewDelegate
@optional
- (void)verticalMenuView:(ISVerticalMenuView *)verticalMenuView didSelectItemAtIndex:(NSInteger)index;
@end

@interface ISVerticalMenuView : UIView
@property (nonatomic,strong) NSArray * items; // array of UIImage
@property (nonatomic,weak) id<ISVerticalMenuViewDelegate> delegate;

@property (nonatomic,strong) UIColor * menuTintColor;
@property (nonatomic,strong) UIColor * menuHighlightedTintColor;

- (id)initWithItems:(NSArray *)items;
- (void)showFromRect:(CGRect)rect inView:(UIView *)inView animated:(BOOL)animated completion:(void(^)())completion;
- (void)hide:(BOOL)animated completion:(void(^)())completion;
@end
