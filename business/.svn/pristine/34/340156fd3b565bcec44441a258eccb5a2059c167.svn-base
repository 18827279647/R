//
//  SrocketViewController.m
//  rongxu
//
//  Created by admin on 16/4/14.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "SrocketViewController.h"
#import "AppDelegate.h"
#import "SaveData.h"
#import "Unit.h"
#import "AppRequest.h"
#import "WebsocketCmd.h"
#import "Notice.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Config.h"
@interface SrocketViewController ()

@end

static SrocketViewController *instance = nil;
static long AppRunTime=0;
__strong static NSMutableDictionary* Cmds;
static NSString* LogTag=@"WebSocket";
__strong static NSMutableArray* CloseTimes=nil;

long LastMessageTime=0;

__strong NSMutableDictionary* RequestCallbackData;
int RequestNumber=0;
bool available=false;
bool isRunInit=false;

@implementation SrocketViewController

+(SrocketViewController*)Instance {
    if (instance==nil) {
        instance=[[self alloc]init ];
        
        CloseTimes=[[NSMutableArray alloc]init];
        
        Cmds=[[NSMutableDictionary alloc]init];
        [Cmds setObject:[[[WebsocketCmd alloc]init] HaveReturn] forKey:@"Cmds"];
        [Cmds setObject:[[[WebsocketCmd alloc]init] HaveReturn] forKey:@"Echo"];
        [Cmds setObject:[[[WebsocketCmd alloc]init] HaveReturn] forKey:@"EchoData"];
        [Cmds setObject:[[[WebsocketCmd alloc]init] HaveReturn] forKey:@"GetUserAgent"];

        void(^SetUserAgentDef)(NSMutableDictionary*);
        SetUserAgentDef=^(NSMutableDictionary*param){
            if([[Unit JSONString:param key:@"data"] isEqualToString:@""]){
                [param setObject:[SrocketViewController GetUserAgent] forKey:@"data"];
            }
        };
        [Cmds setObject:[[[WebsocketCmd alloc]init] SetDef:SetUserAgentDef] forKey:@"SetUserAgent"];
        
        
        
        [Cmds setObject:[[[WebsocketCmd alloc]init] HaveReturn] forKey:@"GetCookies"];
        [Cmds setObject:[[WebsocketCmd alloc]init] forKey:@"SetCookies"];
        
        
        
        void(^LoginInDef)(NSMutableDictionary*);
        void(^LoginInCall)(NSString*,bool);
        LoginInDef=^(NSMutableDictionary* param){
            if([[Unit JSONString:param key:@"args"] isEqualToString:@""]){
                [param setObject:[Config GetAppType] forKey:@"args"];
            }
            if([[Unit JSONString:param key:@"data"] isEqualToString:@""]){
                [param setObject:[SrocketViewController GetLoginInCookies] forKey:@"data"];
            }
        };
        LoginInCall=^(NSString* data,bool isError){
            [instance LoginInCall];
        };
        [Cmds setObject:[[[[[WebsocketCmd alloc]init] HaveReturn] SetDef:LoginInDef] SetCall:LoginInCall] forKey:@"LoginIn"];
        
        
        
        [Cmds setObject:[[WebsocketCmd alloc]init] forKey:@"LoginOut"];
        [Cmds setObject:[[[WebsocketCmd alloc]init] NotAutoNumber] forKey:@"AppRun"];
        [Cmds setObject:[[[WebsocketCmd alloc]init] NotAutoNumber] forKey:@"AppStop"];
        [Cmds setObject:[[[WebsocketCmd alloc]init] HaveReturn] forKey:@"API"];
        
        
        
        void(^ReadUserMessageDef)(NSMutableDictionary*);
        void(^ReadUserMessageCall)(NSString*,bool);
        ReadUserMessageDef=^(NSMutableDictionary* param){
            if([[Unit JSONString:param key:@"data"] isEqualToString:@""]){
                NSString* data=[SaveData getData:@"EventUserLastID"];
                if([data isEqualToString:@""]){
                    data=@"0";
                }
                [param setObject:data forKey:@"data"];
            }
        };
        ReadUserMessageCall=^(NSString* data,bool isError){
            
            [instance ExecUserMessageResult:data isError:isError];
        };
        [Cmds setObject:[[[[[WebsocketCmd alloc]init] HaveReturn] SetDef:ReadUserMessageDef] SetCall:ReadUserMessageCall] forKey:@"ReadUserMessage"];
        
        
        
        
        
        void(^ReadChatMessageDef)(NSMutableDictionary*);
        void(^ReadChatMessageCall)(NSString*,bool);
        ReadChatMessageDef=^(NSMutableDictionary* param){
            if([[Unit JSONString:param key:@"args"] isEqualToString:@""]){
                NSString* args=[SaveData getData:@"EventChatXiaoquID"];
                if([args isEqualToString:@""]){
                    args=@"0";
                }
                [param setObject:args forKey:@"args"];
            }
            if([[Unit JSONString:param key:@"data"] isEqualToString:@""]){
                NSString* data=[SaveData getData:@"EventChatLastID"];
                if([data isEqualToString:@""]){
                    data=@"0";
                }
                [param setObject:data forKey:@"data"];
            }
        };
        ReadChatMessageCall=^(NSString* data,bool isError){
            [instance ExecChatMessageResult:data isError:isError];
        };
        [Cmds setObject:[[[[[WebsocketCmd alloc]init] HaveReturn] SetDef:ReadChatMessageDef] SetCall:ReadChatMessageCall] forKey:@"ReadChatMessage"];
        void(^ReadSystemMessageDef)(NSMutableDictionary*);
        void(^ReadSystemMessageCall)(NSString*,bool);
        ReadSystemMessageDef=^(NSMutableDictionary* param){
            if([[Unit JSONString:param key:@"data"] isEqualToString:@""]){
                NSString* data=[SaveData getData:@"EventSystemLastID"];
                if([data isEqualToString:@""]){
                    data=@"0";
                }
                [param setObject:data forKey:@"data"];
            }
        };
        ReadSystemMessageCall=^(NSString* data,bool isError){
            [instance ExecSystemMessageResult:data isError:isError];
        };
        [Cmds setObject:[[[[[WebsocketCmd alloc]init] HaveReturn] SetDef:ReadSystemMessageDef] SetCall:ReadSystemMessageCall] forKey:@"ReadSystemMessage"];
    }
    return instance;
}
+(bool)AppIsRun{
    return [Unit GetMS]-AppRunTime<13*1000;
}
+(void)AppRun{
    NSLog(@"%@.AppRun",LogTag);
    AppRunTime=[Unit GetMS];
}
+(void)AppStop{
    
    NSLog(@"%@.AppStop",LogTag);
    AppRunTime=0;
}
+(NSMutableDictionary*)BuildFailResponse:(NSString*)message{
    NSMutableDictionary* response=[[NSMutableDictionary alloc]init];
    [response setObject:@"" forKey:@"status"];
    [response setObject:message forKey:@"message"];
    return response;
}
+(NSString*)GetUserAgent{
    return [SaveData getData:@"setuesrAgent"];
}
+(NSString*)GetLoginInCookies{
    NSString* requestid=@"";
    NSString* token=@"";
    NSDictionary* userData=[Unit ParseJSONObject:[SaveData getData:@"UserData"]];
    requestid=[userData objectForKey:@"RequestID"];
    token=[userData objectForKey:@"Token"];
    
    if(!requestid){
        requestid=@"";
    }
    if(!token){
        token=@"";
    }
    
    return [NSString stringWithFormat:@"%@; %@"
            ,[self buildCookie:@"requestid" value:requestid]
            ,[self buildCookie:@"login_token" value:token]
            ];
}
+(NSString*)buildCookie:(NSString*) key value:(NSString*) value{
    return [NSString stringWithFormat:@"%@=%@",key,value];
}













