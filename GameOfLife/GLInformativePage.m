//
//  GLInformativePage.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/27/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLInformativePage.h"

@implementation GLInformativePage

+ (GLInformativePage *)howToPlayPage
{
   GLInformativePage *howToPlayPage = [GLInformativePage new];

   [howToPlayPage addHeaderText:@"HOW TO PLAY"];
   [howToPlayPage addNewLines:1];
   [howToPlayPage addBodyText:@"5. The Life algorithm was created by British mathematician "
                               "John Conway. Without John, we couldn't have brought you LiFE!"];
   [howToPlayPage addBodyText:@"4. If you don't read anything else, it's important that you "
                               "read this line."];
   [howToPlayPage addBodyText:@"3. The third thing you should know is that all the time "
                               "you spend playing LiFE is most certainly not time wasted."];
   [howToPlayPage addBodyText:@"2. What you get out of LiFE depends on what you put into it."];
   [howToPlayPage addBodyText:@"1. The \"Really Usefull Stuff\" is on the following pages."];
   
   return howToPlayPage;
}

+ (GLInformativePage *)creditsPage
{
   GLInformativePage *creditsPage = [GLInformativePage new];
   
   [creditsPage addHeaderText:@"CREDITS"];
   [creditsPage addNewLines:1];
   [creditsPage addBodyText:@"This game was made possible by:"];
   [creditsPage addBodyText:@"- Greg (Developer)"];
   [creditsPage addBodyText:@"- John (Algorithm)"];
   [creditsPage addBodyText:@"- Leif (Developer)"];
   [creditsPage addBodyText:@"- Nico (Sound FX + Creative Work)"];
   [creditsPage addNewLines:1];
   [creditsPage addBodyText:@"We hope that LiFE is a great experience for you...and we "
                             "thank you with our undying gratitude for trying out LiFE!"];
   [creditsPage addBodyText:@"LiFE started out as a learning experiment using Apple's sprite "
                             "kit for iOS. Everything in LiFE is made using sprite kit."];
   return creditsPage;
}

+ (GLInformativePage *)importPhotoPage
{
   GLInformativePage *importPhotoPage = [GLInformativePage new];

   [importPhotoPage addHeaderText:@"IMPORT PHOTO"];
   [importPhotoPage addNewLines:1];
   [importPhotoPage addBodyText:@"Try loading a previously captured LiFE game by pressing and "
                                 "holding the Camera button.  You will be shown your Photos "
                                 "where you can pick a photo to bring to LiFE."];
   [importPhotoPage addNewLines:1];
   [importPhotoPage addBodyText:@"LiFE will scan any picture in your Library, but will work best "
                                 "with a picture saved with LiFE."];
   return importPhotoPage;
}

+ (GLInformativePage *)sharePhotoPage
{
   GLInformativePage *sharePhotoPage = [GLInformativePage new];

   [sharePhotoPage addHeaderText:@"SHARE PHOTO"];
   [sharePhotoPage addNewLines:1];
   [sharePhotoPage addBodyText:@"Share LiFE with your friends and family by pressing "
                                "and holding the Restore button."];
   [sharePhotoPage addNewLines:1];
   [sharePhotoPage addBodyText:@"You will be shown your Messages app where you can add "
                                "people you wish to share LiFE with."];

   return sharePhotoPage;
}

@end
