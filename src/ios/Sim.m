// MCC and MNC codes on Wikipedia
// http://en.wikipedia.org/wiki/Mobile_country_code

// Mobile Network Codes (MNC) for the international identification plan for public networks and subscriptions
// http://www.itu.int/pub/T-SP-E.212B-2014

// class CTCarrier
// https://developer.apple.com/reference/coretelephony/ctcarrier?language=objc

#import "Sim.h"
#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation Sim

// On iOS 16.4+ the deprecated CTCarrier no longer returns nil for an
// unavailable value. Instead it returns literal placeholder strings ("--" for
// carrier name / ISO country code, "65535" for MCC / MNC). Treat those
// placeholders as absent so they don't leak through as truthy values to JS.
+ (NSString *)normalizeCarrierValue:(NSString *)value
{
  if (!value
      || [value isEqualToString:@"--"]
      || [value isEqualToString:@"65535"]) {
    return @"";
  }
  return value;
}

- (void)getSimInfo:(CDVInvokedUrlCommand*)command
{
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = [netinfo subscriberCellularProvider];

  BOOL allowsVOIPResult = [carrier allowsVOIP];
  NSString *carrierNameResult = [Sim normalizeCarrierValue:[carrier carrierName]];
  NSString *carrierCountryResult = [Sim normalizeCarrierValue:[carrier isoCountryCode]];
  NSString *carrierCodeResult = [Sim normalizeCarrierValue:[carrier mobileCountryCode]];
  NSString *carrierNetworkResult = [Sim normalizeCarrierValue:[carrier mobileNetworkCode]];

  NSDictionary *simData = [NSDictionary dictionaryWithObjectsAndKeys:
    @(allowsVOIPResult), @"allowsVOIP",
    carrierNameResult, @"carrierName",
    carrierCountryResult, @"countryCode",
    carrierCodeResult, @"mcc",
    carrierNetworkResult, @"mnc",
    nil];

  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:simData];

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
