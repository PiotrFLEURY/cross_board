#import "CrossBoardPlugin.h"
#if __has_include(<cross_board/cross_board-Swift.h>)
#import <cross_board/cross_board-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cross_board-Swift.h"
#endif

@implementation CrossBoardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCrossBoardPlugin registerWithRegistrar:registrar];
}
@end
