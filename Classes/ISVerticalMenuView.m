//
//  ISVerticalMenuView.m
//  ISVerticalMenuView
//
//  Created by Meiwin TSC on 23/1/14.
//  Copyright (c) 2014 The Stakeholder Company. All rights reserved.
//

#import "ISVerticalMenuView.h"
#import <QuartzCore/QuartzCore.h>

#define mRgba(_r,_g,_b,_a)  [UIColor colorWithRed:(_r/255.f) green:(_r/255.f) blue:(_b/255.f) alpha:_a]
#define mRgb(_r,_g,_b)      mRgba(_r,_g,_b,1.f)

#define kArrowTipWidth      5.f
#define kMenuDimension      44.f

typedef enum {
    ISVerticalMenuViewArrowDirectionLeft,
    ISVerticalMenuViewArrowDirectionRight
} ISVerticalMenuViewArrowDirection;

#pragma mark - ISVerticalMenuItem
@implementation ISVerticalMenuItem
+ (id)itemWithImage:(UIImage *)image
{
    return [self itemWithImage:image highlightedImage:image];
}
+ (id)itemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    ISVerticalMenuItem * item = [[ISVerticalMenuItem alloc] init];
    item.image = image;
    item.highlightedImage = highlightedImage;
    return item;
}
@end

#pragma mark - ISVerticalMenuView ()
@interface ISVerticalMenuView ()
{
    CGRect _fromRect;
    NSArray * _buttons;
    
    struct {
        unsigned int didSelectItemAtIndex: 1;
    } _delegateFlags;
    
    CAShapeLayer * _maskLayer;
}
@property (nonatomic) ISVerticalMenuViewArrowDirection arrowDirection;
- (CGPoint)rectCenter:(CGRect)rect;
- (void)layoutSelfOnSuperviewForSize:(CGSize)fitSize;
- (void)setupButtonViews;
- (void)alignButtons:(NSArray *)buttons left:(CGFloat)left;
- (CGFloat)buttonLeftPosition;
- (void)updateMaskLayer;
@end

#pragma mark - ISVerticalMenuView (Delegation)
@interface ISVerticalMenuView (Delegation)
- (void)didSelectItemAtIndex:(NSInteger)index;
@end

