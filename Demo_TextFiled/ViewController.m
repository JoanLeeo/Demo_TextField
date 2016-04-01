//
//  ViewController.m
//  Demo_TextFiled
//
//  Created by PC-LiuChunhui on 16/3/30.
//  Copyright © 2016年 PC-LiuChunhui. All rights reserved.
//

#import "ViewController.h"
#define kMaxLength 20
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *demoTextField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.demoTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    self.demoTextField.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self isInputRuleNotBlank:string] || [string isEqualToString:@""]) {//当输入符合规则和退格键时允许改变输入框
        return YES;
    } else {
        return NO;
    }
}
- (void)textFieldChanged:(UITextField *)textField {
    
    
    NSString *toBeString = textField.text;
    
    if (![self isInputRuleAndBlank:toBeString]) {
        textField.text = [self disable_emoji:toBeString];
        return;
    }
   
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
     NSLog(@"%@",lang);
    if([lang isEqualToString:@"zh-Hans"]) { //简体中文输入,第三方输入法（搜狗）所有模式下都会显示“zh-Hans”
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            NSString *getStr = [self getSubString:toBeString];
            if(getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
    } else{
         NSString *getStr = [self getSubString:toBeString];
        if(getStr && getStr.length > 0) {
            textField.text= getStr;
        }
    }
}
/**
 * 字母、数字、中文正则判断（不包括空格）
 */
- (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
/**
 * 字母、数字、中文正则判断（包括空格）（在系统输入法中文输入时会出现拼音之间有空格，需要忽略，当按return键时会自动用字母替换，按空格输入响应汉字）
 */
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
/**
 *  获得 kMaxLength长度的字符
 */
-(NSString *)getSubString:(NSString*)string
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [string dataUsingEncoding:encoding];
    NSInteger length = [data length];
    if (length > kMaxLength) {
        NSData *data1 = [data subdataWithRange:NSMakeRange(0, kMaxLength)];
        NSString *content = [[NSString alloc] initWithData:data1 encoding:encoding];//注意：当截取kMaxLength长度字符时把中文字符截断返回的content会是nil
        if (!content || content.length == 0) {
            data1 = [data subdataWithRange:NSMakeRange(0, kMaxLength - 1)];
            content =  [[NSString alloc] initWithData:data1 encoding:encoding];
        }
        return content;
    }
    return nil;
}
- (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
