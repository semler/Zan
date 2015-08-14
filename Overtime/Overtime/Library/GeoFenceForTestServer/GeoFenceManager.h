//
//  GeoFenceManager.h
//
//  Copyright (c) 2013 ZENRIN DataCom CO., LTD. All Rights Reserved.
//

#import <Foundation/Foundation.h>

/* Library Version 2.0.0 */

#define GEOFENCE_MANAGER_LIBRARY_VERSION        @"2.0.0"
/**
	updateAreaInformationの戻り値
*/
enum {
	kGFlGeoFenceManagerUpdateNoError	= 0,	/*!< 更新成功 */
	kGFlGeoFenceManagerRequestServerDataError,	/*!< サーバーから取得したデータが不正(パース出来なかった) */
	kGFlGeoFenceManagerRequestServerError,		/*!< サーバーからエラーが返って来た */
	kGFlGeoFenceManagerRequestConnectionError,	/*!< 通信でエラーになった時 */
	kGFlGeoFenceManagerRequestUnauthorized,	    /*!< 認証エラーになった時 */
	kGFlGeoFenceManagerModeIsNotServer,	        /*!< モードがサーバーで無い時に呼び出された */
};
typedef NSInteger GeoFenceManagerUpdateAreaInfoResult;	/*!< エリア更新処理の戻り値の型 */

enum {
    kGFlGeoFenceManagerCheckUpdateAnyUpdates,
    kGFlGeoFenceManagerCheckUpdateNoUpdate,
    kGFlGeoFenceManagerCheckUpdateError,
    kGFlGeoFenceManagerCheckUpdateModeIsNotServer   /*!< モードがサーバーで無い時に呼び出された */
};
typedef NSInteger GeoFenceManagerCheckUpdateResult;

/**
	サーバーアクセスパラメータセットの戻り値
*/
enum {
	kGFlGeoFenceManagerSetParamSuccess	= 0,	/*!< 設定成功 */
	kGFlGeoFenceManagerSetParamNoRequired,		/*!< 必須パラメータが足りない */
};
typedef NSInteger GeoFenceManagerSetParamResult;/*!< サーバーアクセスパラメータ設定の戻り値の型 */

/**
    動作モード
*/
enum {
    kGFlGeoFenceManagerOperationMode_None = -1,         /*!< 動作モードの初期状態 */
    kGFlGeoFenceManagerOperationMode_ServerAccess = 0,  /*!< サーバーから情報を取得して動作モード */
    kGFlGeoFenceManagerOperationMode_Manual,            /*!< アプリが通知条件やエリア情報を設定するモード */
};
typedef NSInteger GeoFenceManagerOperationMode;


/**
	ジオフェンスライブラリクラス
*/
@interface GeoFenceManager : NSObject

@property (nonatomic, assign, readonly) GeoFenceManagerOperationMode operationMode;

/**
	GeoFenceManagerを取得する
*/
+ (GeoFenceManager *)defaultManager;

/**
  GeoFenceManagerのパラメータをセットする

  @param	params	サーバーアクセスのパラメータ (operationModeがkGFlGeoFenceManagerOperationMode_ServerAccessの時に設定する)
  @param	mode	動作モードを指定する
  @return	結果
*/
- (GeoFenceManagerSetParamResult)setParams:(NSDictionary *)params operationMode:(GeoFenceManagerOperationMode)mode;

/**
	エリア情報を更新する
	
	@return エリア情報更新の結果
    @note   動作モードが kGFlGeoFenceManagerOperationMode_ServerAccess 以外の時には何もしない
*/
- (GeoFenceManagerUpdateAreaInfoResult)updateAreaInformation;

/**
	引数のlocationInfoでエリア判定を行う
	
	@param	timeStamp	location情報のタイムスタンプ
	@param	latitude	緯度
	@param	longitude	経度
	@param	horizontalAccuracy	測定誤差(m)
	@return	エリア判定した情報のリスト
*/
- (NSArray *)checkLocation:(NSDate *)timeStamp
				  latitude:(double)latitude
				 longitude:(double)longitude
		horizontalAccuracy:(NSInteger)horizontalAccuracy;