#pragma mark - ISVerticalMenuView
@implementation ISVerticalMenuView
- (id)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = mRgb(0xef, 0xef, 0xf2);
        
        self.items = items;
        self.clipsToBounds = YES;
        
        _maskLayer = [CAShapeLayer layer];
        self.layer.mask = _maskLayer;
    }
    return self;
}
- (void)setDelegate:(id<ISVerticalMenuViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateFlags.didSelectItemAtIndex = _delegate && [(id)_delegate respondsToSelector:@selector(verticalMenuView:didSelectItemAtIndex:)];
}
- (void)setItems:(NSArray *)items
{
    _items = items;
    [self setupButtonViews];
}
- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = kArrowTipWidth + kMenuDimension;
    CGFloat height = _items.count * kMenuDimension;
    return (CGSize) { width, height };
}
#pragma mark Privates
- (CGFloat)buttonLeftPosition
{
    return _arrowDirection == ISVerticalMenuViewArrowDirectionLeft ? kArrowTipWidth : 0.f;
}
- (void)alignButtons:(NSArray *)buttons left:(CGFloat)left
{
    CGFloat cy = 0;
    for (UIButton * btn in buttons)
    {
        btn.frame = CGRectMake( left, cy, kMenuDimension, kMenuDimension );
        cy += kMenuDimension;
    }
}
- (void)setupButtonViews
{
    NSMutableArray * buttons = [NSMutableArray array];
    NSInteger i = 0;
    for (ISVerticalMenuItem * item in _items)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.contentMode = UIViewContentModeCenter;
        [button setImage:item.image forState:UIControlStateNormal];
        if (item.highlightedImage)
        {
            button.tag = i;
            [button setImage:item.highlightedImage forState:UIControlStateHighlighted];
            [button setImage:item.highlightedImage forState:UIControlStateSelected];
        }
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [buttons addObject:button];
        
        i++;
    }
    CGFloat left = [self buttonLeftPosition];
    [self alignButtons:buttons left:left];
    _buttons = buttons;
}
- (CGPoint)rectCenter:(CGRect)rect
{
    return (CGPoint) { rect.origin.x + floorf(rect.size.width/2.f), rect.origin.y + floorf(rect.size.height/2.f) };
}
- (void)layoutSelfOnSuperviewForSize:(CGSize)fitSize
{
    // the size needed to fits
    CGSize superSize = CGSizeZero;
    if (self.superview) superSize = self.superview.bounds.size;
    
    // calcualte self frame and arrow direction
    CGPoint fromCenter = [self rectCenter:_fromRect];
    CGRect selfFrame = (CGRect) { 0, floorf(fromCenter.y - (fitSize.height/2.f)), fitSize.width, fitSize.height };
    ISVerticalMenuViewArrowDirection arrowDirection = ISVerticalMenuViewArrowDirectionLeft;
    if (!CGSizeEqualToSize(CGSizeZero, superSize))
    {
        CGFloat leftX = fromCenter.x + _fromRect.size.width/2.f + 10.f;
        CGFloat rightX = fromCenter.x - _fromRect.size.width/2.f - 10.f - kArrowTipWidth - kMenuDimension;
        
        BOOL fitLeft = (leftX + kMenuDimension + kArrowTipWidth) <= superSize.width;
        BOOL fitRight = (leftX) > 0.f;
        
        arrowDirection = (fitLeft || !fitRight) ? ISVerticalMenuViewArrowDirectionLeft : ISVerticalMenuViewArrowDirectionRight;
        
        if (arrowDirection == ISVerticalMenuViewArrowDirectionLeft)
        {
            selfFrame.origin.x = leftX;
        }
        else
        {
            selfFrame.origin.x = rightX;
        }
    }
    _arrowDirection = arrowDirection;
    if (selfFrame.origin.y < 5) selfFrame.origin.y = 5;
    else if ((selfFrame.origin.y + selfFrame.size.height) > (superSize.height - 5)) selfFrame.origin.y = superSize.height-5-selfFrame.size.height;
    self.frame = selfFrame;
}
- (void)updateMaskLayer
{
    _maskLayer.frame = self.bounds;
    
    CGSize selfSize = self.bounds.size;
    CGFloat amultiplier = _arrowDirection == ISVerticalMenuViewArrowDirectionLeft ? 1 : -1;
    CGFloat cx = _arrowDirection == ISVerticalMenuViewArrowDirectionLeft ? kArrowTipWidth : selfSize.width-kArrowTipWidth;
    
    CGPoint rectCenter = [self rectCenter:_fromRect];
    CGFloat sy = (rectCenter.y - selfSize.height/2.f);
    CGFloat ay = self.frame.origin.y-sy;

    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, cx, 0);
    cx += (amultiplier * kMenuDimension);
    CGPathAddLineToPoint(pathRef, nil, cx, 0);
    CGPathAddLineToPoint(pathRef, nil, cx, selfSize.height);
    cx -= (amultiplier * kMenuDimension);
    CGPathAddLineToPoint(pathRef, nil, cx, selfSize.height);
    CGPathAddLineToPoint(pathRef, nil, cx, ceilf(selfSize.height/2.f + kArrowTipWidth) - ay);
    cx -= (amultiplier * kArrowTipWidth);
    CGPathAddLineToPoint(pathRef, nil, cx, selfSize.height/2.f - ay);
    cx += (amultiplier * kArrowTipWidth);
    CGPathAddLineToPoint(pathRef, nil, cx, floorf(selfSize.height/2.f - kArrowTipWidth) - ay);
    CGPathAddLineToPoint(pathRef, nil, cx, 0);
    _maskLayer.path = pathRef;
    CGPathRelease(pathRef);
}
#pragma mark Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = [self buttonLeftPosition];
    [self alignButtons:_buttons left:x];
}
#pragma mark Actions
- (void)buttonTapped:(UIButton *)button
{
    [self didSelectItemAtIndex:button.tag];
}
#pragma mark Show
- (void)showFromRect:(CGRect)rect
              inView:(UIView *)inView
            animated:(BOOL)animated
          completion:(void (^)())completion
{
    if (inView)
    {
        _fromRect = rect;
        [inView addSubview:self];
        if (animated)
        {
            CGSize selfSize = self.bounds.size;
            if (CGSizeEqualToSize(selfSize, CGSizeZero))
            {
                self.bounds = (CGRect) { 0, 0, kArrowTipWidth + kMenuDimension, 0.f };
                selfSize = self.bounds.size;
            }
            [self layoutSelfOnSuperviewForSize:selfSize];
            
            [UIView animateWithDuration:.3 animations:^{
                [self layoutSelfOnSuperviewForSize:[self sizeThatFits:CGSizeZero]];
                [self updateMaskLayer];
            } completion:^(BOOL finished) {
                [self setNeedsLayout];
                if (completion) completion();
            }];
        }
        else
        {
            [self layoutSelfOnSuperviewForSize:[self sizeThatFits:CGSizeZero]];
            [self setNeedsLayout];
            if (completion) completion();
        }
    }
}
- (void)hide:(BOOL)animated
  completion:(void (^)())completion
{
    if (animated)
    {
        [UIView animateWithDuration:.3 animations:^{
            CGSize toSize = (CGSize) { kArrowTipWidth + kMenuDimension, 0.f };
            [self layoutSelfOnSuperviewForSize:toSize];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (completion) completion();
        }];
    }
    else
    {
        [self removeFromSuperview];
        if (completion) completion();
    }
}

#pragma mark Delegation
- (void)didSelectItemAtIndex:(NSInteger)index
{
    if (_delegateFlags.didSelectItemAtIndex) [_delegate verticalMenuView:self didSelectItemAtIndex:index];
}
@end
