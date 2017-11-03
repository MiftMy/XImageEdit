//
//  CrayonFilter.m
//  AreoxPlay
//
//  Created by mifit on 2016/12/7.
//  Copyright © 2016年 Mifit. All rights reserved.
//

#import "CrayonFilter.h"
#import "GLESMath.h"
#import "GLESUtils.h"
#import "XMImageHelper.h"

GLfloat cubeCrayonFilterOrg[] = { -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f, 1.0f,
    1.0f, 1.0f };

GLfloat cubeCrayonFilter[] = { -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f, 1.0f,
    1.0f, 1.0f };

GLfloat TexcoorCrayonFilter[] = { 0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f };

@implementation CrayonFilter

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
        [self adjustImageDisplaySize];
        
        [self destoryRenderAndFrameBuffer];;
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        [self render];
    }
}

- (void)dealloc {
    [self destoryAll];
    NSLog(@"dealloc --- crayon");
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
        return;
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
//    bitmapBytesPerRow = 4 * pixelsWide; //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
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
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"crayonVertexShader" ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"crayonFragmentShader" ofType:@"glsl"];
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
    glUseProgram(_programHandle);
    glUniform1f(StrLoc, 2.0f);
    SSLocx = glGetUniformLocation(_programHandle, "singleStepOffsetX");
    SSLocy = glGetUniformLocation(_programHandle, "singleStepOffsetY");
    
    GLfloat w = 1.0f / (float)pixelsWide;
    GLfloat h = 1.0f / (float)pixelsHigh;
    glUniform1f(SSLocx, w);
    glUniform1f(SSLocy, h);
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
    
    cubeCrayonFilter[0] = cubeCrayonFilterOrg[0] / ratioH;
    cubeCrayonFilter[1] = cubeCrayonFilterOrg[1] / ratioW;
    cubeCrayonFilter[2] = cubeCrayonFilterOrg[2] / ratioH;
    cubeCrayonFilter[3] = cubeCrayonFilterOrg[3] / ratioW;
    cubeCrayonFilter[4] = cubeCrayonFilterOrg[4] / ratioH;
    cubeCrayonFilter[5] = cubeCrayonFilterOrg[5] / ratioW;
    cubeCrayonFilter[6] = cubeCrayonFilterOrg[6] / ratioH;
    cubeCrayonFilter[7] = cubeCrayonFilterOrg[7] / ratioW;
}

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
    
    if (imgPixel) {
        free(imgPixel);
        imgPixel = NULL;
    }
    
    if (imgPixel2) {
        free(imgPixel2);
        imgPixel2 = NULL;
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
    glVertexAttribPointer(AttribPos, 2, GL_FLOAT, false, 0, cubeCrayonFilter);
    glEnableVertexAttribArray(AttribTexCoor);
    glVertexAttribPointer(AttribTexCoor, 2, GL_FLOAT, false, 0, TexcoorCrayonFilter);
    
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    [self loadTexture];
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(UniformTex, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(AttribPos);
    glDisableVertexAttribArray(AttribTexCoor);
    
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
