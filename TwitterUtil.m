////
////  TwitterUtil.m
////  QSTwit
////
////  Created by Masato Igarashi on 11/05/07.
////  Copyright 2011 @migrs. All rights reserved.
////
//
//#import "TwitterUtil.h"
//#import "JSON.h"
//#import "OAuthCore.h"
//#import "OAuth+Additions.h"
//#import "ConsumerKey.h"
//#import "QSTwitterDefines.h"
//
//
//void TwitterNotify(NSString *message)
//{
//    QSShowNotifierWithAttributes(
//                                 [NSDictionary dictionaryWithObjectsAndKeys:@"QSTwit",
//                                  QSNotifierTitle, message, QSNotifierText,
//                                  [QSResourceManager imageNamed:@"QSTwit"],QSNotifierIcon,nil]);
//}
//
//NSData *OAuthRequest(NSURL *url, NSData *body, NSString *token, NSString *secret) {
//    NSString *method = @"POST";
//    NSString *header = OAuthorizationHeader(url, method, body, CONSUMER_KEY, CONSUMER_KEY_SECRET, token, secret);
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:method];
//    [request setValue:header forHTTPHeaderField:@"Authorization"];
//    [request setHTTPBody:body];
//    NSURLResponse *response = nil;
//    NSError       *error    = nil;
//    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    return result;
//}
//
//NSString *RequestToken() {
//    NSURL *url = [NSURL URLWithString:kTwitterRequestTokenURL];
//    NSData *body = [[NSString stringWithFormat:@"oauth_callback=%@",kQSTwitterCallbackURL] dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *result = OAuthRequest(url, body, @"", @"");
//    NSDictionary *dict = [NSURL ab_parseURLQueryString:[[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease]];
//    return @"";
//}
//
//NSDictionary *AccessTokenRequest(NSString *username, NSString *password) {
//    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
//    NSData *body = [[NSString stringWithFormat:@"x_auth_username=%@&x_auth_password=%@&x_auth_mode=client_auth", username, password] dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSData *result = OAuthRequest(url, body, @"", @"");
//    NSDictionary *dict = [NSURL ab_parseURLQueryString:[[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease]];
//    return dict;
//}
//
//NSDictionary *Tweet(NSString *message, NSString *token, NSString *secret) {
//    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
//    NSData *body = [[NSString stringWithFormat:@"status=%@", message] dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *result = OAuthRequest(url, body, token, secret);
//    NSString *resultString = [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
//    NSDictionary *dict = [resultString JSONValue];
//    return dict;
//}
