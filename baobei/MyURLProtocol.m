//
//  MyURLProtocol.m
//  NSURLProtocol
//
//  Created by zhaoyaqun on 15/11/30.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "MyURLProtocol.h"
#import "AppRequest.h"
#import "SaveData.h"
#import "Util.h"
static NSString *HEAD = @"MyURLProtocolHead";
static NSDictionary *MIMEdict ;
static NSString* False=@"false";
static NSString* True=@"true";
static NSString* NeedCacheKey=@"needCache";
static NSString* IsErrorKey=@"isError";
static NSString* CacheUrlKey=@"cahceUrl";

static NSString* CacheOFF=@"OFF";
static NSString* CacheON=@"ON";
static NSString* CacheUPDATE=@"UPDATE";



static NSString* StaticExt=
        @",png,jpg,webp,js,css,html,gif,ico,xml,svg,eot,woff,ttf,mp3,ogg,mp4,flv,f4v,zip,";

@implementation MyURLProtocol
{
    NSMutableDictionary *cacheSet;
    NSMutableData *dataArr;//接收到的数据
}

+(NSString *)getMime:(NSString *)ext
{
    
    if (!MIMEdict)
    {
        MIMEdict = [[NSDictionary alloc]initWithObjectsAndKeys:@"text/html",@"html", @"application/javascript",@"js",@"text/css",@"css",@"text/xml",@"xml",@"text/xml",@"svg",@"image/png",@"png",@"image/gif",@"gif",@"image/jpeg",@"jpg",@"image/x-icon",@"icon",@"application/octet-stream",@"eot",@"application/octet-stream",@"woff",@"application/octet-stream",@"ttf",@"application/octet-stream",@"data",nil];
    }
    NSString *mimeStr = [MIMEdict objectForKey:ext];
    if (!mimeStr)
    {
        mimeStr = [MIMEdict objectForKey:@"data"];
    }
    return mimeStr;
}

//创建NSURLProtocol实例，NSURLProtocol注册之后，所有的NSURLConnection都会通过这个方法检查是否持有该Http请求。
 + (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    
    BOOL isneed=false;
    
    
    if (!isneed && [request.URL.scheme hasPrefix:@"http"])
    {
        if([request.URL.path isEqual:@"/appclient/request"]){
            isneed=true;
        }
    }
    if (isneed && [request valueForHTTPHeaderField:HEAD])
    {
        isneed = false;
    }
    return isneed?YES:NO;
}

//NSURLProtocol抽象类必须要实现。通常情况下这里有一个最低的标准：即输入输出请求满足最基本的协议规范一致。因此这里简单的做法可以直接返回。一般情况下我们是不会去更改这个请求的。如果你想更改，比如给这个request添加一个title，组合成一个新的http请求。
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request;
{

    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a
                       toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

-(void)returnResponse:(NSURL *)urll andMime:(NSString *)mime andData:(NSData *)data
{
    NSHTTPURLResponse *  response = [[NSHTTPURLResponse alloc] initWithURL:urll MIMEType:mime expectedContentLength:[data length] textEncodingName:@"utf-8"];
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];

}

