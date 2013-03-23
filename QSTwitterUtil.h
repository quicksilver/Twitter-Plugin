//
//  QSTwitterUtil.h
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import <Foundation/Foundation.h>

@class GTMOAuthAuthentication;

@interface QSTwitterUtil : NSObject {
    GTMOAuthAuthentication *authentication;
}


@property (retain) GTMOAuthAuthentication *authentication;

+(id)sharedInstance;
-(void)twitterNotify:(NSString *)message;
- (void)signInToCustomService;
- (BOOL)isSignedIn;

@end
