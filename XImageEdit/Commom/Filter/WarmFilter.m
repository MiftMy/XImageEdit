//
//  WarmFilter.m
//  AreoxPlay
//
//  Created by mifit on 2016/12/7.
//  Copyright © 2016年 Mifit. All rights reserved.
//

#import "WarmFilter.h"
#import "GLESMath.h"
#import "GLESUtils.h"
#import "XMImageHelper.h"

GLfloat cubeWarmFilterOrg[] = { -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f, 1.0f,
    1.0f, 1.0f };

GLfloat cubeWarmFilter[] = { -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f, 1.0f,
    1.0f, 1.0f };

GLfloat TexcoorWarmFilter[] = { 0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f };

@implementation WarmFilter
//- (UIImage *)filterImage {
//    return _filterImage;
//}


- (void)setImage:(UIImage *)image {
    if (image) {
        _image = image;
        [self setupLayer];
        [self setupContext];
        
        [self setupTexture];
        [self setupProgram];
        [self initImageData];
        [self adjustImageDisplaySize];
        
        [self destoryRenderAndFrameBuffer];;
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        [self render];
    }
}

- (void)dealloc {
    [self destoryAll];
    NSLog(@"dealloc --- warm");
}

- (void)setupLayer {
    _eaglLayer = [CAEAGLLayer new];
    _eaglLayer.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}


- (BOOL)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        return NO;
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        return NO;
    }
    return YES;
}


- (void)setupTexture {
    //获取图片数据
    UIImage *image = self.image;
    if (!image) {
        image = [UIImage imageNamed:@"1.jpg"];
    }
    pixelsWide = CGImageGetWidth(image.CGImage); //获取横向的像素点的个数
    pixelsHigh = CGImageGetHeight(image.CGImage); //纵向
    
//    CGSize size = image.size;
//    CGContextRef context = NULL;
//    CGColorSpaceRef colorSpace;
//    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
//    int bitmapByteCount;
//    int bitmapBytesPerRow;
//    
//    bitmapBytesPerRow = 4 * pixelsWide;
//    //bitmapBytesPerRow = CGImageGetBytesPerRow(image.CGImage);; //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
//    bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
//    
//    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
//    bitmapData = malloc(bitmapByteCount); //分配足够容纳图片字节数的内存空间
//    context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
//    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
//    
//    CGColorSpaceRelease( colorSpace );
//    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
//    CFRelease(bitmapData);
//    /**/
//    //CGContextRef cgctx = context; //使用上面的函数创建上下文
//    CGRect rect = {{0,0},{size.width, size.height}};
//    CGContextDrawImage(context, rect, image.CGImage); //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
//    imgPixel = CGBitmapContextGetData (context);
//    CGContextRelease(context);

    imgPixel = [XMImageHelper convertUIImageToBitmapRGBA8:image];
    
    //    CGDataProviderRef proData = CGImageGetDataProvider(image.CGImage);
    //    CFDataRef data = CGDataProviderCopyData(proData);
    //    imgPixel =  (void *)CFDataGetBytePtr(data);
    //CFRelease(data);//不使用才能释放
    
    glDisable(GL_DITHER);
    glClearColor(0, 0, 0, 0);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelsWide, pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, imgPixel);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)setupProgram {
    
    // Load shaders
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"warmVertextShader" ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"warmFragmentShader" ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER withFilepath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER withFilepath:fragmentShaderPath];
    
    // Create program, attach shaders.
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Failed to create program.");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    // Link program
    glLinkProgram(_programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked );
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv (_programHandle, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog (_programHandle, infoLen, NULL, infoLog );
            NSLog(@"Error linking program:\n%s\n", infoLog );
            free (infoLog );
        }
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    glUseProgram(_programHandle);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    AttribPos = glGetAttribLocation(_programHandle, "position");
    UniformTex = glGetUniformLocation(_programHandle, "inputImageTexture");
    AttribTexCoor = glGetAttribLocation(_programHandle, "inputTextureCoordinate");
    StrLoc = glGetUniformLocation(_programHandle, "strength");
    
    // ÷∏∂®¬À≤®∆˜
    ToneCurveLoc = glGetUniformLocation(_programHandle, "curve");
    Gray1Loc = glGetUniformLocation(_programHandle, "layerImage");
    Gray2Loc = glGetUniformLocation(_programHandle, "greyFrame");
}

