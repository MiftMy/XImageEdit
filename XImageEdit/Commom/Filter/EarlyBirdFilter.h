//
//  EarlyBirdFilter.h
//  AreoxPlay
//
//  Created by mifit on 2016/12/7.
//  Copyright © 2016年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EarlyBirdFilter : NSObject
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    
    GLint AttribPos, UniformTex, AttribTexCoor;
    GLint StrLoc;
    
    GLint TextureLoc[5];
    GLint TextureHan[5];
    
    GLuint texture;
    GLuint textureId;
    
    GLsizei pixelsWide;//获取横向的像素点的个数
    GLsizei pixelsHigh;
    
    CGSize imgSize;
    
    //UIImage *_filterImage;
    unsigned char *imgPixel;
    unsigned char *imgPixel2;
    
    unsigned char *preImgPixel[4];
}

@property (nonatomic,strong) UIImage *image;
//@property (nonatomic,readonly) UIImage *filterImage;

- (NSString *)filterImage;
@end
