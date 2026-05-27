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
// placeholders (and empty strings) as absent so they don't leak through as
// truthy values to JS. Returns nil for an absent value so the caller can omit
// the key entirely, matching Android (which leaves the key out when null) and
// the documented behaviour of returning null/undefined when no SIM data exists.
+ (NSString *)normalizeCarrierValue:(NSString *)value
{
  if (!value
      || [value length] == 0
      || [value isEqualToString:@"--"]
      || [value isEqualToString:@"65535"]) {
    return nil;
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

  // Build the result with only the values that are actually available. Any
  // placeholder/absent field is left out so it reads back as undefined/null in
  // JS rather than as the literal "--" / "65535" / "" sentinel.
  NSMutableDictionary *simData = [NSMutableDictionary dictionary];
  simData[@"allowsVOIP"] = @(allowsVOIPResult);
  if (carrierNameResult)    simData[@"carrierName"] = carrierNameResult;
  if (carrierCountryResult) simData[@"countryCode"] = carrierCountryResult;
  if (carrierCodeResult)    simData[@"mcc"]         = carrierCodeResult;
  if (carrierNetworkResult) simData[@"mnc"]         = carrierNetworkResult;

  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:simData];

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
