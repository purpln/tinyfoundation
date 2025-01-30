#pragma once

#include <errno.h>
#include <fcntl.h>
#include <wasi/libc-environ.h>

static inline int32_t _getConst_O_ACCMODE(void) { return O_ACCMODE; }
static inline int32_t _getConst_O_APPEND(void) { return O_APPEND; }
static inline int32_t _getConst_O_CREAT(void) { return O_CREAT; }
static inline int32_t _getConst_O_DIRECTORY(void) { return O_DIRECTORY; }
static inline int32_t _getConst_O_EXCL(void) { return O_EXCL; }
static inline int32_t _getConst_O_NONBLOCK(void) { return O_NONBLOCK; }
static inline int32_t _getConst_O_TRUNC(void) { return O_TRUNC; }
static inline int32_t _getConst_O_WRONLY(void) { return O_WRONLY; }

static inline int32_t _getConst_EWOULDBLOCK(void) { return EWOULDBLOCK; }
static inline int32_t _getConst_EOPNOTSUPP(void) { return EOPNOTSUPP; }

char **environ_wrapper() {
    return __wasilibc_get_environ();
}
