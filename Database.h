/********************************************************************************\
 *
 * File Name       Database.h
 *
 \********************************************************************************/

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface Database : NSObject {

	sqlite3 *databaseObj;

}
+(Database*) shareDatabase;

-(BOOL) createDataBase;
-(NSString *) GetDatabasePath;

-(NSMutableArray *)SelectAllFromTable:(NSString *)query;
-(int)getCount:(NSString *)query;
-(BOOL)CheckForRecord:(NSString *)query;
-(void)Insert:(NSString *)query;
-(void)Delete:(NSString *)query;
-(void)Update:(NSString *)query;
-(int)GetSum:(NSString*)query;
-(BOOL)createtable:(NSString *)CreatetableQuery;
@end
