//
//  WarmFilter.h
//  AreoxPlay
//
//  Created by mifit on 2016/12/7.
//  Copyright © 2016年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarmFilter : NSObject
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    
    GLint AttribPos, UniformTex, AttribTexCoor;
    GLint StrLoc;
    GLint ToneCurveLoc, Gray1Loc, Gray2Loc;
    GLuint ToneCurveTexture;
    GLuint Gray1TextureId, Gray2TextureId;
    
    GLuint texture;
    GLuint textureId;
    
    GLsizei pixelsWide;//获取横向的像素点的个数
    GLsizei pixelsHigh;
    
    //UIImage *_filterImage;
    unsigned char *imgPixel;
    unsigned char *imgPixel2;
    
    CFDataRef textureData1;
    CFDataRef textureData2;
//    unsigned char *imgPixelTem1;
//    unsigned char *imgPixelTem2;
}
@property (nonatomic,strong) UIImage *image;
//@property (nonatomic,readonly) UIImage *filterImage;

- (NSString *)filterImage;
@end
