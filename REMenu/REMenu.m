//
// REMenu.m
// REMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REMenu.h"
#import "REMenuItem.h"
#import "REMenuItemView.h"


@interface REMenuItem ()

@property (assign, readwrite, nonatomic) REMenuItemView *itemView;

@end

@interface REMenu ()

@property (strong, readwrite, nonatomic) UIView *menuView;
@property (strong, readwrite, nonatomic) UIView *menuWrapperView;
@property (strong, readwrite, nonatomic) REMenuContainerView *containerView;
@property (strong, readwrite, nonatomic) UIButton *backgroundButton;
@property (assign, readwrite, nonatomic) BOOL isOpen;
@property (strong, readwrite, nonatomic) NSMutableArray *itemViews;
@property (weak, readwrite, nonatomic) UINavigationBar *navigationBar;
@property (strong, readwrite, nonatomic) UIToolbar *toolbar;

@end

@implementation REMenu

- (id)init
{
    if ((self = [super init])) {
        self.liveBlur = YES;
        self.liveBlurTintColor = [UIColor clearColor];
        self.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleLight;
        self.imageAlignment = REMenuImageAlignmentLeft;
        self.closeOnSelection = YES;
        self.itemHeight = 48.0;
        self.separatorHeight = 2.0;
        self.waitUntilAnimationIsComplete = YES;
        
        self.textOffset = CGSizeMake(0, 0);
        self.subtitleTextOffset = CGSizeMake(0, 0);
        self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
        self.subtitleFont = [UIFont systemFontOfSize:14.0];
        
//        self.backgroundColor = [UIColor colorWithRed:15/255.0 green:118/255.0 blue:223/255.0 alpha:.7];
        self.separatorColor = [UIColor colorWithPatternImage:self.separatorImage];
        self.textColor = [UIColor colorWithRed:0/255.0 green:128/255.0 blue:225/255.0 alpha:1];
//        self.textShadowColor = [UIColor blackColor];
//        self.textShadowOffset = CGSizeMake(0, -1.0);
        self.textAlignment = NSTextAlignmentCenter;
        
//        self.highlightedBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"selectedBackground"]];
//        self.highlightedSeparatorColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1.0];
        self.highlightedTextColor = [UIColor colorWithRed:40/255.0 green:140/255.0 blue:255/255.0 alpha:1];
//        self.highlightedTextShadowColor = [UIColor blackColor];
//        self.highlightedTextShadowOffset = CGSizeMake(0, -1.0);
        
        self.subtitleTextColor = [UIColor colorWithWhite:1.0 alpha:1.000];
//        self.subtitleTextShadowColor = [UIColor blackColor];
//        self.subtitleTextShadowOffset = CGSizeMake(0, -1.0);
        self.subtitleHighlightedTextColor = [UIColor colorWithRed:0.389 green:0.384 blue:0.379 alpha:1.000];
        self.subtitleHighlightedTextShadowColor = [UIColor blackColor];
        self.subtitleHighlightedTextShadowOffset = CGSizeMake(0, -1.0);
        self.subtitleTextAlignment = NSTextAlignmentCenter;
        
//        self.borderWidth = 1.0;
//        self.borderColor =  [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1.0];
        self.animationDuration = 0.3;
        self.bounce = YES;
        self.bounceAnimationDuration = 0.1;
        
        self.appearsBehindNavigationBar = YES;
    }
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    if ((self = [self init])) {
        self.items = items;
    }
    return self;
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view
{
    self.isOpen = YES;
    
    // Create views
    //
    self.containerView = ({
        REMenuContainerView *view = [[REMenuContainerView alloc] init];
        view.clipsToBounds = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if (self.backgroundView) {
            self.backgroundView.alpha = 0.75;
            [view addSubview:self.backgroundView];
        }
        view;
    });
    
    self.menuView = ({
        UIView *view = [[UIView alloc] init];
        if (!self.liveBlur || REUIKitIsFlatMode()) {
            view.backgroundColor = self.backgroundColor;
        }
        view.layer.cornerRadius = self.cornerRadius;
        view.layer.borderColor = self.borderColor.CGColor;
        view.layer.borderWidth = self.borderWidth;
        view.layer.masksToBounds = YES;
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view;
    });
    
    if (!REUIKitIsFlatMode()) {
        self.toolbar = ({
            UIToolbar *toolbar = [[UIToolbar alloc] init];
            [toolbar setAlpha:1];
            toolbar.barStyle = self.liveBlurBackgroundStyle;
            if ([toolbar respondsToSelector:@selector(setBarTintColor:)])
                [toolbar performSelector:@selector(setBarTintColor:) withObject:self.liveBlurTintColor];
            toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            toolbar;
        });
    }
    
    self.menuWrapperView = ({
        UIView *view = [[UIView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (!self.liveBlur || REUIKitIsFlatMode()) {
            view.layer.shadowColor = self.shadowColor.CGColor;
            view.layer.shadowOffset = self.shadowOffset;
            view.layer.shadowOpacity = self.shadowOpacity;
            view.layer.shadowRadius = self.shadowRadius;
            view.layer.shouldRasterize = YES;
            view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        }
        view;
    });
    
    self.backgroundButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        button.accessibilityLabel = NSLocalizedString(@"Menu background", @"Menu background");
        button.accessibilityHint = NSLocalizedString(@"Double tap to close", @"Double tap to close");
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    CGFloat navigationBarOffset = self.appearsBehindNavigationBar && self.navigationBar ? 64 : 0;
    
    // Append new item views to REMenuView
    //
    for (REMenuItem *item in self.items) {
        NSInteger index = [self.items indexOfObject:item];
        
        CGFloat itemHeight = self.itemHeight;
        if (index == self.items.count - 1)
            itemHeight += self.cornerRadius;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         index * self.itemHeight + index * self.separatorHeight + 40.0 + navigationBarOffset,
                                                                         rect.size.width,
                                                                         self.separatorHeight+50)];
        separatorView.backgroundColor = self.separatorColor;
//        separatorView.backgroundColor = [UIColor clearColor];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [self.menuView addSubview:separatorView];
        
        //live blur
//        UIView *myView = [[UIView alloc] initWithFrame:self.menuView.bounds];
//        myView.backgroundColor = [UIColor clearColor];
//        UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:myView.frame];
//        bgToolbar.barStyle = UIBarStyleDefault;
//        [myView.superview insertSubview:bgToolbar belowSubview:separatorView];
////        [self.menuView addSubview:myView];
//        [self.menuView addSubview:separatorView];
        
        REMenuItemView *itemView = [[REMenuItemView alloc] initWithFrame:CGRectMake(0,
                                                                                    index * self.itemHeight + (index + 1.0) * self.separatorHeight + 40.0 + navigationBarOffset,
                                                                                    rect.size.width,
                                                                                    itemHeight)
                                                                    menu:self
                                                             hasSubtitle:item.subtitle.length > 0];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        itemView.item = item;
        item.itemView = itemView;
        itemView.separatorView = separatorView;
        itemView.autoresizesSubviews = YES;
        if (item.customView) {
            item.customView.frame = itemView.bounds;
            [itemView addSubview:item.customView];
        }
        [self.menuView addSubview:itemView];
    }
    
    // Set up frames
    //
    self.menuWrapperView.frame = CGRectMake(0, -self.combinedHeight - navigationBarOffset, rect.size.width, self.combinedHeight + navigationBarOffset);
    self.menuView.frame = self.menuWrapperView.bounds;
    if (!REUIKitIsFlatMode() && self.liveBlur) {
        self.toolbar.frame = self.menuWrapperView.bounds;
    }
    self.containerView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    self.backgroundButton.frame = self.containerView.bounds;
    
    // Add subviews
    //
    if (!REUIKitIsFlatMode() && self.liveBlur) {
        [self.menuWrapperView addSubview:self.toolbar];
    }
    [self.menuWrapperView addSubview:self.menuView];
    [self.containerView addSubview:self.backgroundButton];
    [self.containerView addSubview:self.menuWrapperView];
    [view addSubview:self.containerView];
    
    // Animate appearance
    //
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.backgroundView.alpha = 1.0;
        CGRect frame = self.menuView.frame;
        frame.origin.y = -40.0 - self.separatorHeight;
        self.menuWrapperView.frame = frame;
    } completion:nil];
}