- (void)startLoading
{
    dataArr = [[NSMutableData alloc]init];
    cacheSet = [[NSMutableDictionary alloc]init];
    [cacheSet setObject:False forKey:IsErrorKey];
    [cacheSet setObject:False forKey:NeedCacheKey];
    
    NSMutableURLRequest* cacheRequest=(NSMutableURLRequest*)self.request;
    
    NSString *urlStr = cacheRequest.URL.absoluteString;
    
    /*******提取url数据*******/
    NSRegularExpression *urlExp = [NSRegularExpression regularExpressionWithPattern:@"(?:(.*?):)?[\\\\/]{2}([^\\\\/\\?#]*)([^\\?#]*)([^#]*)(.*)" options:0 error:nil];
    
    NSTextCheckingResult *match = [urlExp firstMatchInString:urlStr options:0 range:NSMakeRange(0, [urlStr length])];
    NSString *host = @"";
    NSString *path = @"";
    NSString *query = @"";
    NSString *hash = @"";
    NSString *ext = @"";
    NSString *filename =@"";
    NSRange range;
    
    if ([match numberOfRanges]>2) {
        range = [match rangeAtIndex:2];
        if (range.location+range.length<=urlStr.length)
        {
            host = [urlStr substringWithRange:range];
        }
    }
    
    if ([match numberOfRanges]>3) {
        range = [match rangeAtIndex:3];
        if (range.location+range.length<=urlStr.length)
        {
            path = [urlStr substringWithRange:range];
            NSRegularExpression * exppath = [NSRegularExpression regularExpressionWithPattern:@"(/.*?)([^/]*?(?:\\.([^\\.]+))?)$" options:0 error:nil];
            NSTextCheckingResult *m = [exppath firstMatchInString:path options:0 range:NSMakeRange(0, [path length])];
            if (m && [m numberOfRanges]>2)
            {
                range = [m rangeAtIndex:2];
                if (range.location+range.length<=path.length)
                {
                    filename  = [[path substringWithRange:range] lowercaseString];
                    
                }
            }
            if (m && [m numberOfRanges]>3)
            {
                range = [m rangeAtIndex:3];
                if (range.location+range.length<=path.length)
                {
                    ext = [[path substringWithRange:range] lowercaseString];

                }
            }
            
        }
    }

    if ([match numberOfRanges]>4) {
        range = [match rangeAtIndex:4];
        if (range.location+range.length<=urlStr.length)
        {
            query = [urlStr substringWithRange:range];
            
        }
        
    }
    NSRange hashRange;
    if ([match numberOfRanges]>5) {
        range = [match rangeAtIndex:5];
        hashRange = range;
        if (range.location+range.length<=urlStr.length)
        {
            hash = [urlStr substringWithRange:range];
            
        }
        
    }
    /********提取url数据End***************/
    
    while(true)
    {
        
        /*********app请求**********/
        if ([path isEqualToString:@"/appclient/request"])
        {
            NSString *jsonStr = [[[self.request URL] query]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      
            void(^callback)(NSData*);
            
            callback=^(NSData*data)
            {
                NSString * dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *codeStr = [NSString stringWithFormat:@"AppRequest.Call(%@)",dataStr];
                [[ViewController viewControllerManager] excode:codeStr];
            };

            AppRequest *app = [[AppRequest alloc] init:jsonStr and:callback];
            [self returnResponse:[self.request URL] andMime:@"text/json" andData:[app work]];
            return;
        }
        
        
        /*****缓存*************/
        if (![SaveData AllowCacheHost:host])
        {
            break;
        }
        
        NSString *cacheMode = CacheOFF;
    
        /**提取参数中的cacheMode**/
        NSRegularExpression *cacheExp =[NSRegularExpression regularExpressionWithPattern:@"AppCache=([\\w]+)" options:0 error:nil];
        NSTextCheckingResult *cacheM = [cacheExp firstMatchInString:query options:0 range:NSMakeRange(0, [query length])];
        BOOL isfind = false;
        NSString *queryCacheMode =@"";
        if (cacheM && [cacheM numberOfRanges]>1)
        {
            range = [cacheM rangeAtIndex:0];
            if (range.location+range.length<=query.length)
            {
                queryCacheMode = [query substringWithRange:range];
            }

            range = [cacheM rangeAtIndex:1];
            if (range.location+range.length<=query.length)
            {
                cacheMode = [query substringWithRange:range];
                isfind = true;
            }
        }
        if (isfind)
        {
            if ([hash length]>0) {
                urlStr = [urlStr substringWithRange:NSMakeRange(0, hashRange.location)];
            }
            if([cacheMode isEqualToString:CacheON] || [cacheMode isEqualToString:CacheUPDATE]){
                urlStr = [urlStr stringByReplacingOccurrencesOfString:queryCacheMode withString:@"AppCache=Load"];
                
                /**更新请求**/
                cacheRequest=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlStr]];
            }
        }else if([StaticExt containsString:[NSString stringWithFormat:@",%@,",ext]])
        {
           cacheMode = CacheON;
        }
    
    
//        /**读取缓存**/
//        if ([cacheMode isEqualToString:CacheON]) {
//            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
//            dataDict = [SaveData getCache:urlStr  andID:0];
//            if (dataDict)
//            {
//                NSData *getCacheData =  [dataDict objectForKey:@"data"];
//                NSString *mime =[[dataDict objectForKey:@"otherInfo"] objectForKey:@"MIMEType"];
//
//                [self returnResponse:[self.request URL] andMime:mime andData:getCacheData];
//                return;
//            }
//            /**读取app内置资源**/
//            if([path hasPrefix:@"/app/init/"])
//            {
//                NSString * htmlPath = [[NSBundle mainBundle] pathForResource:filename
//                                                                      ofType:@""];
//
//                NSData *htmlData = [[NSData alloc]initWithContentsOfFile:htmlPath];
//                if (htmlData)
//                {
//                    NSLog(@"请求内置资源");
//                    [self returnResponse:[self.request URL] andMime:[MyURLProtocol getMime:ext] andData:htmlData];
//                    return;
//                }
//            }
//
//            cacheMode=CacheUPDATE;
//        }
    
        if ([cacheMode isEqualToString:CacheUPDATE])
        {
            [cacheSet setObject:True forKey:NeedCacheKey];
            [cacheSet setObject:urlStr forKey:CacheUrlKey];
        }
        
        break;
    }
    
    //请求服务器 缓存＋其他请求
    [cacheRequest addValue:@"1" forHTTPHeaderField:HEAD];
    self.connection = [NSURLConnection connectionWithRequest:cacheRequest delegate:self];

}
- (void)stopLoading
{
    [self.connection cancel];
}

 - (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    
    return  request;
}

 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    
    [cacheSet setObject:True forKey:IsErrorKey];
}

 - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)P
{
    NSHTTPURLResponse* response=(NSHTTPURLResponse*)P;
    NSInteger statusCode=response.statusCode;
    
    if([[cacheSet objectForKey:NeedCacheKey] isEqualToString:True]){
        //检查mime，如果需要修改就从新构造response
        NSString* mime=[response.MIMEType lowercaseString];
        NSRange range=[mime rangeOfString:@"/"];
        NSString*Private=[mime substringToIndex:range.location];
        NSString*code=[mime substringFromIndex:range.location+1];

        if ([Private isEqualToString:@"private"])
        {
            if ([code isEqualToString:@"page"])
            {
                code=@"text/html";
            }else
            {
                code=[code stringByReplacingOccurrencesOfString:@".."
                                                     withString:@"/"];
            }
            mime=code;
        
            NSMutableDictionary* fields=[[NSMutableDictionary alloc] init];
            NSDictionary* dic=response.allHeaderFields;
            for (NSString*key in [dic allKeys])
            {
                NSString* value=[dic objectForKey:key];
                if([[key lowercaseString] isEqualToString:@"content-type"]){
                    NSLog(@"MIME Change %@=%@ -> %@",key,value,mime);

                    value=mime;
                }
                [fields setObject:value forKey:key];
            }
        
            response=[[NSHTTPURLResponse alloc] initWithURL:[[self request] URL] statusCode:statusCode HTTPVersion:@"HTTP/1.1" headerFields:fields];
        }
    }
    
    self.response = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    if([[cacheSet objectForKey:NeedCacheKey] isEqualToString:True]){
        if (statusCode !=200)
        {
            [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"fail" code:statusCode userInfo:nil]];
        }
    }
}

 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
    
    
    if ([[cacheSet objectForKey:NeedCacheKey] isEqualToString:True])
    {
        [dataArr appendData:data];
    }
}


 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocolDidFinishLoading:self];
    
    bool isError=false;
    if(!isError && [[cacheSet objectForKey:IsErrorKey] isEqualToString:True]){
        isError=true;
    }
    if(!isError && self.response.statusCode !=200){
        isError=true;
    }
    if(!isError && [[cacheSet objectForKey:NeedCacheKey] isEqualToString:False]){
        isError=true;
    }
    //保存缓存数据
    if (!isError) {
        NSData *data =nil;
        [SaveData saveCache:[cacheSet objectForKey:CacheUrlKey] andResponse:self.response andString:data];
    }

    self.connection = nil;
    self.response = nil;
}


@end
