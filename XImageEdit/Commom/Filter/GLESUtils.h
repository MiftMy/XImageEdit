//
//  GLESUtils.h
//  XMOpenGL
//
//  Created by mifit on 15/12/14.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

@interface GLESUtils : NSObject
// Create a shader object, load the shader source string, and compile the shader.
+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

+ (GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;

+(GLuint)loadProgram:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentFilePath;
@end