- (void)showInView:(UIView *)view
{
    [self showFromRect:view.bounds inView:view];
}

- (void)showFromNavigationController:(UINavigationController *)navigationController
{
    self.navigationBar = navigationController.navigationBar;
    [self showFromRect:CGRectMake(0, 0, navigationController.navigationBar.frame.size.width, navigationController.view.frame.size.height) inView:navigationController.view];
    self.containerView.appearsBehindNavigationBar = self.appearsBehindNavigationBar;
    self.containerView.navigationBar = navigationController.navigationBar;
    if (self.appearsBehindNavigationBar) {
        [navigationController.view bringSubviewToFront:navigationController.navigationBar];
    }
}

- (void)closeWithCompletion:(void (^)(void))completion
{
    CGFloat navigationBarOffset = self.appearsBehindNavigationBar && self.navigationBar ? 64 : 0;
    
    void (^closeMenu)(void) = ^{
        [UIView animateWithDuration:self.animationDuration animations:^{
            CGRect frame = self.menuView.frame;
            frame.origin.y = - self.combinedHeight - navigationBarOffset;
            self.menuWrapperView.frame = frame;
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.menuView removeFromSuperview];
            [self.menuWrapperView removeFromSuperview];
            [self.backgroundButton removeFromSuperview];
            [self.backgroundView removeFromSuperview];
            [self.containerView removeFromSuperview];
            self.isOpen = NO;
            if (completion)
                completion();
            
            if (self.closeCompletionHandler)
                self.closeCompletionHandler();
        }];
        
    };
    
    if (self.bounce) {
        [UIView animateWithDuration:self.bounceAnimationDuration animations:^{
            CGRect frame = self.menuView.frame;
            frame.origin.y = -20.0;
            self.menuWrapperView.frame = frame;
        } completion:^(BOOL finished) {
            closeMenu();
        }];
    } else {
        closeMenu();
    }
}

- (void)close
{
    [self closeWithCompletion:nil];
}

- (CGFloat)combinedHeight
{
    return self.items.count * self.itemHeight + self.items.count  * self.separatorHeight + 40.0 + self.cornerRadius;
}

- (void)setNeedsLayout
{
    [UIView animateWithDuration:0.35 animations:^{
        [self.containerView layoutSubviews];
    }];
}

#pragma mark -
#pragma mark Setting style

- (UIImage *)separatorImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1.0));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1.0, 1.0));
//    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor);
//    CGContextFillRect(context, CGRectMake(0, 3.0, 1.0, 2.0));
    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:outputImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
}

@end
