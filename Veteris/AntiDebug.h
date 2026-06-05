#ifndef MyAntiDebugging_h
#define MyAntiDebugging_h


// Secure EXIT
static
__attribute__((used))
__attribute__((always_inline))
void asm_exit() {
    __asm__ volatile (
                      "mov r0, #0\n"
                      "mov r12, #1\n"
                      "svc #80\n"
                      );
}

// For debugger_ptrace. Ref: https://www.theiphonewiki.com/wiki/Bugging_Debuggers
#import <dlfcn.h>
#import <sys/types.h>

// For debugger_sysctl
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <sys/types.h>
#import <sys/sysctl.h>

// For ioctl
#import <termios.h>
#import <sys/ioctl.h>

// For task_get_exception_ports
#import <mach/task.h>
#import <mach/mach_init.h>

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

/*!
 @brief This is the basic ptrace functionality.
 @link http://www.coredump.gr/articles/ios-anti-debugging-protections-part-1/
 */
NS_INLINE
void debugger_ptrace()
{
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

/*!
 @brief This function uses sysctl to check for attached debuggers.
 @link https://developer.apple.com/library/mac/qa/qa1361/_index.html
 @link http://www.coredump.gr/articles/ios-anti-debugging-protections-part-2/
 */
NS_INLINE
bool debugger_sysctl(void)
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int mib[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    if (sysctl(mib, 4, &info, &info_size, NULL, 0) == -1)
    {
        asm_exit();
    }
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

/* Set platform binary flag */
#define FLAG_PLATFORMIZE (1 << 1)


NS_INLINE
void root_anti_debugging()
{
    
    {
        setuid(0);
        setgid(0);
    }
    
    // If enabled the program should exit with code 055 in GDB
    // Program exited with code 055.
    debugger_ptrace();
    
    // If enabled the program should exit with code 0377 in GDB
    // Program exited with code 0377.
    if (debugger_sysctl())
    {
        asm_exit();
    }
    
    // Another way of calling ptrace.
    // Ref: https://www.theiphonewiki.com/wiki/Kernel_Syscalls
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    syscall(26, 31, 0, 0);
#pragma clang diagnostic pop
    
    // Another way of figuring out if LLDB is attached.
    if (isatty(1)) {
        asm_exit();
    }
    
    // Yet another way of figuring out if LLDB is attached.
    if (!ioctl(1, TIOCGWINSZ)) {
        asm_exit();
    }

    // Everything above relies on libraries. It is easy enough to hook these libraries and return the required
    // result to bypass those checks. So here it is implemented in ARM assembly. Not very fun to bypass these.
    // __asm__ volatile (
    //     "mov r0, #31\n"
    //     "mov r1, #0\n"
    //     "mov r2, #0\n"
    //     "mov r12, #26\n"
    //     "svc #80\n"
    // );
}

#endif  /* MyAntiDebugging_h */