// 初始化
-(void)Init;
{
    if(isRunInit){
        return;
    }
    
    [self Destroy];
    
    LastMessageTime=0;
    RequestNumber=1;
    available=false;
    RequestCallbackData=[[NSMutableDictionary alloc]init];
    
    NSString* url=[SaveData getData:@"WebSocketUrl"];
    if([url isEqualToString:@""]){
        NSLog(@"%@地址不存在，不连接服务器",LogTag);
        return;
    }
    NSLog(@"%@开始连接到:%@",LogTag,url);
    isRunInit=true;
    webSocket=[[SRWebSocket alloc]initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    webSocket.delegate=self;
    [webSocket open];
    
    if (timer!=nil) {
        [timer invalidate];
    }
    [self StartHeartbeat];
}
-(void)Destroy{
    if(webSocket){
        available=false;
        
        [self StopHeartbeat];

        webSocket.delegate=nil;
        [webSocket close];
        webSocket=nil;
    }
}
-(bool)Available{
    return available;
}
















-(void)StartHeartbeat{
    self.HeartbeatTimer=[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(AutoSendHeartbeat) userInfo:nil repeats:YES];
}
-(void)StopHeartbeat{
    //关闭定时器
    [self.HeartbeatTimer setFireDate:[NSDate distantFuture]];
}
-(void)AutoSendHeartbeat{
    [self SendHeartbeat:false];
}
//发送心跳
-(void)SendHeartbeat:(bool)send
{
    long now=[Unit GetMS];
    if(send || now-LastMessageTime+3000>30000)
    {
        [self Request:false cmd:[SrocketViewController AppIsRun]?@"AppRun":@"AppStop" args:@"" data:@"" callback:nil];
    }
}





















//发信息
-(void)Request:(bool)autoNumber
        cmd:(NSString*)cmd
        args:(NSString*)args
        data:(NSString*)data
        callback:(void(^)(NSString* data,bool isError))callback

{
    if(!available){
        if(!isRunInit){
            [self Init];
        }
        if(callback){
            callback(@"连接不可用",true);
        }
        return;
    }
    
    int number=1;
    
    
    if(autoNumber){
        RequestNumber+=2;
        number=RequestNumber;
    }
    
    if(callback){
        [RequestCallbackData setObject:callback forKey:[NSNumber numberWithInt:number]];
    }
    
    NSString* code=[NSString stringWithFormat:@"%d:%@",number,cmd];
    if(args && ![args isEqualToString:@""]){
        code=[NSString stringWithFormat:@"%@ %@",code,args];
    }
    if(data && ![data isEqualToString:@""]){
        code=[NSString stringWithFormat:@"%@ %@",code,data];
    }
    
    
    NSLog(@"%@.Request:%@",LogTag,code);
    
    [webSocket send:code];
    
    LastMessageTime=[Unit GetMS];
}
-(void)response:(int)number and:(NSString*)data
{
    NSString*code=[NSString stringWithFormat:@"%d:%@",number,data];
    
    
    NSLog(@"%@.response:%@",LogTag,code);
    
    [webSocket send:code];
    
    LastMessageTime=[Unit GetMS];

}





-(void)sendCmd:(NSString*) cmd
            args:(NSString*)args
            data:(NSString*)data
            callback:(void(^)(NSString*,bool))callback
{
    WebsocketCmd* webSocketCmd=[Cmds objectForKey:cmd];
    if(!webSocketCmd){
        if(callback){
            callback([NSString stringWithFormat:@"未识别命令%@",cmd],true);
        }
        return;
    }
    
    NSMutableDictionary* param=[[NSMutableDictionary alloc]init];
    [param setObject:args forKey:@"args"];
    [param setObject:data forKey:@"data"];
    
    void(^def)(NSMutableDictionary* param);
    def=webSocketCmd.def;
    if(def){
        def(param);
    }
    
    void(^call)(NSString*,bool);
    
    if(webSocketCmd.haveReturn && (webSocketCmd.call || callback)){
        call=^(NSString* data,bool isError){
            if(webSocketCmd.call){
                webSocketCmd.call(data,isError);
            }
            if(callback){
                callback(data,isError);
            }
        };
    }
    [self Request:!webSocketCmd.notAutoNumber
            cmd:cmd
            args:[Unit JSONString:param key:@"args"]
            data:[Unit JSONString:param key:@"data"]
            callback:call];
    
}














-(void)execMessage:(NSMutableArray*) data key:(NSString*)key
{
    
    if (data.count==0) {
        return;
    }
    
    int lastID=[[SaveData getData:key]intValue];
    for (int i=0;i<data.count;i++)
    {
        NSMutableDictionary*item=[Unit JSONArrayObject:data key:i];
        lastID=lastID>[[Unit JSONString:item key:@"id"]intValue]?lastID:[[Unit JSONString:item key:@"id"]intValue];
        bool appIsRun=[SrocketViewController AppIsRun];
        NSLog(@"%@.execMessage:AppIsRun:%d",LogTag,appIsRun);
    
    
        if (appIsRun)
        {

           NSLog(@"客户端打开");
            //客户端打开
            [[ViewController viewControllerManager] excode:[NSString stringWithFormat:@"AppRequest.Event(%@)",[Unit FormatJSONObject:item]]];
        
        //新增超时定时器
        self.EventTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(eventReceiveTime:) userInfo:item repeats:NO];
        //接收信息回调通知，收到就关闭定时器
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventReceiveNotice) name:@"eventReceiveNotice" object:nil];
        
        
        }
        else
        {
             NSLog(@"客户端未打开");
            //把运行状态和数据，key发过去。
            [Notice Notice:item];
        
            int num=[[SaveData getData:@"EventDataNumber"]intValue]+1;
            [SaveData setData:@"EventDataNumber" andIntValue:num];
            NSMutableArray*EventDataArray=[Unit ParseJSONArray:[SaveData getData:@"EventDataIndex"]];
            [EventDataArray addObject:[NSNumber numberWithInt:num]];
            [SaveData setData:@"EventDataIndex"andValue:[Unit FormatJSONArray:EventDataArray]];
            NSString*EventData=[NSString stringWithFormat:@"EventData%d",num];
            NSString*Data=[Unit FormatJSONObject:item];
        
            [SaveData setData:EventData andValue:Data];
        }
    }
    //保存那个最大值
    [SaveData setData:key andIntValue:lastID];
}

