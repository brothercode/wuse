//
//  UIImage+Size.m
//  WuSe
//
//  Created by 潘嘉尉 on 15/12/16.
//  Copyright © 2015年 jiawei. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)


//压缩图片
-(NSData *)compressionImage:(UIImage *)image
{
    image = [image imageByScalingAndCroppingForSize];
    NSData *datatemp = UIImageJPEGRepresentation(image, 1);
    if (datatemp.length >60 *1024) {
        if (datatemp.length >1000 *1024) {
            NSLog(@"===%lu",datatemp.length);
            NSData *data = UIImageJPEGRepresentation(image, 0.5 -(datatemp.length -600 *1024)/(100*1024.0) *0.15);
            NSLog(@"===%lu",data.length);
            return data;
        }else if (datatemp.length >700 *1024) {
            NSLog(@"===%lu",datatemp.length);
            NSData *data = UIImageJPEGRepresentation(image, 0.5 -(datatemp.length -600 *1024)/(100*1024.0) *0.08);
            NSLog(@"===%lu",data.length);
            return data;
        }else if (datatemp.length >400 *1024) {
            NSLog(@"===%lu",datatemp.length);
            NSData *data = UIImageJPEGRepresentation(image, 0.7 -(datatemp.length -400 *1024)/(100*1024.0) *0.15);
            NSLog(@"===%lu",data.length);
            return data;
        }else if (datatemp.length >200 *1024) {
            NSLog(@"===%lu",datatemp.length);
            CGFloat scaleQuality = 200*1024/datatemp.length/2.0;
            NSData *data = UIImageJPEGRepresentation(image, scaleQuality +0.7);
            NSLog(@"===%lu",data.length);
            return data;
        }else if (datatemp.length >200 *1024){
            NSLog(@"===%lu",datatemp.length);
            CGFloat scaleQuality = 60*1024/datatemp.length/2.5;
            NSData *data = UIImageJPEGRepresentation(image, scaleQuality +0.8);
            NSLog(@"===%lu",data.length);
            return data;
        }else if (datatemp.length >100 *1024){
            if (datatemp.length >140 *1024) {
                NSLog(@"===%lu",datatemp.length);
                CGFloat scaleQuality = 60*1024.0/datatemp.length/4.0;
                NSData *data = UIImageJPEGRepresentation(image, scaleQuality +0.8);
                NSLog(@"===%lu",data.length);
                return data;
            }
            NSLog(@"===%lu",datatemp.length);
            CGFloat scaleQuality = 60*1024.0/datatemp.length/4.0;
            NSData *data = UIImageJPEGRepresentation(image, scaleQuality +0.85);
            NSLog(@"===%lu",data.length);
            return data;
        }
        NSLog(@"===%lu",datatemp.length);
        NSData *data = UIImageJPEGRepresentation(image, 1);
        NSLog(@"===%lu",data.length);
        return data;
    }else{
        return datatemp;
    }
    return datatemp;
}

-(NSData *)imageData:(UIImage *)image
{
    return UIImageJPEGRepresentation(image, 0.9);
}

-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

+ (CGSize)imageWithOriginalSize:(CGSize)originalSize{
    CGFloat originalWidth = originalSize.width;
    CGFloat originalHeight = originalSize.height;
    CGFloat scale = originalWidth/(kScreen_Width - 20);
    originalWidth = kScreen_Width - 20;
    originalHeight = 1/scale * originalHeight;
    return CGSizeMake(originalWidth, originalHeight);
}

+ (CGSize)imageWithOriginalSizeWithKScreenWidth:(CGSize)originalSize{
    CGFloat originalWidth = originalSize.width;
    CGFloat originalHeight = originalSize.height;
    CGFloat scale = originalWidth/(kScreen_Width);
    originalWidth = kScreen_Width;
    originalHeight = 1/scale * originalHeight;
    return CGSizeMake(originalWidth, originalHeight);
}

//图片压缩到指定大小
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingAndCroppingForSize
{
    CGSize targetSize = CGSizeMake(414 * 2.0, 414 * 2.0);
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        scaleFactor = widthFactor;
//        if (widthFactor > heightFactor)
//            scaleFactor = heightFactor; // scale to fit height
//        else
//            scaleFactor = widthFactor; // scale to fit width
        scaledWidth= targetWidth;
        scaledHeight = scaleFactor*height;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight)); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
