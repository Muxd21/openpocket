/*
 * spawn.h — POSIX spawn stub header for Termux
 * Some native modules expect posix_spawn declarations
 */
#ifndef _TERMUX_SPAWN_H_
#define _TERMUX_SPAWN_H_

#include <sys/types.h>
#include <signal.h>
#include <sched.h>

typedef struct {
    short __flags;
    pid_t __pgrp;
    sigset_t __sd;
    sigset_t __ss;
    struct sched_param __sp;
    int __policy;
    int __pad[16];
} posix_spawnattr_t;

typedef struct {
    int __allocated;
    int __used;
    void *__actions;
    int __pad[16];
} posix_spawn_file_actions_t;

#ifdef __cplusplus
extern "C" {
#endif

int posix_spawn(pid_t *__restrict, const char *__restrict,
                const posix_spawn_file_actions_t *,
                const posix_spawnattr_t *__restrict,
                char *const __restrict[], char *const __restrict[]);

int posix_spawnp(pid_t *__restrict, const char *__restrict,
                 const posix_spawn_file_actions_t *,
                 const posix_spawnattr_t *__restrict,
                 char *const __restrict[], char *const __restrict[]);

int posix_spawnattr_init(posix_spawnattr_t *);
int posix_spawnattr_destroy(posix_spawnattr_t *);
int posix_spawnattr_setflags(posix_spawnattr_t *, short);
int posix_spawnattr_getflags(const posix_spawnattr_t *__restrict, short *__restrict);

int posix_spawn_file_actions_init(posix_spawn_file_actions_t *);
int posix_spawn_file_actions_destroy(posix_spawn_file_actions_t *);

#ifdef __cplusplus
}
#endif

#endif /* _TERMUX_SPAWN_H_ */
