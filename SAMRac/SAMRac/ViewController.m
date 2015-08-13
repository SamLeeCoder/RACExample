//
//  ViewController.m
//  SAMRac
//
//  Created by SamLee on 15/7/29.
//  Copyright (c) 2015年 mf. All rights reserved.
//

#import "ViewController.h"
/**
 *  定义
 *
 *  @param paramInteger
 *
 *  @return
 */
typedef NSString* (^IntToStringConverter)(NSUInteger paramInteger);
@interface ViewController ()
//@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UITextField *tfdText;
@property (strong, nonatomic) IBOutlet UILabel *lblText;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RACSignal *nameSignal = self.nameTF.rac_textSignal;
    RACSignal *pwdSignal = self.pwdTF.rac_textSignal;
    RAC(self.loginBtn, enabled) = [RACSignal combineLatest:@[nameSignal,pwdSignal] reduce:^id(NSString *name,NSString *pwd){
        return @( ![name isEqualToString:@""]&&![pwd isEqualToString:@""]);
    }];
//    [self.usernameTextField.rac_textSignal subscribeNext:^(id x) {
//        NSLog(@"%@", x);
//    }];
    NSArray *array = @[ @1, @2, @3 ];
    NSLog(@"%@",[[[array rac_sequence] map:^id (id value){
        return [value stringValue];
    }] foldLeftWithStart:@"" reduce:^(id accumulator, id value){
        return [accumulator stringByAppendingString:value];
    }]);
    
    RACSignal *signal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        NSLog(@"triggered");
        [subscriber sendNext:@"foobar"];
        [subscriber sendCompleted];
        return nil;
    }];
    [signal subscribeCompleted:^{
        NSLog(@"subscription");
    }];
    [signal replay];
    [signal subscribeCompleted:^{
        NSLog(@"subscription----");
    }];
    [self test];
    
    
}
- (IBAction)clickButton:(id)sender {
    __block int count = 10;
    
    
    /**
     *  @brief  计时器：每2秒减一，将lblText打印上相应的数字。
     *                 在完成时，打印上“完成”
     */
    RACSignal *intervalSignal = [[RACSignal interval:2 onScheduler:[RACScheduler mainThreadScheduler]] startWith:[NSDate date]];
    intervalSignal = [intervalSignal take:count];
    intervalSignal = [intervalSignal map:^id(id value) {
        return @(count--);
    }];
    
    //  intervalSignal = [intervalSignal replay];
    
    [intervalSignal subscribeNext:^(id x) {
        [self.lblText setText:[NSString stringWithFormat:@"%@", x]];
    }];
    
    [intervalSignal subscribeCompleted:^{
        [self.lblText setText:@"完成"];
    }];
}

/**
 *  2.用Block作为参数的函数
 */
- (NSString *)convertIntToString:(NSUInteger)paramInteger usingBlockObject:(IntToStringConverter)paramBlockObject{
    
    return paramBlockObject(paramInteger);
}
/**
 *  3.内联调用
 */
- (void) doTheConversion{
    NSString *result =[self convertIntToString:123
                              usingBlockObject:^(NSUInteger paramInteger) {
                                  NSString *result = [NSString stringWithFormat:@"%lu",(unsigned long)paramInteger];
                                  return result;
                              }];
    
    NSLog(@"result = %@", result);
    
}


// 定义Block
void (^simpleBlock)(NSString *) = ^(NSString *theParam){
    NSLog(@"the string=%@",theParam);
    
};

// 调用Block
- (void) callSimpleBlock{
    simpleBlock(@"O'Reilly");
}
/**
 *  嵌套调用
 */

// 定义内层Block
NSString *(^trimString)(NSString *) = ^(NSString *inputString){
    NSString *result = [inputString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    return result;
};
// 定义外层Block
NSString *(^trimWithOtherBlock)(NSString *) = ^(NSString *inputString){
    return trimString(inputString);
};

// 调用方法
- (void) callTrimBlock{
    NSString *trimmedString = trimWithOtherBlock(@" O'Reilly ");
    NSLog(@"Trimmed string = %@", trimmedString);
}

- (void)test
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        double delayInSeconds = 2.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [subscriber sendNext:@"A"];
//        });
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"B"];
        [subscriber sendNext:@"Another B"];
        [subscriber sendNext:@"Another-- B"];

        [subscriber sendCompleted];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(doA:withB:) withSignals:signalA, signalB, nil];
}
- (void)doA:(NSString *)A withB:(NSString *)B
{
    NSLog(@"A:%@ and B:%@", A, B);
}

@end
