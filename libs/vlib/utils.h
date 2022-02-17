#ifndef _UTILS_H
#define _UTILS_H

#ifndef PACKED
# define PACKED __attribute__((packed))
#endif

#ifndef __cplusplus
# define EXTERN extern
#else // __cplusplus
# define EXTERN extern "C"
#endif // !__cplusplus

#endif // _UTILS_H