//新增信息超时处理
-(void)eventReceiveTime:(NSTimer*)Eventtime
{
    NSLog(@"客户端未打开");
    //把运行状态和数据，key发过去。
    NSMutableDictionary*item=[Eventtime userInfo];
    
    [Notice Notice:item];
    
    int num=[[SaveData getData:@"EventDataNumber"]intValue]+1;
    [SaveData setData:@"EventDataNumber" andIntValue:num];
    NSMutableArray*EventDataArray=[Unit ParseJSONArray:[SaveData getData:@"EventDataIndex"]];
    [EventDataArray addObject:[NSNumber numberWithInt:num]];
    [SaveData setData:@"EventDataIndex"andValue:[Unit FormatJSONArray:EventDataArray]];
    NSString*EventData=[NSString stringWithFormat:@"EventData%d",num];
    NSString*Data=[Unit FormatJSONObject:item];
    
    [SaveData setData:EventData andValue:Data];
    
    
    if (self.EventTimer!=nil) {
        [self.EventTimer invalidate];
        self.EventTimer=nil;
    }
}
//新增收到信息回调，执行取消定时器操作
-(void)eventReceiveNotice
{
    if (self.EventTimer!=nil) {
        [self.EventTimer invalidate];
        self.EventTimer=nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"eventReceiveNotice" object:nil];
}
-(void)execMessageResult:(NSString*)data isError:(bool)isError key:(NSString*)key{
    if(!isError){
        NSMutableDictionary* json=[Unit ParseJSONObject:data];
        if([[Unit JSONString:json key:@"status"] isEqualToString:@"success"]){
            [self execMessage:[Unit JSONArray:json key:@"value"] key:key];
        }
    }
}
-(void)execMessageRequest:(NSString*)jsonArrStr key:(NSString*)key{
    [self execMessage:[Unit ParseJSONArray:jsonArrStr] key:key];
}

