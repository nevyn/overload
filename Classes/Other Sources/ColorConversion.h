//
//  ColorConversion.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-01-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

/*
 HSL2RGB Converts hue, saturation, luminance values to the equivalent red, green and blue values.
For details on this conversion, see Fundamentals of Interactive Computer Graphics by Foley and van Dam (1982, Addison and Wesley)
You can also find HSL to RGB conversion algorithms by searching the Internet.
See also http://en.wikipedia.org/wiki/HSV_color_space for a theoretical explanation
 
 From the GLPaint sample
*/
extern void HSLToRGB(float h, float s, float l, float* outR, float* outG, float* outB);
