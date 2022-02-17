#ifndef _STDINT_H
#define _STDINT_H

#ifndef _int8_t_defined
#define _int8_t_defined
typedef char int8_t;
#endif // _int8_t_defined
#ifndef _uint8_t_defined
#define _uint8_t_defined
typedef unsigned char uint8_t;
#endif // _uint8_t_defined
#ifndef _int16_t_defined
#define _int16_t_defined
typedef short int16_t;
#endif // _int16_t_defined
#ifndef _uint16_t_defined
#define _uint16_t_defined
typedef unsigned short uint16_t;
#endif // _uint16_t_defined
#ifndef _int32_t_defined
#define _int32_t_defined
typedef int int32_t;
#endif // _int32_t_defined
#ifndef _uint32_t_defined
#define _uint32_t_defined
typedef unsigned int uint32_t;
#endif // _uint32_t_defined
#ifndef _int64_t_defined
#define _int64_t_defined
typedef long long int64_t;
#endif // _int64_t_defined
#ifndef _uint64_t_defined
#define _uint64_t_defined
typedef unsigned long long uint64_t;
#endif // _uint64_t_defined

#ifndef _size_t_defined
#define _size_t_defined
# ifdef __GNUC__
typedef unsigned int size_t;
# else
typedef long unsigned int size_t;
# endif
#endif // _size_t_defined

#ifndef _uintptr_t_defined
#define _uintptr_t_defined
typedef unsigned long uintptr_t;
#endif // _uintptr_t_defined

#ifndef NULL
#define NULL 0
#endif // NULL

#endif // _STDINT_H