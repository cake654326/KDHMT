#import <Preferences/Preferences.h>

@interface kdhmtsettingsListController: PSListController {
}
@end

@implementation kdhmtsettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"kdhmtsettings" target:self] retain];
	}
	return _specifiers;
}

-(void)test{

    //NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tcc.taobao.com/cc/json/mobile_tel_segment.htm?tel=13071066880"]];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cx.shouji.360.cn/phonearea.php?number=+8613071066880"]];
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
                                    NSDictionary *GetLocationErrorCode = [weatherDic objectForKey:@"code"];
                                    NSLog(@"测试数据3--》%@", GetLocationErrorCode );
                                    NSDictionary *weatherInfo = [weatherDic objectForKey:@"data"];
                                    NSString *location = [NSString stringWithFormat:@"%@%@%@",[weatherInfo objectForKey:@"province"],[weatherInfo objectForKey:@"city"],[weatherInfo objectForKey:@"sp"]];
                                    NSLog(@"weatherInfo字典里面的内容为--》%@", weatherDic );

                                   //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"==========================#################来电号码为：000，归属地为：%@",location);
                                   //NSLog(@"HttpResponseCode:%d", responseCode);
                                   //NSLog(@"HttpResponseBody %@",responseString);
                               }
                           }];



    NSURL* url1 = [NSURL URLWithString:[NSString stringWithFormat:@"http://data.haoma.sogou.com/vrapi/query_number.php?number=14730359182&type=json&callback=show"]];
    NSMutableURLRequest* request1 = [NSMutableURLRequest new];
    [request1 setURL:url1];
    [request1 setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request1 setHTTPMethod:@"GET"];
    [request1 setTimeoutInterval:10];
    [request1 setHTTPShouldHandleCookies:FALSE];
    [request1 setValue:@"appliction/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    __block NSString* strRet1 = @"";
    NSOperationQueue *queue1 = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request1
                                       queue:queue1
                           completionHandler:^(NSURLResponse *response1, NSData *data1, NSError *error1){
                               if (error1) {
                                   //NSLog(@"Httperror:%@%d", error.localizedDescription,error.code);
                               }else{
       
                                   strRet1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                                    NSError *error;
                                    //加载一个NSURL对象
                                    // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.weather.com.cn/data/101180601.html"]];
                                    // //将请求的url数据放到NSData对象中
                                    // NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                                    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                                    NSLog(@"###测试数据1--》%@", strRet1 );
                                    strRet1 = [strRet1 stringByReplacingOccurrencesOfString :@"show(" withString:@"{\"show\":"];
                                    strRet1 = [strRet1 stringByReplacingOccurrencesOfString :@")" withString:@"}"];
                                    NSLog(@"###测试数据2--》%@", strRet1 );
                                    NSData* jsonData = [strRet1 dataUsingEncoding:NSUTF8StringEncoding]; 
                                    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                                    NSDictionary *weatherInfo = [weatherDic objectForKey:@"show"];
                                    //NSString *location = [NSString stringWithFormat:@"号码识别：%@ 错误代码：%@ 识别次数：%@",[[[weatherInfo objectForKey:@"NumInfo"] componentsSeparatedByString:@"："] objectAtIndex:1],[weatherInfo objectForKey:@"errorCode"],[weatherInfo objectForKey:@"Amount"]];
                                    NSString *location = [NSString stringWithFormat:@"%@",[[[weatherInfo objectForKey:@"NumInfo"] componentsSeparatedByString:@"："] objectAtIndex:1]];
                                    NSLog(@"###weatherInfo字典里面的内容为--》%@", weatherDic );

                                   //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"###==========================#################来电号码为：111，识别信息为：%@",location);
                                   //NSLog(@"HttpResponseCode:%d", responseCode);
                                   //NSLog(@"HttpResponseBody %@",responseString);
                               }
                           }];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test"
                            message:@"test"
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [alert show];
}
@end

// vim:ft=objc
