//
//  BDWMGlobalData.h
//  UniBBS
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#ifndef BDWM_BDWMGlobalData_h
#define BDWM_BDWMGlobalData_h

//website address
#define BDWM_PREFIX                     @"http://www.bdwm.net/bbs/"
#define BDWM_INDEX_PAGE_SUFFIX          @"main0.php"
#define BDWM_ALL_PLATE_SUFFIX           @"bbsall.php"
#define BDWM_COMPOSE_SUFFIX             @"bbssnd.php"
#define BDWM_COMPOSE_MAIL_SUFFIX        @"bbspsm.php"
#define BDWM_MAIL_LIST_SUFFIX           @"bbsmil.php?go=A"
#define BDWM_REPLY_MAIL_SUFFIX          @"bbssdm.php"
//some magic number
#define PLATE_ELEMENT_NUMBER            8
#define TOPIC_ELEMENT_NUMBER            6
#define MAIL_LIST_ELEMENT_NUMBER        6
#define MAIL_REPLY_TABLE_TR_NUMBER      4
#define MAIL_DETAIL_FOOTER_ELEMENT_NUMBER   7
//others
//#define DEFAULT_USET_AGENT @"5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16"
#define DEFAULT_USET_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36"

#define POST_SUFFIX_STRING          @"\n\n发自我的“北大未名”iOS客户端(http://t.cn/R7ZhtYc)"
#ifdef DEBUG
#define DEFAULT_TIMEOUT_SECONDS     10//for test.
#else
#define DEFAULT_TIMEOUT_SECONDS     45 //longer for app review.
#endif

#define DB_NAME                     @"bdwm.db"

#endif