-(void)ExecUserMessageRequest:(NSString*)jsonArrStr{
    [self execMessageRequest:jsonArrStr key:@"EventUserLastID"];
}
-(void)ExecUserMessageResult:(NSString*)data isError:(bool)isError{
    [self execMessageResult:data isError:isError key:@"EventUserLastID"];
}

-(void)ExecChatMessageRequest:(NSString*)jsonArrStr{
    [self execMessageRequest:jsonArrStr key:@"EventChatLastID"];
}
-(void)ExecChatMessageResult:(NSString*)data isError:(bool)isError{
    [self execMessageResult:data isError:isError key:@"EventChatLastID"];
}

-(void)ExecSystemMessageRequest:(NSString*)jsonArrStr{
    [self execMessageRequest:jsonArrStr key:@"EventSystemLastID"];
}
-(void)ExecSystemMessageResult:(NSString*)data isError:(bool)isError{
    [self execMessageResult:data isError:isError key:@"EventSystemLastID"];
}

//新增push
-(void)ExecPushRequest:(NSString*)jsonArrStr;
{
    NSMutableArray*PushDataArray=[Unit ParseJSONArray:jsonArrStr];
    for (int i=0;i<[PushDataArray count];i++) {
        NSMutableDictionary*item=[Unit JSONArrayObject:PushDataArray key:i];
        NSMutableDictionary*PushData=[Unit JSONObject:item key:@"PushData"];
        if (PushData.count==0) {
            return;
        }
        //类型
        int x_tt=[Unit JSONInt:PushData key:@"x_tt"];
        
        if (x_tt==1) {//系统信息
            [self ExecSystemMessageRequest:jsonArrStr];
        }else if(x_tt==2){//用户信息
            [self ExecUserMessageRequest:jsonArrStr];
        }else if (x_tt==3){//聊天信息
            [self ExecChatMessageRequest:jsonArrStr];
        }else{//改Id，当成系统消息处理,这个需要构造
            [item setObject:[NSNumber numberWithInt:0] forKey:@"id"];
            NSMutableArray*array=[[NSMutableArray alloc]init];
            [array addObject:item];
            [self ExecSystemMessageRequest:[Unit FormatJSONArray:array]];
        }
    }
}