- (void)initImageData {
    glUniform1f(StrLoc, 1.0f);
    
    // ÷∏∂®¬À≤®∆˜
    glActiveTexture(GL_TEXTURE3);
    glGenTextures(1, &ToneCurveTexture);
    glBindTexture(GL_TEXTURE_2D, ToneCurveTexture);
    glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    GLbyte arrayOfByte[2048];
    GLuint arrayOfInt1[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6, 9, 12, 14, 17, 20, 23, 25, 28, 31, 33, 35, 38, 40, 42, 44, 46, 48, 50, 52, 53, 55, 57, 58, 60, 61, 63, 64, 65, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 80, 81, 82, 83, 83, 84, 85, 85, 86, 87, 87, 88, 88, 89, 90, 90, 91, 91, 92, 93, 93, 94, 94, 95, 96, 96, 97, 98, 99, 99, 100, 101, 102, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 114, 115, 116, 117, 119, 120, 121, 123, 124, 126, 127, 128, 130, 131, 133, 135, 136, 138, 139, 141, 143, 144, 146, 148, 149, 151, 153, 154, 156, 158, 159, 161, 163, 165, 166, 168, 170, 172, 173, 175, 177, 179, 180, 182, 184, 185, 187, 189, 190, 192, 194, 195, 197, 199, 200, 202, 203, 205, 207, 208, 210, 211, 213, 214, 215, 217, 218, 219, 221, 222, 223, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 238, 239, 240, 241, 241, 242, 243, 243, 244, 244, 245, 245, 246, 246, 247, 247, 248, 248, 249, 249, 249, 250, 250, 250, 251, 251, 251, 251, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 255, 255, 255, 255, 255, 255 };
    GLuint arrayOfInt2[] = { 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 87, 88, 89, 90, 91, 92, 93, 94, 95, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 235, 236, 237, 238, 239, 240, 241, 242 };
    GLuint arrayOfInt3[] = { 9, 10, 11, 11, 12, 13, 14, 15, 16, 16, 17, 18, 19, 20, 21, 21, 22, 23, 24, 25, 26, 26, 27, 28, 29, 30, 31, 31, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 40, 41, 42, 43, 44, 45, 45, 46, 47, 48, 49, 50, 50, 51, 52, 53, 54, 55, 55, 56, 57, 58, 59, 60, 60, 61, 62, 63, 64, 65, 66, 66, 67, 68, 69, 70, 71, 71, 72, 73, 74, 75, 76, 76, 77, 78, 79, 80, 81, 81, 82, 83, 84, 85, 86, 87, 87, 88, 89, 90, 91, 92, 93, 93, 94, 95, 96, 97, 98, 98, 99, 100, 101, 102, 103, 104, 104, 105, 106, 107, 108, 109, 110, 110, 111, 112, 113, 114, 115, 116, 116, 117, 118, 119, 120, 121, 122, 123, 123, 124, 125, 126, 127, 128, 129, 130, 130, 131, 132, 133, 134, 135, 136, 137, 137, 138, 139, 140, 141, 142, 143, 144, 144, 145, 146, 147, 148, 149, 150, 151, 152, 152, 153, 154, 155, 156, 157, 158, 159, 160, 160, 161, 162, 163, 164, 165, 166, 167, 168, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 225, 226, 227, 228, 229, 230 };
    GLuint arrayOfInt4[] = { 0, 0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31, 33, 34, 35, 37, 38, 40, 41, 42, 44, 45, 47, 48, 50, 51, 53, 54, 56, 58, 59, 61, 62, 64, 65, 67, 69, 70, 72, 73, 75, 77, 78, 80, 82, 83, 85, 86, 88, 90, 91, 93, 94, 96, 98, 99, 101, 102, 104, 105, 107, 108, 110, 111, 113, 114, 116, 117, 119, 120, 122, 123, 124, 126, 127, 129, 130, 131, 133, 134, 136, 137, 138, 140, 141, 142, 144, 145, 146, 147, 149, 150, 151, 153, 154, 155, 156, 157, 159, 160, 161, 162, 163, 165, 166, 167, 168, 169, 170, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 203, 204, 205, 206, 207, 208, 208, 209, 210, 211, 212, 212, 213, 214, 215, 216, 216, 217, 218, 218, 219, 220, 221, 221, 222, 223, 223, 224, 225, 225, 226, 227, 227, 228, 228, 229, 230, 230, 231, 231, 232, 233, 233, 234, 234, 235, 235, 236, 236, 237, 238, 238, 239, 239, 240, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 246, 247, 247, 248, 248, 249, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 255 };
    for (int i = 0; i < 256; i++){
        arrayOfByte[(i * 4)] = ((char)arrayOfInt1[i]);
        arrayOfByte[(1 + i * 4)] = ((char)arrayOfInt2[i]);
        arrayOfByte[(2 + i * 4)] = ((char)arrayOfInt3[i]);
        arrayOfByte[(3 + i * 4)] = ((char)arrayOfInt4[i]);
    }
    GLuint arrayOfInt5[] = { 0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9, 10, 11, 11, 11, 12, 13, 13, 14, 15, 15, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 24, 24, 25, 26, 27, 28, 28, 28, 29, 30, 31, 31, 32, 33, 34, 35, 36, 36, 37, 38, 39, 39, 40, 41, 41, 42, 43, 44, 45, 46, 47, 47, 48, 49, 50, 51, 52, 53, 54, 55, 55, 56, 57, 58, 59, 60, 61, 62, 63, 63, 64, 65, 66, 68, 69, 70, 71, 71, 72, 73, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 86, 87, 88, 89, 90, 92, 93, 94, 95, 95, 97, 98, 99, 100, 102, 103, 104, 105, 106, 108, 109, 110, 111, 112, 114, 115, 116, 117, 118, 119, 122, 123, 124, 125, 126, 127, 129, 130, 131, 132, 133, 134, 135, 137, 138, 139, 141, 142, 143, 144, 145, 146, 148, 149, 150, 151, 152, 154, 155, 156, 157, 158, 159, 161, 162, 164, 165, 166, 167, 168, 169, 170, 171, 173, 174, 175, 176, 177, 178, 179, 180, 183, 184, 185, 186, 187, 188, 190, 191, 192, 193, 194, 195, 196, 198, 199, 200, 201, 202, 203, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215, 216, 217, 219, 220, 221, 222, 223, 224, 226, 227, 228, 229, 230, 231, 233, 234, 235, 236, 237, 239, 240, 241, 242, 243, 243, 244, 246, 247, 248, 249, 250, 251, 253, 254, 255, 255, 255, 255, 255, 255, 255, 255 };
    GLuint arrayOfInt6[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 28, 29, 30, 31, 32, 33, 34, 35, 37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 47, 48, 49, 50, 51, 52, 53, 54, 55, 55, 56, 57, 58, 60, 61, 62, 63, 63, 64, 65, 66, 67, 68, 69, 70, 71, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 80, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 133, 134, 135, 136, 137, 138, 139, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 154, 155, 156, 157, 158, 159, 161, 162, 164, 165, 166, 167, 168, 169, 170, 171, 173, 174, 175, 176, 177, 178, 179, 180, 182, 183, 184, 185, 186, 187, 190, 191, 192, 193, 194, 195, 196, 198, 199, 200, 201, 202, 203, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215, 216, 217, 220, 221, 222, 223, 224, 226, 227, 228, 229, 230, 231, 233, 234, 235, 236, 237, 239, 240, 241, 242, 243, 244, 246, 247, 249, 250, 251, 253, 254, 255, 255, 255, 255, 255, 255, 255, 255 };
    GLuint arrayOfInt7[] = { 45, 45, 46, 46, 47, 47, 47, 47, 48, 48, 49, 49, 50, 50, 50, 51, 51, 52, 52, 53, 53, 54, 54, 55, 55, 55, 55, 56, 56, 57, 57, 58, 58, 59, 59, 60, 60, 61, 61, 62, 62, 63, 63, 63, 63, 64, 64, 65, 65, 66, 66, 67, 67, 68, 69, 69, 70, 70, 71, 71, 71, 72, 72, 73, 73, 74, 75, 75, 76, 76, 77, 78, 78, 79, 79, 80, 80, 80, 81, 82, 82, 83, 84, 84, 85, 86, 87, 87, 88, 89, 89, 90, 91, 92, 92, 93, 94, 95, 95, 95, 96, 97, 98, 98, 99, 100, 101, 102, 103, 103, 104, 105, 106, 107, 108, 109, 110, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 135, 136, 137, 138, 139, 141, 142, 143, 144, 146, 147, 148, 149, 150, 151, 152, 154, 156, 157, 158, 159, 160, 161, 162, 165, 166, 167, 168, 169, 170, 171, 173, 175, 176, 177, 178, 179, 180, 182, 183, 184, 186, 187, 188, 190, 191, 192, 193, 194, 195, 196, 198, 199, 200, 201, 202, 203, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215, 216, 217, 217, 219, 220, 221, 222, 223, 224, 226, 227, 227, 228, 229, 230, 231, 233, 234, 235, 235, 236, 237, 239, 240, 241, 241, 242, 243, 244, 246, 246, 247, 248, 249, 250, 251, 251, 253, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };
    GLuint arrayOfInt8[] = { 0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 8, 8, 8, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 23, 23, 23, 24, 24, 24, 25, 25, 25, 25, 26, 26, 27, 27, 28, 28, 28, 28, 29, 29, 30, 29, 31, 31, 31, 31, 32, 32, 33, 33, 34, 34, 34, 34, 35, 35, 36, 36, 37, 37, 37, 38, 38, 39, 39, 39, 40, 40, 40, 41, 42, 42, 43, 43, 44, 44, 45, 45, 45, 46, 47, 47, 48, 48, 49, 50, 51, 51, 52, 52, 53, 53, 54, 55, 55, 56, 57, 57, 58, 59, 60, 60, 61, 62, 63, 63, 64, 65, 66, 67, 68, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 88, 89, 90, 91, 93, 94, 95, 96, 97, 98, 100, 101, 103, 104, 105, 107, 108, 110, 111, 113, 115, 116, 118, 119, 120, 122, 123, 125, 127, 128, 130, 132, 134, 135, 137, 139, 141, 143, 144, 146, 148, 150, 152, 154, 156, 158, 160, 163, 165, 167, 169, 171, 173, 175, 178, 180, 182, 185, 187, 189, 192, 194, 197, 199, 201, 204, 206, 209, 211, 214, 216, 219, 221, 224, 226, 229, 232, 234, 236, 239, 241, 245, 247, 250, 252, 255 };
    for (int j = 0; j < 256; j++){
        arrayOfByte[1024 + (j * 4)] = ((char)arrayOfInt5[j]);
        arrayOfByte[1024 + (1 + j * 4)] = ((char)arrayOfInt6[j]);
        arrayOfByte[1024 + (2 + j * 4)] = ((char)arrayOfInt7[j]);
        arrayOfByte[1024 + (3 + j * 4)] = ((char)arrayOfInt8[j]);
    }
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, arrayOfByte);
    
    Gray1TextureId = [self loadImage:[UIImage imageNamed:@"warm_layer1.bmp"] index:4];
    Gray2TextureId = [self loadImage:[UIImage imageNamed:@"bluevintage_mask1.bmp"] index:5];
}

