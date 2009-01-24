//
//  UIImage+GLTexture.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-01-25.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface UIImage (GLTexture)
// if tex != 0, will reuse tex name
-(BOOL)loadIntoTexture:(GLuint*)tex;
@end
