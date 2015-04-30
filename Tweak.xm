#include <substrate.h>
#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCall.h>
#import <UIKit/UIKit.h>

NSString *InComingNum = @"";
int status = 0;

typedef struct __CTCall *CTCallRef;
extern "C" {
void CTCallDisconnect(CTCallRef call);
NSString *CTCallCopyAddress(void *, CTCallRef call);
CFNotificationCenterRef CTTelephonyCenterGetDefault();
void CTTelephonyCenterAddObserver(CFNotificationCenterRef center,
                                         const void *observer,
                                         CFNotificationCallback callBack,
                                         CFStringRef name,
                                         const void *object,
                                         CFNotificationSuspensionBehavior suspensionBehavior);
}

static void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if ([(__bridge NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"]) {
        NSLog(@"运行到handleCallStatusChanged这里了吗。0%@",userInfo );
        InComingNum = @"";
        CTCallRef call = (CTCallRef)[userInfo objectForKey:@"kCTCall"];
        status = [[(__bridge NSDictionary *)userInfo objectForKey:@"kCTCallStatus"] intValue];
        if (status == 4) {
            NSLog(@"运行到handleCallStatusChanged这里了吗。1%@",InComingNum );
            InComingNum = CTCallCopyAddress(NULL, call);
            InComingNum = [InComingNum stringByReplacingOccurrencesOfString:@"-" withString:@""];//去除号码中的 -  。
        }
    }
}

// %hook TUCallCenter

// - (void)handleCallStatusChanged:(id)arg1 userInfo:(id)arg2
// {
//     InComingNum = @"";
//     NSLog(@"运行到handleCallStatusChanged这里了吗。0%@",arg2 );
//     NSDictionary *info = (NSDictionary *)arg2;
//     CTCallRef call = (CTCallRef)[info objectForKey:@"kCTCall"];
//     status = [[info objectForKey:@"kCTCallStatus"] stringValue];
//     //这里获取来电的号码。
//     if ([status isEqualToString:@"4"])
//     {
//         NSLog(@"运行到handleCallStatusChanged这里了吗。1%@",InComingNum );
//         InComingNum = CTCallCopyAddress(NULL, call);
//         InComingNum = [InComingNum stringByReplacingOccurrencesOfString:@"-" withString:@""];//去除号码中的 -  。
//     }
    
//     %orig;
// }

// %end

NSString *location = @"无法定位";
NSString *NumRecognize = @"无法识别";
UILabel *InComingNumRecognize = nil;
UILabel *InCominglabel = nil;

%hook PHCallParticipantsViewController
- (void)viewDidLoad{
    %orig;
    if (![InComingNum isEqualToString:@""]){
    UIView *_awayView = MSHookIvar<UIView *>(self, "_participantsView");
            float w = 200;
        float h = 100;
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cx.shouji.360.cn/phonearea.php?number=%@",InComingNum]];
        NSMutableURLRequest* request = [NSMutableURLRequest new];
        [request setURL:url];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:10];
        [request setHTTPShouldHandleCookies:FALSE];
        [request setValue:@"appliction/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        __block NSString* strRet = @"";
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   if (error) {
                                       //NSLog(@"Httperror:%@%d", error.localizedDescription,error.code);
                                   }else{
           
                                       strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                        NSError *error;
                                        //加载一个NSURL对象
                                        // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.weather.com.cn/data/101180601.html"]];
                                        // //将请求的url数据放到NSData对象中
                                        // NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                                        NSLog(@"测试数据1--》%@", strRet );
                                        strRet = [strRet stringByReplacingOccurrencesOfString :@"__" withString:@""];
                                        strRet = [strRet stringByReplacingOccurrencesOfString :@"_ =" withString:@":"];
                                        NSLog(@"测试数据2--》%@", strRet );
                                        NSData* jsonData = [strRet dataUsingEncoding:NSUTF8StringEncoding]; 
                                        NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                                        NSDictionary *weatherInfo = [weatherDic objectForKey:@"data"];
                                        NSString *GetLocationErrorCode = [weatherDic objectForKey:@"code"];
                                        NSString *location = @"无法获取归属地信息%@";

                                        // if ([GetLocationErrorCode isEqualToString:@"0"])
                                        // {
                                            location = [NSString stringWithFormat:@"%@%@%@",[weatherInfo objectForKey:@"province"],[weatherInfo objectForKey:@"city"],[weatherInfo objectForKey:@"sp"]];
                                            NSLog(@"weatherInfo字典里面的内容为--》%@", weatherDic );

                                           //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           NSLog(@"360==========================#################来电号码为：%@，归属地为：%@",InComingNum,location);
                                           //NSLog(@"HttpResponseCode:%d", responseCode);
                                           //NSLog(@"HttpResponseBody %@",responseString);
                                        // }

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            InCominglabel = [[UILabel alloc] initWithFrame:CGRectMake((_awayView.frame.size.width - w)/2,100,w,h)];
                                            InCominglabel.text = location;
                                            InCominglabel.textAlignment = NSTextAlignmentCenter;
                                            InCominglabel.backgroundColor = [UIColor clearColor];
                                            InCominglabel.textColor = [UIColor redColor];
                                            [_awayView addSubview:InCominglabel];
                                        });

                                   }
                               }];}
    // if (![InComingNum isEqualToString:@""] && [status isEqualToString:@"4"])
    // {
        
    //     UIView *_awayView = MSHookIvar<UIView *>(self, "_participantsView");
    //     float w = 200;
    //     float h = 100;

    //     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cx.shouji.360.cn/phonearea.php?number=%@",InComingNum]];
    //     NSMutableURLRequest* request = [NSMutableURLRequest new];
    //     [request setURL:url];
    //     [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    //     [request setHTTPMethod:@"GET"];
    //     [request setTimeoutInterval:10];
    //     [request setHTTPShouldHandleCookies:FALSE];
    //     [request setValue:@"appliction/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //     __block NSString* strRet = @"";
    //     NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    //     [NSURLConnection sendAsynchronousRequest:request
    //                                        queue:queue
    //                            completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
    //                                if (error) {
    //                                    //NSLog(@"Httperror:%@%d", error.localizedDescription,error.code);
    //                                }else{
           
    //                                    strRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //                                     NSError *error;
    //                                     //加载一个NSURL对象
    //                                     // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.weather.com.cn/data/101180601.html"]];
    //                                     // //将请求的url数据放到NSData对象中
    //                                     // NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //                                     //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    //                                     NSLog(@"测试数据1--》%@", strRet );
    //                                     strRet = [strRet stringByReplacingOccurrencesOfString :@"__" withString:@""];
    //                                     strRet = [strRet stringByReplacingOccurrencesOfString :@"_ =" withString:@":"];
    //                                     NSLog(@"测试数据2--》%@", strRet );
    //                                     NSData* jsonData = [strRet dataUsingEncoding:NSUTF8StringEncoding]; 
    //                                     NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    //                                     NSDictionary *weatherInfo = [weatherDic objectForKey:@"data"];
    //                                     NSString *GetLocationErrorCode = [weatherDic objectForKey:@"code"];
    //                                     NSString *location = @"无法获取归属地信息%@";

    //                                     // if ([GetLocationErrorCode isEqualToString:@"0"])
    //                                     // {
    //                                         location = [NSString stringWithFormat:@"%@%@%@",[weatherInfo objectForKey:@"province"],[weatherInfo objectForKey:@"city"],[weatherInfo objectForKey:@"sp"]];
    //                                         NSLog(@"weatherInfo字典里面的内容为--》%@", weatherDic );

    //                                        //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //                                        NSLog(@"360==========================#################来电号码为：%@，归属地为：%@",InComingNum,location);
    //                                        //NSLog(@"HttpResponseCode:%d", responseCode);
    //                                        //NSLog(@"HttpResponseBody %@",responseString);
    //                                     // }

    //                                     dispatch_async(dispatch_get_main_queue(), ^{
    //                                         InCominglabel = [[UILabel alloc] initWithFrame:CGRectMake((_awayView.frame.size.width - w)/2,100,w,h)];
    //                                         InCominglabel.text = location;
    //                                         InCominglabel.textAlignment = NSTextAlignmentCenter;
    //                                         InCominglabel.backgroundColor = [UIColor clearColor];
    //                                         InCominglabel.textColor = [UIColor redColor];
    //                                         [_awayView addSubview:InCominglabel];
    //                                     });

    //                                }
    //                            }];



    //     NSURL* url1 = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.haoma.sogou.com/vrapi/query_number.php?number=%@&type=json&callback=show",InComingNum]];
    //     NSMutableURLRequest* request1 = [NSMutableURLRequest new];
    //     [request1 setURL:url1];
    //     [request1 setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    //     [request1 setHTTPMethod:@"GET"];
    //     [request1 setTimeoutInterval:10];
    //     [request1 setHTTPShouldHandleCookies:FALSE];
    //     [request1 setValue:@"appliction/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //     __block NSString* strRet1 = @"";
    //     NSOperationQueue *queue1 = [[NSOperationQueue alloc]init];
    //     [NSURLConnection sendAsynchronousRequest:request1
    //                                        queue:queue1
    //                            completionHandler:^(NSURLResponse *response1, NSData *data1, NSError *error1){
    //                                if (error1) {
    //                                    //NSLog(@"Httperror:%@%d", error.localizedDescription,error.code);
    //                                }else{
           
    //                                    strRet1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    //                                     NSError *error;
    //                                     //加载一个NSURL对象
    //                                     // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.weather.com.cn/data/101180601.html"]];
    //                                     // //将请求的url数据放到NSData对象中
    //                                     // NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //                                     //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    //                                     NSLog(@"###测试数据1--》%@", strRet1 );
    //                                     strRet1 = [strRet1 stringByReplacingOccurrencesOfString :@"show(" withString:@"{\"show\":"];
    //                                     strRet1 = [strRet1 stringByReplacingOccurrencesOfString :@")" withString:@"}"];
    //                                     NSLog(@"###测试数据2--》%@", strRet1 );
    //                                     NSData* jsonData = [strRet1 dataUsingEncoding:NSUTF8StringEncoding]; 
    //                                     NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    //                                     NSDictionary *weatherInfo = [weatherDic objectForKey:@"show"];
    //                                     //NSString *location = [NSString stringWithFormat:@"号码识别：%@ 错误代码：%@ 识别次数：%@",[[[weatherInfo objectForKey:@"NumInfo"] componentsSeparatedByString:@"："] objectAtIndex:1],[weatherInfo objectForKey:@"errorCode"],[weatherInfo objectForKey:@"Amount"]];
    //                                     if ([[weatherInfo objectForKey:@"NumInfo"] hasPrefix:@"号码通"])
    //                                     {
    //                                         NumRecognize = [NSString stringWithFormat:@"%@",[[[weatherInfo objectForKey:@"NumInfo"] componentsSeparatedByString:@"："] objectAtIndex:1]];
    //                                     }
    //                                     else{
    //                                         NumRecognize = [NSString stringWithFormat:@"%@",[weatherInfo objectForKey:@"NumInfo"]];
    //                                     }
    //                                     NSLog(@"###weatherInfo字典里面的内容为--》%@", weatherDic );

    //                                    //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //                                    NSLog(@"sogou###==========================#################来电号码为：%@，识别信息为：%@",InComingNum,NumRecognize);
    //                                    //NSLog(@"HttpResponseCode:%d", responseCode);
    //                                    //NSLog(@"HttpResponseBody %@",responseString);

    //                                     dispatch_async(dispatch_get_main_queue(), ^{
    //                                         InComingNumRecognize = [[UILabel alloc] initWithFrame:CGRectMake((_awayView.frame.size.width - w)/2,120,w,h)];
    //                                         InComingNumRecognize.text = NumRecognize;
    //                                         InComingNumRecognize.textAlignment = NSTextAlignmentCenter;
    //                                         InComingNumRecognize.backgroundColor = [UIColor clearColor];
    //                                         InComingNumRecognize.textColor = [UIColor redColor];
    //                                         [_awayView addSubview:InComingNumRecognize];

    //                                     });
                                        
    //                                }
    //                            }];
    //     //InComingNum = @"";
    // }
}