- (GLint)loadImage:(UIImage *)img index:(int)index {
    CGFloat Wide = CGImageGetWidth(img.CGImage); //获取横向的像素点的个数
    CGFloat High = CGImageGetHeight(img.CGImage); //纵向
    
    CGDataProviderRef proData = CGImageGetDataProvider(img.CGImage);
    CFDataRef data = CGDataProviderCopyData(proData);
    if (index == 4) {
        textureData1 = data;
    }
    if (index == 5) {
        textureData2 = data;
    }
    const void * pixel =  (void *)CFDataGetBytePtr(data);
    //CFRelease(data);//不使用才能释放
    
    GLuint t;
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &t);
    glBindTexture(GL_TEXTURE_2D, t);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, Wide, High, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLuint tId = -1;
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0 + index);
    glGenTextures(1, &tId);
    glBindTexture(GL_TEXTURE_2D, tId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, Wide, High, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
    glBindTexture(GL_TEXTURE_2D, 0);
    
//    if (index == 4) {
//        imgPixelTem1 = pixel;
//    }
//    if (index == 5) {
//        imgPixelTem2 = pixel;
//    }
    return tId;
}


- (void)adjustImageDisplaySize
{
    CGSize size = self.image.size;
    float ratio1 = (float)size.width/ pixelsWide;
    float ratio2 = (float)size.height / pixelsHigh;
    float ratioMax = (ratio1 > ratio2) ? ratio1 : ratio2;
    int Widthnew = round(pixelsWide*ratioMax);
    int Heightnew = round(pixelsHigh*ratioMax);
    
    float ratioW = Widthnew / (float)size.width;
    float ratioH = Heightnew / (float)size.height;
    
    cubeWarmFilter[0] = cubeWarmFilterOrg[0] / ratioH;
    cubeWarmFilter[1] = cubeWarmFilterOrg[1] / ratioW;
    cubeWarmFilter[2] = cubeWarmFilterOrg[2] / ratioH;
    cubeWarmFilter[3] = cubeWarmFilterOrg[3] / ratioW;
    cubeWarmFilter[4] = cubeWarmFilterOrg[4] / ratioH;
    cubeWarmFilter[5] = cubeWarmFilterOrg[5] / ratioW;
    cubeWarmFilter[6] = cubeWarmFilterOrg[6] / ratioH;
    cubeWarmFilter[7] = cubeWarmFilterOrg[7] / ratioW;
}

