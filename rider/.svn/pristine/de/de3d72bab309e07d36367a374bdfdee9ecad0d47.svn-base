//
//  alertLabel.m
//  kakong
//
//  Created by yinxun on 14-9-4.
//
//

#import "alertLabel.h"

@implementation alertLabel


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:16];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6.0;
        //self.layer.borderWidth = 1.0;
        //self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.alpha = 0;
        
    }
    return self;
}

- (void)alertLabelShowTitle:(NSString *)str view:(UIView *)view
{
    
    CGFloat labW = str.length * 20;
    self.text = str;
    self.frame = CGRectMake(0, 0, labW, 50);
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height * 0.75);
    
    [view.window addSubview:self];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:3.0 options:0 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];

}

- (void)alertLabelShowTitle:(NSString *)str height:(CGFloat)height
{
    
    CGFloat labW = str.length * 20;
    self.text = str;
    
    self.frame = CGRectMake(0, 0, labW, 50);
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, height);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.5 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
    
}




@end
