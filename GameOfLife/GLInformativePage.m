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

+ (GLInformativePage *)importPhotoPage
{
   GLInformativePage *importPhotoPage = [GLInformativePage new];

   [importPhotoPage addHeaderText:@"IMPORT PHOTO"];
   [importPhotoPage addNewLines:1];
   [importPhotoPage addBodyText:@"Try loading a previously captured LiFE state by pressing and holding the Camera button!  You will be taken to your Photo Library where you can access whichever photo you would like to turn to LiFE."];
   [importPhotoPage addNewLines:1];
   [importPhotoPage addBodyText:@"This feature may be used with any picture in your Photo Library, but it will work the best with a picture that was taken by pressing the camera button at the bottom."];

   return importPhotoPage;
}

+ (GLInformativePage *)sharePhotoPage
{
   GLInformativePage *sharePhotoPage = [GLInformativePage new];

   [sharePhotoPage addHeaderText:@"SHARE PHOTO"];
   [sharePhotoPage addNewLines:1];
   [sharePhotoPage addBodyText:@"Share a saved LiFE state with your friends by pressing and holding the Restore button!"];
   [sharePhotoPage addNewLines:1];
   [sharePhotoPage addBodyText:@"You will be taken to your messages app where you can add the repient(s) who you wish to see and potentially try out your LiFE."];

   return sharePhotoPage;
}

@end
