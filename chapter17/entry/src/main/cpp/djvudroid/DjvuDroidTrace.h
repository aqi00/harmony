/*
 * DjvuDroidTrace.h
 *
 *  Created on: 21.01.2010
 *      Author: Cool
 */

#ifndef DJVUDROIDTRACE_H_
#define DJVUDROIDTRACE_H_
#include <hilog/log.h>

#define DJVU_DROID "DjvuDroidNativeCodec"
#define DJVU_DOMAIN 0x6610

#define DEBUG_PRINT(fmt, ...) OH_LOG_Print(LOG_APP, LOG_DEBUG, DJVU_DOMAIN, DJVU_DROID, fmt, ##__VA_ARGS__)
#define DEBUG_WRITE(str)     OH_LOG_Print(LOG_APP, LOG_DEBUG, DJVU_DOMAIN, DJVU_DROID, "%s", str)

#endif /* DJVUDROIDTRACE_H_ */
