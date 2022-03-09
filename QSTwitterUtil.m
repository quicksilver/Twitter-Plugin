//
//  QSTwitterUtil.m
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import "QSTwitterUtil.h"
#import "ConsumerKey.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthWindowController.h"
#import "QSTwitterDefines.h"
#import "QSTwitterPrefPane.h"

@implementation QSTwitterUtil

@synthesize authentication,prefPane;

+ (void)initialize {
    [QSTwitterUtil sharedInstance];
}
+ (QSTwitterUtil *) sharedInstance {
    static QSTwitterUtil *tu = nil;
    if (tu == nil) {
        tu = [[QSTwitterUtil alloc] init];
    }
    return tu;
}

-(id)init {
    if (self = [super init]) {
        GTMOAuthAuthentication *auth = [self auth];
        if (auth) {
            [GTMOAuthWindowController authorizeFromKeychainForName:kQSTwitterKeychainItemName
                                                                   authentication:auth];
        }
        [self setAuthentication:auth];

    }
    return self;
}
-(void)twitterNotify:(NSString *)message {
    QSShowNotifierWithAttributes(
                                 [NSDictionary dictionaryWithObjectsAndKeys:@"Quicksilver Twitter",
                                  QSNotifierTitle, message, QSNotifierText,
                                  [QSResourceManager imageNamed:@"QSTwit"],QSNotifierIcon,nil]);
}

- (GTMOAuthAuthentication *)auth {
    
    GTMOAuthAuthentication *auth;
    auth = [[[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:CONSUMER_KEY
                                                         privateKey:CONSUMER_KEY_SECRET] autorelease];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = kQSTwitterServiceName;
    
    return auth;
}

- (void)signOut {
    // remove the stored Twitter authentication from the keychain, if any
    [GTMOAuthWindowController removeParamsFromKeychainForName:kQSTwitterKeychainItemName];
    
    // discard our retains authentication object
    [self setAuthentication:nil];
}

// if 'user' is not nil then it's a direct message
-(QSObject *)tweet:(NSString *)message toUser:(NSString*)user {
    if (![self isSignedIn]) {
        [self twitterNotify:NSLocalizedStringFromTableInBundle(@"Not signed in to Twitter", nil, [NSBundle bundleForClass:[self class]], @"not signed in message")];
        return [QSObject textProxyObjectWithDefaultValue:message];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:user ? kTwitterDMURL : kTwitterUpdateURL];
    [request setValue:@"application/x-www-form-urlencoded"
   forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    message = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)message, NULL,CFSTR(":/?#[]@!$&’'()*+,;=."), kCFStringEncodingUTF8);
    [request setHTTPBody:[[NSString stringWithFormat:@"%@%@=%@", user ? [NSString stringWithFormat:@"screen_name=%@&", user] : @"" , user ? @"text" : @"status", message] dataUsingEncoding:NSUTF8StringEncoding]];
    [authentication authorizeRequest:request];
    QSGCDMainSync(^{
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
            if (err != nil) {
                [self twitterNotify:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"[Error] %@", nil, [NSBundle bundleForClass:[self class]], @"error sending tweet message"), [err localizedDescription]]];
				return;
			}
			NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
			if (err != nil) {
				[self twitterNotify:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"[Error] %@", nil, [NSBundle bundleForClass:[self class]], @"error sending tweet message"), [err localizedDescription]]];
				return;
			}
			if ([response valueForKey:@"text"]) {
				[self twitterNotify:NSLocalizedStringFromTableInBundle(@"Tweet sent successfully", nil, [NSBundle bundleForClass:[self class]], nil)];
			} else {
				[self twitterNotify:[NSString stringWithFormat:@"[ERROR] %@",[response valueForKey:@"error"]]];
			}
        }];
    });
    return nil;

}

- (void)signInToCustomService {
    [self signOut];
    NSString *scope = @"http://api.twitter.com/";    
    GTMOAuthAuthentication *auth = [self auth];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:kQSTwitterCallbackURL];
    
    // Display the autentication view
    GTMOAuthWindowController *windowController;
    windowController = [[[GTMOAuthWindowController alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:kTwitterRequestTokenURL
                                                       authorizeTokenURL:kTwitterAuthorizeURL
                                                          accessTokenURL:kTwitterAccessTokenURL
                                                          authentication:auth
                                                          appServiceName:kQSTwitterKeychainItemName
                                                          resourceBundle:[NSBundle bundleForClass:[self class]]] autorelease];
    [windowController signInSheetModalForWindow:nil
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)windowController:(GTMOAuthWindowController *)windowController
        finishedWithAuth:(GTMOAuthAuthentication *)auth
                   error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"%@", str);
        }
        
        [self setAuthentication:nil];
    } else {

        // save the authentication object
        [self setAuthentication:auth];
        [self.prefPane updateUI];
    }
}

-(void)getCredentials {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kTwitterUserCredURL];
    [authentication authorizeRequest:request];
    QSGCDMainSync(^{
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
            if (data) {
				NSDictionary *credentials = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
				if (err == nil) {
					[self.prefPane updateCredentials:credentials];
					return;
				}
            }
			// display the error
			[self.prefPane updateCredentials:@{@"name": [NSString stringWithFormat:@"[ERROR]: %@",[err localizedDescription]]}];
        }];
    });
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = [authentication canAuthorize];
    return isSignedIn;
}

@end
