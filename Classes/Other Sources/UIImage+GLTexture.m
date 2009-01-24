//
//  UIImage+GLTexture.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-01-25.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "UIImage+GLTexture.h"


@implementation UIImage (GLTexture)
-(BOOL)loadIntoTexture:(GLuint*)tex;
{
    CGImageRef spriteImage = self.CGImage;
    if( ! spriteImage)
        return NO;

	// Get the width and height of the image
	NSUInteger width = CGImageGetWidth(spriteImage);
	NSUInteger height = CGImageGetHeight(spriteImage);
	// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
	// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.

    // Allocated memory needed for the bitmap context
    GLubyte *spriteData = (GLubyte *) malloc(width * height * 4);
    if(!spriteData)
        return NO;
    
    // Uses the bitmatp creation function provided by the Core Graphics framework. 
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    if(!spriteContext) {
        free(spriteData);
        return NO;
    }
    
    // After you create the context, you can draw the sprite image to the context.
    CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
    // You don't need the context at this point, so you need to release it to avoid memory leaks.
    CGContextRelease(spriteContext);
    
    // Use OpenGL ES to generate a name for the texture.
    if(*tex == 0)
        glGenTextures(1, tex);
    // Bind the texture name. 
    glBindTexture(GL_TEXTURE_2D, *tex);
    // Speidfy a 2D texture image, provideing the a pointer to the image data in memory
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    // Release the image data
    free(spriteData);
    
    return YES;
}
@end
