//
//  UploadFiler.m
//  Hoolink_IoT
//
//  Created by HL on 2018/7/3.
//  Copyright © 2018年 hoolink_IoT. All rights reserved.
//

#import "UploadFiler.h"

@implementation UploadFiler

#define UTF8Encode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

+(void)upload:(NSString *)name
     filename:(NSString *)filename
     mimeType:(NSString*)mimeType
         data:(NSData *)data
        upUrl:(NSString *)url
       parmas:(NSDictionary *)params
     complete:(void(^)(NSDictionary *dict))complete {
 
    // 文件上传
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";

    // 设置请求体
    NSMutableData *HTTP_Body = [NSMutableData data];

    /***************文件参数***************/
    
    // 参数开始的标志
    [HTTP_Body appendData:UTF8Encode(@"--YY\r\n")];
    
    // name : 指定参数名(必须跟服务器端保持一致)
    
    // filename : 文件名
    
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
    
    [HTTP_Body appendData:UTF8Encode(disposition)];
    
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType];
    
    [HTTP_Body appendData:UTF8Encode(type)];
    
    
    
    [HTTP_Body appendData:UTF8Encode(@"\r\n")];
    
    [HTTP_Body appendData:data];
    
    [HTTP_Body appendData:UTF8Encode(@"\r\n")];
    
    
    
    /***************普通参数***************/
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop) {
        
        // 参数开始的标志
        
        [HTTP_Body appendData:UTF8Encode(@"--YY\r\n")];
        
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
        
        [HTTP_Body appendData:UTF8Encode(disposition)];
        
        
        
        [HTTP_Body appendData:UTF8Encode(@"\r\n")];
        
        [HTTP_Body appendData:UTF8Encode(obj)];
        
        [HTTP_Body appendData:UTF8Encode(@"\r\n")];
        
    }];
    
    
    
    /***************参数结束***************/
    
    // YY--\r\n
    
    [HTTP_Body appendData:UTF8Encode(@"--YY--\r\n")];
    
    request.HTTPBody = HTTP_Body;
    
    
    
    // 设置请求头
    
    // 请求体的长度
    
    [request setValue:[NSString stringWithFormat:@"%zd", HTTP_Body.length]forHTTPHeaderField:@"Content-Length"];
    
    //声明这个POST请求是个文件上传
    
    [request setValue:@"multipart/form-data; boundary=YY"forHTTPHeaderField:@"Content-Type"];
    
    
    
    // 发送请求
    NSURLSessionDataTask *task =[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            NSLog(@"-----------------%@", dict);
            
            NSLog(@"上传成功");
            
            complete(dict);
        }else {
            NSLog(@"上传失败");
        }

    }];
    
    [task resume];
    
}




static NSString * const FORM_FLE_INPUT = @"upimg";//与服务器要求的key 一样

+ (NSString *)postRequestWithURL: (NSString *)url  // IN

                      postParems: (NSMutableDictionary *)postParems // IN

                     picFilePath: (NSString *)picFilePath  // IN上传图片路径

                     picFileName: (NSString *)picFileName  // IN
{
    
    
    
    
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    
    //根据url初始化request
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                    
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    
                                                       timeoutInterval:10];
    
    //分界线 --AaB03x
    
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    
    //结束符 AaB03x--
    
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    //得到图片的data
    
    NSData* data;
    
    
    
    if(picFilePath){
        
        
        
        UIImage *image=[UIImage imageWithContentsOfFile:picFilePath];
        
        //判断图片是不是png格式的文件
        
        if (UIImagePNGRepresentation(image)) {
            
            //返回为png图像。
            
            data = UIImagePNGRepresentation(image);
            
        }else {
            
            //返回为JPEG图像。
            
            data = UIImageJPEGRepresentation(image, 1.0);
            
        }
        
    }
    
    //http body的字符串
    
    NSMutableString *body=[[NSMutableString alloc]init];
    
    //参数的集合的所有key的集合
    
    NSArray *keys= [postParems allKeys];
    
    
    
    //遍历keys
    
    for(int i=0;i<[keys count];i++)
        
    {
        
        //得到当前key
        
        NSString *key=[keys objectAtIndex:i];
        
        
        
        //添加分界线，换行
        
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //添加字段名称，换2行
        
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        
        //添加字段的值
        
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        
        
        
        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
        
    }
    
    
    
    if(picFilePath){
        
        ////添加分界线，换行
        
        [body appendFormat:@"%@\r\n",MPboundary];
        
        
        
        //声明pic字段，文件名为boris.png
        
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",FORM_FLE_INPUT,picFileName];
        
        //声明上传文件的格式
        
        [body appendFormat:@"Content-Type: image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
        
        NSLog(@"body = %@",body);
        
    }
    
    
    
    //声明结束符：--AaB03x--
    
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    
    //声明myRequestData，用来放入http body
    
    NSMutableData *myRequestData=[NSMutableData data];
    
    
    
    //将body字符串转化为UTF8格式的二进制
    
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(picFilePath){
        
        //将image的data加入
        
        [myRequestData appendData:data];
        
    }
    
    //加入结束符--AaB03x--
    
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    //设置HTTPHeader中Content-Type的值
    
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    //设置HTTPHeader
    
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    
    //设置Content-Length
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    
    [request setHTTPBody:myRequestData];
    
    //http method
    
    [request setHTTPMethod:@"POST"];
    
    
    
    
    
//    __block NSHTTPURLResponse *urlResponese = nil;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        
        
//        NSString* result= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
//        if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
//            
//            NSLog(@"返回结果=====%@",result);
//            
//            return result;
//            
//        }
    }];
    
    [task resume];

    
    
    
    

    
    return nil;
    
}



/**
 
 * modify图片大小
 
 */

+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize{
    
    newSize.height=image.size.height*(newSize.width/image.size.width);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return  newImage;
    
    
    
}



/**
 
 * 保存图片
 
 */

+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName{
    
    NSData* imageData;
    
    
    
    //判断图片是不是png格式的文件
    
    if (UIImagePNGRepresentation(tempImage)) {
        
        //返回为png图像。
        
        imageData = UIImagePNGRepresentation(tempImage);
        
    }else {
        
        //返回为JPEG图像。
        
        imageData = UIImageJPEGRepresentation(tempImage, 1.0);
        
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    
    
    NSArray *nameAry=[fullPathToFile componentsSeparatedByString:@"/"];
    
    NSLog(@"===fullPathToFile===%@",fullPathToFile);
    
    NSLog(@"===FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    
    return fullPathToFile;
    
}

@end