/**
    通知条件を追加する

    @param  informationList
    @return 追加できなかった通知条件のリスト, すべて追加できた場合, 空の配列を返す
*/
- (NSArray *)addNotificationConditionInformation:(NSArray *)informationList;

/**
    通知条件を削除する

    @param  informationIDList   削除する通知条件IDのリスト
    @return 削除した通知条件IDのリスト
*/
- (NSArray *)removeNotificationConditionInformation:(NSArray *)informationIDList;

/**
    通知条件のリストを返す

    @param  informationIDList    取得する通知条件IDのリスト, nilの場合はすべて返す
    @return 通知条件のリスト
*/
- (NSArray *)notificationConditionInformationList:(NSArray *)informationIDList;

/**
    エリア情報を追加する

    @param informationList  追加するエリア情報のリスト
    @return 追加できなかったエリア情報のリスト, すべて追加できた場合, 空の配列を返す
*/
- (NSArray *)addAreaInformation:(NSArray *)informationList;

/**
    エリア情報を削除する
    
    @param areaIDList   削除するエリアIDのリスト
    @return 削除したエリアIDのリスト
*/
- (NSArray *)removeAreaInformation:(NSArray *)areaIDList;

/**
    エリア情報を取得する

    @param  areaIDList  取得するエリアIDのリスト, nilの場合はすべて返す
    @return エリア情報のリスト
*/
- (NSArray *)areaInformationList:(NSArray *)areaIDList;

/**
    エリア情報と通知条件の更新日時を取得して、更新があるかを返す
 
 @param  areaIDList  取得するエリアIDのリスト, nilの場合はすべて返す
 @return 更新があるかの結果
 */
- (NSDictionary *)checkAreaUpdate;

/**
    バージョン情報を返す
*/
- (NSString *)libraryVersion;

@end

extern NSString * const GFlGeoFenceManagerErrorDomain;	/*<! GeoFenceManagerのエラードメイン */

/**
	リクエストパラメータのキー文字列定義
*/
/*@{*/
extern NSString * const GFlRequestParamKeyClientid;	/**<! クライアントID */
extern NSString * const GFlRequestParamKeySecret;	/**<! 秘密鍵 */
extern NSString * const GFlRequestParamKeyTntp;	    /**<! 取得対象通知条件種別 */
extern NSString * const GFlRequestParamKeyTatp;	    /**<! 取得対象エリア情報種別 */
extern NSString * const GFlRequestParamKeyTmid;	    /**<! 取得対象端末ID */
extern NSString * const GFlNotificationConditionServerURLKey;   /**<! 通知条件サーバURL */
extern NSString * const GFlAreaInformationServerURLKey;         /**<! エリア情報サーバーURL */
extern NSString * const GFlModifiedDateServerURLKey;            /**<! エリア・通知更新日時サーバーURL */

// 下記はアプリからは直接指定しない物 //
extern NSString * const GFlRequestParamKeyAuthType; /**<! 認証方式  */
extern NSString * const GFlRequestParamKeyTnid;	    /**<! 取得対象通知条件ID */
extern NSString * const GFlRequestParamKeyTaid;		/**<! 取得対象エリアID */
extern NSString * const GFlRequestParamKeyOffset;	/**<! 取得開始位置 */
extern NSString * const GFlRequestParamKeyLimit;	/**<! 取得件数 */
/*@}*/

/**
	レスポンス情報のキー文字列定義
*/
/*@{*/
extern NSString * const GFlResponseTagKeyCondition;	/**<! 通知条件情報タグ */
extern NSString * const GFlResponseTagKeyArea;	/**<! エリア情報タグ */

// 共通 //
extern NSString * const GFlResponseKeyResponse;	/**<! レスポンス */
extern NSString * const GFlResponseKeyStatus;	/**<! ステータス */
extern NSString * const GFlResponseKeyReturnCode;	/**<! リターンコード */
extern NSString * const GFlResponseKeyErrorInfo;	/**<! エラー情報 */
extern NSString * const GFlResponseKeyErrorMsgId;	/**<! エラーメッセージID */
extern NSString * const GFlResponseKeyErrorMsg;	/**<! エラーメッセージ */
extern NSString * const GFlResponseKeyRecCount;	/**<! 取得レコード数 */
extern NSString * const GFlResponseKeyHitCount;	/**<! ヒット件数 */
extern NSString * const GFlResponseKeyResult;	/**<! 取得結果情報 */
extern NSString * const GFlResponseKeyRecord;	/**<! 端末情報 */