-(void)LoginInCall
{
    [self sendCmd:@"ReadUserMessage" args:@"" data:@"" callback:nil];
    [self sendCmd:@"ReadChatMessage" args:@"" data:@"" callback:nil];
    [self sendCmd:@"ReadSystemMessage" args:@"" data:@"" callback:nil];
}




















/***********WebSocket回调*****************/

//接受新消息的处理
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    LastMessageTime=[Unit GetMS];
    
    NSLog(@"%@.didReceiveMessage:%@",LogTag,message);
    int number=0;
    NSString* data=@"";
    
    NSScanner*scan=[NSScanner scannerWithString:message];
    [scan scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    [scan scanInt:&number];
    
    NSRange range=[message rangeOfString:@":"];
    data=[message substringFromIndex:range.location+1];
    
    
    if(number%2==0)
    {
        //从服务器推送
        NSString* cmd=@"";
        range=[data rangeOfString:@" "];
        if(range.location==NSNotFound){
            cmd=data;
            data=@"";
        }else{
            cmd=[data substringWithRange:NSMakeRange(0, range.location)];
            data=[data substringFromIndex:range.location+1];
        }
        if([cmd isEqualToString:@"Alive"]){
            [self SendHeartbeat:true];
        }else if([cmd isEqualToString:@"ClientCmd"]){
            if ([SrocketViewController AppIsRun])
            {
                //如果客户端已打开，把数据转发给他处理
                [[ViewController viewControllerManager]excode:[NSString stringWithFormat:@"AppRequest.SocketClientCmd(\"%@\")",data]];
            }
           else
            {
                //如果未打开
                int num=[[SaveData getData:@"SocketClientCmdNumber"]intValue]+1;
                [SaveData setData:@"SocketClientCmdNumber"andIntValue:num];
                NSMutableArray*JSONArray=[Unit ParseJSONArray:[SaveData getData:@"SocketClientCmdIndex"]];
                [JSONArray addObject:[NSNumber numberWithInt:num]];
                [SaveData setData:@"SocketClientCmdIndex" andValue:[Unit FormatJSONArray:JSONArray]];
                NSString*SocketClientCmd=[NSString stringWithFormat:@"SocketClientCmd%d",num];
                [SaveData setData:SocketClientCmd andValue:data];
            }
        }else if([cmd isEqualToString:@"AppCmd"]){
            //解析数据，得到需要执行的命令名称
            NSMutableDictionary*json=[Unit ParseJSONObject:data];
            NSMutableDictionary*args=[Unit JSONObject:json key:@"args"];
            //获取命令
            cmd=[json objectForKey:@"cmd"];
            
            if([[Cmds allKeys] containsObject:cmd]){
                //WebSocket接口
                [self sendCmd:cmd args:[Unit JSONString:args key:@"args"] data:[Unit JSONString:args key:@"data"] callback:nil];
            }else{
                //AppClient接口
                NSMutableDictionary*json=[[NSMutableDictionary alloc]init];
                [json setObject:cmd forKey:@"action"];
                [json setObject:args forKey:@"args"];
                
                void(^callback)(NSData*);
                callback=^(NSData*data)
                {

                    NSString*sting=[Unit String:data];
                    [self response:number and:sting];
                
                };
                AppRequest*app=[[[AppRequest alloc]init] initWithJson:json and:callback];
                
                NSData*data=[[NSData alloc]init];
                if ([app hasAction])
                {
                 data=[app work];
                }
                if(!app.isAsync){
                    callback(data);
                }
          }
        }else if([cmd isEqualToString:@"UserMessage"]){
            [self ExecUserMessageRequest:data];
        }else if([cmd isEqualToString:@"ChatMessage"]){
            [self ExecChatMessageRequest:data];
        }else if([cmd isEqualToString:@"SystemMessage"]){
            [self ExecSystemMessageRequest:data];
        }else if([cmd isEqualToString:@"Push"]){//新增push
            [self ExecPushRequest:data];
            //回调
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            [self response:number and:[Unit FormatJSONObject:dic]];
        }
        else{
            NSLog(@"%@未识别服务器推送命令：%@",LogTag,cmd);
        }
    }
    else
    {
        //服务器的回调
        NSNumber* key=[NSNumber numberWithInt:number];
        void(^call)(NSString*,bool);
    
        call=[RequestCallbackData objectForKey:key];
        
        if(call){
            [RequestCallbackData removeObjectForKey:key];
            
            call(data,false);
        }
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    //NOOP
}
//连接成功后
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    isRunInit=false;
    available=true;
    
    NSLog(@"%@已连接服务器",LogTag);
    
    NSMutableArray* data=[[NSMutableArray alloc]init];
    [data addObject:[NSString stringWithFormat:@"SetUserAgent %@",[SrocketViewController GetUserAgent]]];
    [data addObject:[NSString stringWithFormat:@"LoginIn %@ %@",[Config GetAppType],[SrocketViewController GetLoginInCookies]]];
    
    
    void(^call)(NSString*,bool);
    call=^(NSString* data,bool isError){
        [instance LoginInCall];
    };
    
    [self Request:true cmd:@"Cmds" args:@"" data:[Unit FormatJSONArray:data] callback:call];
}
//连接关闭
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    
    NSLog(@"连接关闭");
    isRunInit=false;
    available=false;
    
    long now=[Unit GetMS];
    int len=(int)CloseTimes.count;
    if(len>0){
        //5分钟都没断过，突然断了
        if(now-[[CloseTimes objectAtIndex:len-1]longLongValue]>5*60*1000){
            [CloseTimes removeAllObjects];
        }
    }
    [CloseTimes addObject:[NSNumber numberWithLong:now]];
    len=(int)CloseTimes.count;
    if(len>5){
        //经常断，可能连不上服务器
        NSMutableArray* new=[[NSMutableArray alloc]init];
        for(int i=len-5;i<len;i++){
            [new addObject:[CloseTimes objectAtIndex:i]];
        }
        CloseTimes=new;
        len=(int)CloseTimes.count;
    }
    int wait=(len-1)*15*1000;//0,15,30,45,60,60...秒尝试连接服务器
    if(wait>0 && len>1){
        wait-=now-[[CloseTimes objectAtIndex:len-1] longLongValue];
    }
    if(wait<0){
        wait=1;
    }
        // NSLog(@"%@连接已断开，%d秒后重新连接",LogTag,wait/1000);
    timer=[NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(Init) userInfo:nil repeats:NO];
}
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    //NOOP
    isRunInit=false;
    available=false;
    NSLog(@"连接断开");
    long now=[Unit GetMS];
    int len=(int)CloseTimes.count;
    if(len>0){
            //5分钟都没断过，突然断了
        if(now-[[CloseTimes objectAtIndex:len-1]longLongValue]>5*60*1000){
            [CloseTimes removeAllObjects];
        }
    }
    [CloseTimes addObject:[NSNumber numberWithLong:now]];
    len=(int)CloseTimes.count;
    if(len>5){
            //经常断，可能连不上服务器
        NSMutableArray* new=[[NSMutableArray alloc]init];
        for(int i=len-5;i<len;i++){
            [new addObject:[CloseTimes objectAtIndex:i]];
        }
        CloseTimes=new;
        len=(int)CloseTimes.count;
    }
    int wait=(len-1)*15*1000;//0,15,30,45,60,60...秒尝试连接服务器
    if(wait>0 && len>1){
        wait-=now-[[CloseTimes objectAtIndex:len-1] longLongValue];
    }
    if(wait<0){
        wait=1;
    }
    NSLog(@"%@连接已断开，%d秒后重新连接",LogTag,wait/1000);
    timer=[NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(Init) userInfo:nil repeats:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NOOP
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //NOOP
}
-(void)dealloc
{

}
@end
