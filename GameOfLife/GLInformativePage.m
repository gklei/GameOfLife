//
//  GLInformativePage.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/27/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLInformativePage.h"

@implementation GLInformativePage

+ (GLInformativePage *)aboutPage
{
   GLInformativePage *aboutPage = [GLInformativePage new];

   [aboutPage addHeaderText:@"HOW TO PLAY"];
   [aboutPage addNewLines:1];
   [aboutPage addBodyText:@"1. The Game of Life was orginally created by a British mathematician named John Conway."];
   [aboutPage addBodyText:@"2. The second thing that you really have to realize about this game is that it is actually very pointless and there is a good chance that you will waste a fair amount of time playing it."];
   [aboutPage addBodyText:@"3. This is another line that is really important."];
   [aboutPage addBodyText:@"4. The last thing that that you should really be aware of is that Leif Alton is the best programmer EVER."];

   return aboutPage;
}

+ (GLInformativePage *)creditsPage
{
   GLInformativePage *creditsPage = [GLInformativePage new];
   [creditsPage addHeaderText:@"CREDITS"];
   [creditsPage addNewLines:1];
   [creditsPage addBodyText:@"This game was created by:"];
   [creditsPage addNewLines:1];
   [creditsPage addBodyText:@"- Leif A. (Developer)"];
   [creditsPage addBodyText:@"- Gregory K. (Developer)"];
   [creditsPage addBodyText:@"- Nico G. (Sound FX + Creative Work)"];
   [creditsPage addBodyText:@"- John Conway (Algorithm)"];
   [creditsPage addNewLines:1];
   [creditsPage addBodyText:@"If you hate this game and think that the algorithm sucks, please contact John Conway.  Thank you for trying out LiFE!"];

   return creditsPage;
}

@end
