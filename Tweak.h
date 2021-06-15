#import <UIKit/UIKit.h>

//https://stackoverflow.com/a/5337804
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NSArray (GameplayKit)
-(NSArray *)shuffledArray;
@end

@interface SBIcon : NSObject
-(UIImage *)getIconImage:(int)format; // iOS 12 | available formats:
/*
    Formats:
    0 - 29x29
    1 - 40x40
    2 - 62x62
    3 - 42x42
    4 - 37x48
    5 - 37x48
    6 - 82x82
    7 - 62x62
    8 - 20x20
    9 - 37x48
    10 - 37x48
    11 - 122x122
    12 - 58x58
*/
-(NSString *)applicationBundleID;
@property (nonatomic,readonly) int badgeValue;
@property (nonatomic,readonly) NSString * displayName;
@end

@interface FBSBundleInfo  : NSObject
@property (nonatomic,readonly) NSURL * bundleURL;
@end

@interface SBApplicationInfo : FBSBundleInfo
@end

@interface SBApplication : UIApplication
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,retain) SBApplicationInfo * info;
@end

@interface SBApplicationIcon : SBIcon
-(SBApplication *)application;
@end

@interface SBHIconModel : NSObject
@property (nonatomic,copy,readonly) NSSet * hiddenIconTags;
@property (nonatomic,copy,readonly) NSSet * leafIcons; //iOS 13
-(void)setDesiredIconState:(NSDictionary *)arg1; // iOS 13
// -(void)setSortsIconsAlphabetically:(BOOL)arg1 ; //works, but keeps folders intact + sorts folders and widgets
-(void)removeAllIcons;
-(void)layout;
-(id)iconState;
@end

@interface SBIconModel : SBHIconModel//{
    // NSSet* _hiddenIconTags;  //iOS 12
// }
// -(NSDictionary *)leafIcons; //iOS 12
-(void)importDesiredIconState:(NSDictionary *)arg1; // iOS 12
// -(void)setSortsIconsAlphabetically:(BOOL)arg1 ; //iOS 12
-(void)removeIcon:(id)icon; //iOS 12
// -(void)layout; //iOS 12
// -(id)iconState; //iOS 12
-(SBIcon *)expectedIconForDisplayIdentifier:(NSString *)arg1;
@end

@interface SBIconListView : UIView
@property (getter=isEmpty,nonatomic,readonly) BOOL empty;
@property (getter=isFull,nonatomic,readonly) BOOL full;
@property (nonatomic,readonly) unsigned long long maximumIconCount; //if you want to know the number of icons permitted per listView
@property (nonatomic,retain) SBIconModel * model;
-(id)icons;
-(id)insertIcon:(id)icon atIndex:(int)index options:(int)options;
-(void)removeIcon:(id)arg1;
-(void)layoutIconsNow; //iOS 12
@end

@interface SBFolder : NSObject
@property (nonatomic,readonly) unsigned long long listCount; //total number of list views (HS pages)
@property (nonatomic,readonly) unsigned long long visibleListCount; //visible lists (selected) // iOS 14
@property (nonatomic,readonly) unsigned long long hiddenListCount; //hidden lists (unselected) // iOS 14
-(id)addIcon:(id)arg1;
-(void)addIcons:(id)arg1; //iOS 13+
@end

@interface SBFolderController : NSObject
@property (nonatomic,readonly) SBIconListView * dockIconListView;
@property(readonly, copy, nonatomic) NSArray *iconListViews;
@end

@interface SBHIconImageCache : NSObject{
    NSMutableDictionary *_images;
}
-(void)cacheImagesForIcons:(id)icons;
@end

@interface SBIconController : UIViewController
@property (nonatomic,readonly) SBHIconImageCache * appSwitcherUnmaskedIconImageCache;
@property (nonatomic,retain) SBIconModel * model;
@property (nonatomic,readonly) SBFolder * rootFolder;
+(instancetype)sharedInstance;
-(void)saveLayout; //SortingSwipe
-(void)loadLayout; //SortingSwipe
-(void)sortAppsWithConfiguration:(int)configuration forVersion:(int)version; //SortingSwipe
// -(SBFolder*)rootFolder; //iOS 12
-(SBFolderController *)_currentFolderController;
@end