extern NSString * const GFlResponseKeyClinetid;	/**<! クライアントID */
extern NSString * const GFlResponseKeyMid;	/**<! 端末ID */
extern NSString * const GFlResponseKeyAid;	/**<! エリアID */

// 通知条件検索固有 //
extern NSString * const GFlResponseKeyNid;	/**<! 通知条件ID */
extern NSString * const GFlResponseKeyNtp;	/**<! 通知条件種別 */
extern NSString * const GFlResponseKeyNtmg;	/**<! 通知タイミング */
extern NSString * const GFlResponseKeyNwk;	/**<! 通知曜日 */
extern NSString * const GFlResponseKeyNstm;	/**<! 通知開始時間 */
extern NSString * const GFlResponseKeyNetm;	/**<! 通知終了時間 */
extern NSString * const GFlResponseKeyNsvd;	/**<! 通知開始期間 */
extern NSString * const GFlResponseKeyNevd;	/**<! 通知終了期間 */
extern NSString * const GFlResponseKeyNotnd;/**<! 再通知禁止日数 */

// エリア情報取得固有 //
extern NSString * const GFlResponseKeyAtp;	/**<! エリア情報種別 */
extern NSString * const GFlResponseKeyPinf;	/**<! ポリゴン情報 */
extern NSString * const GFlResponseKeyLat;	/**<! 中心緯度 */
extern NSString * const GFlResponseKeyLon;	/**<! 中心経度 */
extern NSString * const GFlResponseKeyRad;	/**<! 半径 */
extern NSString * const GFlResponseKeyMsg;	/**<! エリア説明 */
extern NSString * const GFlResponseKeyInlv;	/**<! IN精度閾値 */
extern NSString * const GFlResponseKeyInfnum;	/**<! IN確定回数閾値 */
extern NSString * const GFlResponseKeyInftim;	/**<! IN確定時間閾値 */
extern NSString * const GFlResponseKeyInmitim;	/**<! IN最低回数閾値 */
extern NSString * const GFlResponseKeyOutlv;	/**<! OUT精度閾値 */
extern NSString * const GFlResponseKeyOutfnum;	/**<! OUT確定回数閾値 */
extern NSString * const GFlResponseKeyOutftim;	/**<! OUT確定時間閾値 */
extern NSString * const GFlResponseKeyOutmitim;	/**<! OUT最低回数閾値 */
extern NSString * const GFlResponseKeyVst;	/**<! 有効期間(開始) */
extern NSString * const GFlResponseKeyVet;	/**<! 有効期間(終了) */
extern NSString * const GFlResponseKeyTout;	/**<! TIMEOUT閾値 */

// エリア情報・通知条件更新日 //

extern NSString * const GFlResponseKeyAmdt; /**<! エリア情報最新更新日時 */
extern NSString * const GFlResponseKeyNmdt; /**<! 通知条件最新更新日時 */

extern NSString * const GFlGeoFenceManagerCheckUpdateKeyResult;                     // 更新の有無の結果(NSNumber(GeoFenceManagerCheckUpdateResult))
extern NSString * const GFlGeoFenceManagerCheckUpdateKeyLibraryAreaDate;            // 保存されているエリア情報の更新日時(NSDate)
extern NSString * const GFlGeoFenceManagerCheckUpdateKeyLibraryNotificationDate;    // 保存されている通知条件の更新日時(NSDate)
extern NSString * const GFlGeoFenceManagerCheckUpdateKeyServerAreaDate;             // サーバのエリア情報の更新日時(NSDate)
extern NSString * const GFlGeoFenceManagerCheckUpdateKeyServerNotificationDate;     // サーバの通知条件の更新日時(NSDate)

/*@}*/

