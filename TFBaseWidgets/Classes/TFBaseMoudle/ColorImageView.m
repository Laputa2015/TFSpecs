//
//  ColorImageView.m
//
//  Created by iMac on 16/12/12.
//  Copyright © 2016年 zws. All rights reserved.
//

#import "ColorImageView.h"

@interface ColorImageView()
@property (strong, nonatomic) UIView *panView;
@end

@implementation ColorImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)];
    if (self) {
        self.image = [UIImage imageNamed:@"palette"];
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.masksToBounds = YES;
        [self addSubview:self.panView];
    }
    return self;
}

- (void)setPickerPt:(CGPoint)pickerPt
{
    _pickerPt = pickerPt;
    self.panView.center = pickerPt;
    if (self.currentColorBlock) {
        UIColor *color = [self colorAtPixel:pickerPt];
        self.currentColorBlock(color,pickerPt);
    }
}

- (UIView*)panView
{
    if (!_panView) {
        _panView = [UIView new];
        _panView.frame = CGRectMake(self.frame.size.width/2-10,
                                    self.frame.size.height/2-10,
                                    20, 20);
        _panView.userInteractionEnabled = YES;
        _panView.backgroundColor = [UIColor clearColor];
        _panView.layer.borderColor = [UIColor whiteColor].CGColor;
        _panView.layer.borderWidth = 1.0;
        _panView.layer.cornerRadius = _panView.frame.size.width/2.0;
        _panView.layer.masksToBounds = YES;
    }
    return _panView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint pointL = [touch locationInView:self];
    
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        
        UIColor *color = [self colorAtPixel:pointL];
        self.panView.center = pointL;
        if (self.currentColorBlock) {
            self.currentColorBlock(color,pointL);
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint pointL = [touch locationInView:self];
    
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        
        UIColor *color = [self colorAtPixel:pointL];
        self.panView.center = pointL;
        if (self.currentColorBlock) {
            self.currentColorBlock(color,pointL);
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pointL = [touch locationInView:self];
    
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        
        UIColor *color = [self colorAtPixel:pointL];
        self.panView.center = pointL;
        if (self.currentColorBlock) {
            self.currentColorBlock(color,pointL);
        }
    }
}

//获取图片某一点的颜色
- (UIColor *)colorAtPixel:(CGPoint)point {
    //如果图片上不存在该点返回nil
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);//直接舍去小数，如1.58 -> 1.0
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.image.CGImage;
    NSUInteger width = self.image.size.width;
    NSUInteger height = self.image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//bitmap上下文使用的颜色空间
    int bytesPerPixel = 4; //bitmap在内存中所占的比特数
    int bytesPerRow = bytesPerPixel * 1;//bitmap的每一行在内存所占的比特数
    NSUInteger bitsPerComponent = 8;//内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
    unsigned char pixelData[4] = { 0, 0, 0, 0 }; //初始化像素信息
    //创建位图文件环境。位图文件可自行百度 bitmap
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);//指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);//当一个颜色覆盖上另外一个颜色，两个颜色的混合方式
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);//改变画布位置
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);//改变画布位置
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    NSLog(@"%f***%f***%f***%f",red,green,blue,alpha);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)setImage:(UIImage *)image {
    UIImage *temp = [self imageForResizeWithImage:image resize:CGSizeMake(self.frame.size.width, self.frame.size.width)];
    [super setImage:temp];
}

- (UIImage *)imageForResizeWithImage:(UIImage *)picture resize:(CGSize)resize {
    CGSize imageSize = resize; //CGSizeMake(25, 25)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [picture drawInRect:imageRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}
@end
