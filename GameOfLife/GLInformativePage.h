//
//  GLInformativePage.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/27/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPageLayer.h"

@interface GLInformativePage : GLPageLayer

+ (GLInformativePage *)aboutPage;
+ (GLInformativePage *)creditsPage;
+ (GLInformativePage *)importPhotoPage;
+ (GLInformativePage *)sharePhotoPage;

@end
