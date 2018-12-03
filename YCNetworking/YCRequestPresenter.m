//
//  YCRequestPresenter.m
//  YCRequest
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCRequestPresenter.h"
#import <UIKit/UIKit.h>

@interface YCRequestPresenter()
@property (nonatomic,strong)UITextView *logView;
@property (nonatomic,strong)UIButton *requestBtn;
@end

@implementation YCRequestPresenter


- (instancetype)initWithView:(id)view {
    if (self = [super initWithView:view]) {
        [_view addSubview:self.logView];
        [_view addSubview:self.requestBtn];
    }
    return self;
}

- (void)requestAction:(UIButton *)sender {
    if (self.handleAction){
        self.handleAction();
    }
}

- (void)scrollToBottom
{
    [self.logView scrollRectToVisible:CGRectMake(0, self.logView.contentSize.height - 15, self.logView.contentSize.width, 10) animated:YES];
}

- (void)logError:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];

    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];

    [[self.logView textStorage] appendAttributedString:as];
    [self scrollToBottom];
}

- (void)logInfo:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[UIColor purpleColor] forKey:NSForegroundColorAttributeName];

    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];

    [[self.logView textStorage] appendAttributedString:as];
    [self scrollToBottom];
}

- (void)logMessage:(NSString *)msg
{
    NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [attributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];

    NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];

    [[self.logView textStorage] appendAttributedString:as];

    [self scrollToBottom];
}

- (UITextView *)logView {
    if (!_logView){
       UITextView *logView = [[UITextView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width ,  [UIScreen mainScreen].bounds.size.height - 120)];
        logView.editable = false;
        logView.backgroundColor = [UIColor grayColor];
        _logView = logView;
    }
    return _logView;
}

- (UIButton *)requestBtn {
    if (!_requestBtn){
        UIButton *requestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [requestBtn setTitle:@"请求数据" forState:UIControlStateNormal];
        requestBtn.backgroundColor = [UIColor redColor];
        requestBtn.frame = CGRectMake((([UIScreen mainScreen].bounds.size.width -100 )/ 2), 50, 100, 30);
        [requestBtn addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
        _requestBtn = requestBtn;
    }
    return _requestBtn;
}

@end