#pragma mark - layout
- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)destoryAll {
    if (texture) {
        glDeleteTextures(1, &texture);
        texture = 0;
    }
    
    if (textureId) {
        glDeleteTextures(1, &textureId);
        textureId = 0;
    }
    
    if (ToneCurveTexture) {
        glDeleteTextures(1, &ToneCurveTexture);
        ToneCurveTexture = 0;
    }
    
    if (Gray1TextureId) {
        glDeleteTextures(1, &Gray1TextureId);
        Gray1TextureId = 0;
    }
    
    if (Gray2TextureId) {
        glDeleteTextures(1, &Gray2TextureId);
        Gray2TextureId = 0;
    }
    
    if (imgPixel) {
        free(imgPixel);
        imgPixel = NULL;
    }
    
    if (imgPixel2) {
        free(imgPixel2);
        imgPixel2 = NULL;
    }
    
//    if (imgPixelTem1) {
//        free(imgPixelTem1);
//        imgPixelTem1 = NULL;
//    }
//    
//    if (imgPixelTem2) {
//        free(imgPixelTem2);
//        imgPixelTem2 = NULL;
//    }
    
    if (textureData1) {
        CFRelease(textureData1);//不使用才能释放
    }
    
    if (textureData2) {
        CFRelease(textureData2);//不使用才能释放
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_colorRenderBuffer) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
    if (_programHandle) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
}


- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)render {
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    CGSize size = self.image.size;
    glViewport(0, 0, size.width, size.height);
    
    glUseProgram(_programHandle);
    glEnableVertexAttribArray(AttribPos);
    glVertexAttribPointer(AttribPos, 2, GL_FLOAT, false, 0, cubeWarmFilter);
    glEnableVertexAttribArray(AttribTexCoor);
    glVertexAttribPointer(AttribTexCoor, 2, GL_FLOAT, false, 0, TexcoorWarmFilter);
    
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    [self loadTexture];
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(UniformTex, 0);
    
    if (ToneCurveTexture != -1) {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, ToneCurveTexture);
        glUniform1i(ToneCurveLoc, 3);
    }
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, Gray1TextureId);
    glUniform1i(Gray1Loc, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, Gray2TextureId);
    glUniform1i(Gray2Loc, 5);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(AttribPos);
    glDisableVertexAttribArray(AttribTexCoor);
    
    if (ToneCurveTexture != -1) {
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, 0);
        glActiveTexture(GL_TEXTURE0);
    }
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, 0);
    glActiveTexture(GL_TEXTURE0);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, 0);
    glActiveTexture(GL_TEXTURE0);
    
    //_filterImage = [self glToUIImage];
    
    //[_context presentRenderbuffer:GL_RENDERBUFFER];
    
    //UIImage *img = UIGraphicsGetImageFromCurrentImageContext();//获取不到
}

- (void)loadTexture {
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,  GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,      GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,      GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelsWide, pixelsHigh, 0, GL_RGBA, GL_UNSIGNED_BYTE, imgPixel);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (UIImage *) glToUIImage {
    
    NSInteger myDataLength = pixelsWide * pixelsHigh * 4;
    //NSInteger le = strlen(imgPixel);
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, pixelsWide, pixelsHigh, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < pixelsHigh; y++)
    {
        for(int x = 0; x < pixelsWide * 4; x++)
        {
            buffer2[((int)pixelsHigh - 1 - y) * (int)pixelsWide * 4 + x] = buffer[y * 4 * (int)pixelsWide + x];
        }
    }
    free(buffer);
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * pixelsWide;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(pixelsWide,pixelsHigh, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    //free(buffer2);
    imgPixel2 = buffer2;
    CFRelease(provider);
    CFRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    
    return myImage;
}


- (NSString *)filterImage
{
    GLenum error = GL_NO_ERROR;
    NSInteger dataLength = pixelsWide * pixelsHigh * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength);
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, pixelsWide, pixelsHigh, GL_RGBA, GL_UNSIGNED_BYTE, data);
    //NSData *pixelsRead = [NSData dataWithBytes:data length:dataLength];
    error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"error happend, error is %d, line %d",error,__LINE__);
    }
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(pixelsWide, pixelsHigh, 8, 32, pixelsWide * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    UIGraphicsBeginImageContext(CGSizeMake(pixelsWide, pixelsHigh));
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, pixelsWide, pixelsHigh), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSData *d = UIImageJPEGRepresentation(image, 1);
    NSString *documentDirPath = NSTemporaryDirectory();
    NSString *savingPath = [documentDirPath stringByAppendingPathComponent:@"tem.jpg"];
    BOOL succ = [d writeToFile:savingPath atomically:NO]; //is succeeded
    UIGraphicsEndImageContext();
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    if (succ) {
        return savingPath;
    } else {
        return nil;
    }
}

@end