%end

%hook PHSingleCallParticipantLabelView
- (void)setLabel:(id)arg1{
    %orig;
    //UILabel *nameOverrideLabel = MSHookIvar<UILabel *>(self, "_nameOverrideLabel");
    NSLog(@"设置的标签为: %@,",arg1);//这里会显示   正在呼叫   。。。
}
%end

UILabel *DialLabel = nil;

// %%%%%%%%%%%%%%%%%%%%这里是输入号码时的监控，这里以后可以加入拨号盘的归属地。%%%%%%%%%%%%%%%%%%%%%%%
%hook DialerController

- (void)_getPersonName:(id *)arg1 personLabel:(id *)arg2 personUID:(int *)arg3 forPhoneNumberString:(id)arg4{
	%orig;
	NSLog(@"取得输入的号码: %@",arg4);
    DialLabel.text = arg4;
}

- (void)viewDidLoad{
    %orig;
    UIView *_awayView = MSHookIvar<UIView *>(self, "_dialerView");
    //create a lable whose width = 200 and height = 100 and add to _awayView
    float w = 200;
    float h = 100;
    DialLabel = [[UILabel alloc] initWithFrame:CGRectMake((_awayView.frame.size.width - w)/2,100,w,h)];
    DialLabel.text = @"美国，圣地亚哥!!";
    DialLabel.textAlignment = NSTextAlignmentCenter;
    DialLabel.backgroundColor = [UIColor clearColor];
    DialLabel.textColor = [UIColor blackColor];
    [_awayView addSubview:DialLabel];

}

%end

%ctor
{
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR("com.kdfly.iboxsettings-preferencesChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, &callBack, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
    %init();
}

