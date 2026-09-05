/*
 * Small libc gaps for the freestanding core build.
 *
 * strcasestr is a GNU extension. The firmware build picks it up from its own
 * libc configuration; a core links -nostdlib against newlib-nano, which does
 * not declare it, and it is not on the ABI. main_msx.c uses it once, to spot
 * "konami" in a ROM name and pick a key mapping.
 */
#pragma once

#include <ctype.h>
#include <stddef.h>

static inline char *msx_strcasestr(const char *haystack, const char *needle)
{
    if (!*needle) return (char *)haystack;

    for (; *haystack; haystack++) {
        const char *h = haystack;
        const char *n = needle;
        while (*h && *n && tolower((unsigned char)*h) == tolower((unsigned char)*n)) {
            h++;
            n++;
        }
        if (!*n) return (char *)haystack;
    }
    return NULL;
}

#define strcasestr msx_strcasestr
