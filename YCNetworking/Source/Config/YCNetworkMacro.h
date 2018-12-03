//
//  YCNetworkMacro.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#ifndef YCNetworkMacro_h
#define YCNetworkMacro_h

static inline BOOL IsEmptyValue(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0)
    ||  ([thing isKindOfClass:[NSNull class]]);
}

#if DEBUG
#define YCNetLog(...) NSLog(__VA_ARGS__)
#else
#define YCNetLog(...) {}
#endif

#define YC_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })
#define YCLock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define YCUnlock() dispatch_semaphore_signal(self->_lock)

#pragma mark - weakify strongify

#if DEBUG
#define yc_keywordify autoreleasepool {}
#else
#define yc_keywordify try {} @catch (...) {}
#endif

#define yc_weakify_(INDEX, CONTEXT, VAR) \
CONTEXT __typeof__(VAR) yc_metamacro_concat(VAR, _weak_) = (VAR);

#define yc_strongify_(INDEX, VAR) \
__strong __typeof__(VAR) VAR = yc_metamacro_concat(VAR, _weak_);

#define yc_weakify(...) \
yc_keywordify \
yc_metamacro_foreach_cxt(yc_weakify_,, __weak, __VA_ARGS__)

#define yc_strongify(...) \
yc_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
yc_metamacro_foreach(yc_strongify_,, __VA_ARGS__) \
_Pragma("clang diagnostic pop")


/**
 * Executes one or more expressions (which may have a void type, such as a call
 * to a function that returns no value) and always returns true.
 */
#define yc_metamacro_exprify(...) \
((__VA_ARGS__), true)

/**
 * Returns a string representation of VALUE after full macro expansion.
 */
#define yc_metamacro_stringify(VALUE) \
yc_metamacro_stringify_(VALUE)

/**
 * Returns A and B concatenated after full macro expansion.
 */
#define yc_metamacro_concat(A, B) \
yc_metamacro_concat_(A, B)

/**
 * Returns the Nth variadic argument (starting from zero). At least
 * N + 1 variadic arguments must be given. N must be between zero and twenty,
 * inclusive.
 */
#define yc_metamacro_at(N, ...) \
yc_metamacro_concat(yc_metamacro_at, N)(__VA_ARGS__)

/**
 * Returns the number of arguments (up to twenty) provided to the macro. At
 * least one argument must be provided.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define yc_metamacro_argcount(...) \
yc_metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
/**
 * Identical to #yc_metamacro_foreach_cxt, except that no CONTEXT argument is
 * given. Only the index and current argument will thus be passed to MACRO.
 */
#define yc_metamacro_foreach(MACRO, SEP, ...) \
yc_metamacro_foreach_cxt(yc_metamacro_foreach_iter, SEP, MACRO, __VA_ARGS__)

/**
 * For each consecutive variadic argument (up to twenty), MACRO is passed the
 * zero-based index of the current argument, CONTEXT, and then the argument
 * itself. The results of adjoining invocations of MACRO are then separated by
 * SEP.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define yc_metamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
yc_metamacro_concat(yc_metamacro_foreach_cxt, yc_metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * Identical to #yc_metamacro_foreach_cxt. This can be used when the former would
 * fail due to recursive macro expansion.
 */
#define yc_metamacro_foreach_cxt_recursive(MACRO, SEP, CONTEXT, ...) \
yc_metamacro_concat(yc_metamacro_foreach_cxt_recursive, yc_metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * In consecutive order, appends each variadic argument (up to twenty) onto
 * BASE. The resulting concatenations are then separated by SEP.
 *
 * This is primarily useful to manipulate a list of macro invocations into instead
 * invoking a different, possibly related macro.
 */
#define yc_yc_metamacro_foreach_concat(BASE, SEP, ...) \
yc_metamacro_foreach_cxt(yc_metamacro_foreach_concat_iter, SEP, BASE, __VA_ARGS__)
/**
 * Iterates COUNT times, each time invoking MACRO with the current index
 * (starting at zero) and CONTEXT. The results of adjoining invocations of MACRO
 * are then separated by SEP.
 *
 * COUNT must be an integer between zero and twenty, inclusive.
 */
#define yc_metamacro_for_cxt(COUNT, MACRO, SEP, CONTEXT) \
yc_metamacro_concat(yc_metamacro_for_cxt, COUNT)(MACRO, SEP, CONTEXT)

/**
 * Returns the first argument given. At least one argument must be provided.
 *
 * This is useful when implementing a variadic macro, where you may have only
 * one variadic argument, but no way to retrieve it (for example, because \c ...
 * always needs to match at least one argument).
 *
 * @code

 #define varmacro(...) \
 yc_metamacro_head(__VA_ARGS__)

 * @endcode
 */
#define yc_metamacro_head(...) \
yc_metamacro_head_(__VA_ARGS__, 0)

/**
 * Returns every argument except the first. At least two arguments must be
 * provided.
 */
#define yc_metamacro_tail(...) \
yc_metamacro_tail_(__VA_ARGS__)

/**
 * Returns the first N (up to twenty) variadic arguments as a new argument list.
 * At least N variadic arguments must be provided.
 */
#define yc_metamacro_take(N, ...) \
yc_metamacro_concat(yc_metamacro_take, N)(__VA_ARGS__)

/**
 * Removes the first N (up to twenty) variadic arguments from the given argument
 * list. At least N variadic arguments must be provided.
 */
#define yc_metamacro_drop(N, ...) \
yc_metamacro_concat(yc_metamacro_drop, N)(__VA_ARGS__)

/**
 * Decrements VAL, which must be a number between zero and twenty, inclusive.
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define yc_metamacro_dec(VAL) \
yc_metamacro_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

/**
 * Increments VAL, which must be a number between zero and twenty, inclusive.
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define yc_metamacro_inc(VAL) \
yc_metamacro_at(VAL, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21)

/**
 * If A is equal to B, the next argument list is expanded; otherwise, the
 * argument list after that is expanded. A and B must be numbers between zero
 * and twenty, inclusive. Additionally, B must be greater than or equal to A.
 *
 * @code

 // expands to true
 yc_metamacro_if_eq(0, 0)(true)(false)

 // expands to false
 yc_metamacro_if_eq(0, 1)(true)(false)

 * @endcode
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define yc_metamacro_if_eq(A, B) \
yc_metamacro_concat(yc_metamacro_if_eq, A)(B)

/**
 * Identical to #yc_metamacro_if_eq. This can be used when the former would fail
 * due to recursive macro expansion.
 */
#define yc_metamacro_if_eq_recursive(A, B) \
yc_metamacro_concat(yc_metamacro_if_eq_recursive, A)(B)


/**
 * Returns 1 if N is an even number, or 0 otherwise. N must be between zero and
 * twenty, inclusive.
 *
 * For the purposes of this test, zero is considered even.
 */
#define yc_metamacro_is_even(N) \
yc_metamacro_at(N, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1)

/**
 * Returns the logical NOT of B, which must be the number zero or one.
 */
#define yc_metamacro_not(B) \
yc_metamacro_at(B, 1, 0)

// IMPLEMENTATION DETAILS FOLLOW!
// Do not write code that depends on anything below this line.
#define yc_metamacro_stringify_(VALUE) # VALUE
#define yc_metamacro_concat_(A, B) A ## B
#define yc_metamacro_foreach_iter(INDEX, MACRO, ARG) MACRO(INDEX, ARG)
#define yc_metamacro_head_(FIRST, ...) FIRST
#define yc_metamacro_tail_(FIRST, ...) __VA_ARGS__
#define yc_metamacro_consume_(...)
#define yc_metamacro_expand_(...) __VA_ARGS__

// implemented from scratch so that yc_metamacro_concat() doesn't end up nesting
#define yc_metamacro_foreach_concat_iter(INDEX, BASE, ARG) yc_metamacro_foreach_concat_iter_(BASE, ARG)
#define yc_metamacro_foreach_concat_iter_(BASE, ARG) BASE ## ARG


// yc_metamacro_at expansions
#define yc_metamacro_at0(...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at1(_0, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at2(_0, _1, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at3(_0, _1, _2, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at4(_0, _1, _2, _3, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at5(_0, _1, _2, _3, _4, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at6(_0, _1, _2, _3, _4, _5, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at7(_0, _1, _2, _3, _4, _5, _6, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) yc_metamacro_head(__VA_ARGS__)

// yc_metamacro_foreach_cxt expansions
#define yc_metamacro_foreach_cxt0(MACRO, SEP, CONTEXT)
#define yc_metamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define yc_metamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
yc_metamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) \
SEP \
MACRO(1, CONTEXT, _1)

#define yc_metamacro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
yc_metamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
SEP \
MACRO(2, CONTEXT, _2)

#define yc_metamacro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
yc_metamacro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
SEP \
MACRO(3, CONTEXT, _3)

#define yc_metamacro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
yc_metamacro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
SEP \
MACRO(4, CONTEXT, _4)

#define yc_metamacro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
yc_metamacro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
SEP \
MACRO(5, CONTEXT, _5)

#define yc_metamacro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
yc_metamacro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
SEP \
MACRO(6, CONTEXT, _6)

#define yc_metamacro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
yc_metamacro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
SEP \
MACRO(7, CONTEXT, _7)

#define yc_metamacro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
yc_metamacro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
SEP \
MACRO(8, CONTEXT, _8)

#define yc_metamacro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
yc_metamacro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
SEP \
MACRO(9, CONTEXT, _9)

#define yc_metamacro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
yc_metamacro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
SEP \
MACRO(10, CONTEXT, _10)

#define yc_metamacro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
yc_metamacro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
SEP \
MACRO(11, CONTEXT, _11)

#define yc_metamacro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
yc_metamacro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
SEP \
MACRO(12, CONTEXT, _12)

#define yc_metamacro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
yc_metamacro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
SEP \
MACRO(13, CONTEXT, _13)


#define yc_metamacro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
yc_metamacro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
SEP \
MACRO(14, CONTEXT, _14)

#define yc_metamacro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
yc_metamacro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
SEP \
MACRO(15, CONTEXT, _15)

#define yc_metamacro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
yc_metamacro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
SEP \
MACRO(16, CONTEXT, _16)

#define yc_metamacro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
yc_metamacro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
SEP \
MACRO(17, CONTEXT, _17)

#define yc_metamacro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
yc_metamacro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
SEP \
MACRO(18, CONTEXT, _18)

#define yc_metamacro_foreach_cxt20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
yc_metamacro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
SEP \
MACRO(19, CONTEXT, _19)

// yc_metamacro_foreach_cxt_recursive expansions
#define yc_metamacro_foreach_cxt_recursive0(MACRO, SEP, CONTEXT)
#define yc_metamacro_foreach_cxt_recursive1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define yc_metamacro_foreach_cxt_recursive2(MACRO, SEP, CONTEXT, _0, _1) \
yc_metamacro_foreach_cxt_recursive1(MACRO, SEP, CONTEXT, _0) \
SEP \
MACRO(1, CONTEXT, _1)

#define yc_metamacro_foreach_cxt_recursive3(MACRO, SEP, CONTEXT, _0, _1, _2) \
yc_metamacro_foreach_cxt_recursive2(MACRO, SEP, CONTEXT, _0, _1) \
SEP \
MACRO(2, CONTEXT, _2)

#define yc_metamacro_foreach_cxt_recursive4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
yc_metamacro_foreach_cxt_recursive3(MACRO, SEP, CONTEXT, _0, _1, _2) \
SEP \
MACRO(3, CONTEXT, _3)

#define yc_metamacro_foreach_cxt_recursive5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
yc_metamacro_foreach_cxt_recursive4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
SEP \
MACRO(4, CONTEXT, _4)

#define yc_metamacro_foreach_cxt_recursive6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
yc_metamacro_foreach_cxt_recursive5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
SEP \
MACRO(5, CONTEXT, _5)

#define yc_metamacro_foreach_cxt_recursive7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
yc_metamacro_foreach_cxt_recursive6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
SEP \
MACRO(6, CONTEXT, _6)

#define yc_metamacro_foreach_cxt_recursive8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
yc_metamacro_foreach_cxt_recursive7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
SEP \
MACRO(7, CONTEXT, _7)

#define yc_metamacro_foreach_cxt_recursive9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
yc_metamacro_foreach_cxt_recursive8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
SEP \
MACRO(8, CONTEXT, _8)

#define yc_metamacro_foreach_cxt_recursive10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
yc_metamacro_foreach_cxt_recursive9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
SEP \
MACRO(9, CONTEXT, _9)

#define yc_metamacro_foreach_cxt_recursive11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
yc_metamacro_foreach_cxt_recursive10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
SEP \
MACRO(10, CONTEXT, _10)

#define yc_metamacro_foreach_cxt_recursive12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
yc_metamacro_foreach_cxt_recursive11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
SEP \
MACRO(11, CONTEXT, _11)

#define yc_metamacro_foreach_cxt_recursive13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
yc_metamacro_foreach_cxt_recursive12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
SEP \
MACRO(12, CONTEXT, _12)

#define yc_metamacro_foreach_cxt_recursive14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
yc_metamacro_foreach_cxt_recursive13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
SEP \
MACRO(13, CONTEXT, _13)

#define yc_metamacro_foreach_cxt_recursive15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
yc_metamacro_foreach_cxt_recursive14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
SEP \
MACRO(14, CONTEXT, _14)

#define yc_metamacro_foreach_cxt_recursive16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
yc_metamacro_foreach_cxt_recursive15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
SEP \
MACRO(15, CONTEXT, _15)

#define yc_metamacro_foreach_cxt_recursive17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
yc_metamacro_foreach_cxt_recursive16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
SEP \
MACRO(16, CONTEXT, _16)

#define yc_metamacro_foreach_cxt_recursive18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
yc_metamacro_foreach_cxt_recursive17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
SEP \
MACRO(17, CONTEXT, _17)

#define yc_metamacro_foreach_cxt_recursive19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
yc_metamacro_foreach_cxt_recursive18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
SEP \
MACRO(18, CONTEXT, _18)

#define yc_metamacro_foreach_cxt_recursive20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
yc_metamacro_foreach_cxt_recursive19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
SEP \
MACRO(19, CONTEXT, _19)

// yc_metamacro_for_cxt expansions
#define yc_metamacro_for_cxt0(MACRO, SEP, CONTEXT)
#define yc_metamacro_for_cxt1(MACRO, SEP, CONTEXT) MACRO(0, CONTEXT)

#define yc_metamacro_for_cxt2(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt1(MACRO, SEP, CONTEXT) \
SEP \
MACRO(1, CONTEXT)

#define yc_metamacro_for_cxt3(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt2(MACRO, SEP, CONTEXT) \
SEP \
MACRO(2, CONTEXT)

#define yc_metamacro_for_cxt4(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt3(MACRO, SEP, CONTEXT) \
SEP \
MACRO(3, CONTEXT)

#define yc_metamacro_for_cxt5(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt4(MACRO, SEP, CONTEXT) \
SEP \
MACRO(4, CONTEXT)

#define yc_metamacro_for_cxt6(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt5(MACRO, SEP, CONTEXT) \
SEP \
MACRO(5, CONTEXT)

#define yc_metamacro_for_cxt7(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt6(MACRO, SEP, CONTEXT) \
SEP \
MACRO(6, CONTEXT)

#define yc_metamacro_for_cxt8(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt7(MACRO, SEP, CONTEXT) \
SEP \
MACRO(7, CONTEXT)

#define yc_metamacro_for_cxt9(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt8(MACRO, SEP, CONTEXT) \
SEP \
MACRO(8, CONTEXT)

#define yc_metamacro_for_cxt10(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt9(MACRO, SEP, CONTEXT) \
SEP \
MACRO(9, CONTEXT)

#define yc_metamacro_for_cxt11(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt10(MACRO, SEP, CONTEXT) \
SEP \
MACRO(10, CONTEXT)

#define yc_metamacro_for_cxt12(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt11(MACRO, SEP, CONTEXT) \
SEP \
MACRO(11, CONTEXT)

#define yc_metamacro_for_cxt13(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt12(MACRO, SEP, CONTEXT) \
SEP \
MACRO(12, CONTEXT)

#define yc_metamacro_for_cxt14(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt13(MACRO, SEP, CONTEXT) \
SEP \
MACRO(13, CONTEXT)

#define yc_metamacro_for_cxt15(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt14(MACRO, SEP, CONTEXT) \
SEP \
MACRO(14, CONTEXT)

#define yc_metamacro_for_cxt16(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt15(MACRO, SEP, CONTEXT) \
SEP \
MACRO(15, CONTEXT)

#define yc_metamacro_for_cxt17(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt16(MACRO, SEP, CONTEXT) \
SEP \
MACRO(16, CONTEXT)

#define yc_metamacro_for_cxt18(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt17(MACRO, SEP, CONTEXT) \
SEP \
MACRO(17, CONTEXT)

#define yc_metamacro_for_cxt19(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt18(MACRO, SEP, CONTEXT) \
SEP \
MACRO(18, CONTEXT)

#define yc_metamacro_for_cxt20(MACRO, SEP, CONTEXT) \
yc_metamacro_for_cxt19(MACRO, SEP, CONTEXT) \
SEP \
MACRO(19, CONTEXT)

// yc_metamacro_if_eq expansions
#define yc_metamacro_if_eq0(VALUE) \
yc_metamacro_concat(yc_metamacro_if_eq0_, VALUE)

#define yc_metamacro_if_eq0_0(...) __VA_ARGS__ yc_metamacro_consume_
#define yc_metamacro_if_eq0_1(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_2(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_3(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_4(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_5(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_6(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_7(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_8(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_9(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_10(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_11(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_12(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_13(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_14(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_15(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_16(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_17(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_18(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_19(...) yc_metamacro_expand_
#define yc_metamacro_if_eq0_20(...) yc_metamacro_expand_

#define yc_metamacro_if_eq1(VALUE) yc_metamacro_if_eq0(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq2(VALUE) yc_metamacro_if_eq1(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq3(VALUE) yc_metamacro_if_eq2(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq4(VALUE) yc_metamacro_if_eq3(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq5(VALUE) yc_metamacro_if_eq4(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq6(VALUE) yc_metamacro_if_eq5(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq7(VALUE) yc_metamacro_if_eq6(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq8(VALUE) yc_metamacro_if_eq7(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq9(VALUE) yc_metamacro_if_eq8(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq10(VALUE) yc_metamacro_if_eq9(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq11(VALUE) yc_metamacro_if_eq10(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq12(VALUE) yc_metamacro_if_eq11(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq13(VALUE) yc_metamacro_if_eq12(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq14(VALUE) yc_metamacro_if_eq13(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq15(VALUE) yc_metamacro_if_eq14(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq16(VALUE) yc_metamacro_if_eq15(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq17(VALUE) yc_metamacro_if_eq16(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq18(VALUE) yc_metamacro_if_eq17(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq19(VALUE) yc_metamacro_if_eq18(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq20(VALUE) yc_metamacro_if_eq19(yc_metamacro_dec(VALUE))

// yc_metamacro_if_eq_recursive expansions
#define yc_metamacro_if_eq_recursive0(VALUE) \
yc_metamacro_concat(yc_metamacro_if_eq_recursive0_, VALUE)

#define yc_metamacro_if_eq_recursive0_0(...) __VA_ARGS__ yc_metamacro_consume_
#define yc_metamacro_if_eq_recursive0_1(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_2(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_3(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_4(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_5(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_6(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_7(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_8(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_9(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_10(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_11(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_12(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_13(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_14(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_15(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_16(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_17(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_18(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_19(...) yc_metamacro_expand_
#define yc_metamacro_if_eq_recursive0_20(...) yc_metamacro_expand_

#define yc_metamacro_if_eq_recursive1(VALUE) yc_metamacro_if_eq_recursive0(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive2(VALUE) yc_metamacro_if_eq_recursive1(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive3(VALUE) yc_metamacro_if_eq_recursive2(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive4(VALUE) yc_metamacro_if_eq_recursive3(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive5(VALUE) yc_metamacro_if_eq_recursive4(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive6(VALUE) yc_metamacro_if_eq_recursive5(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive7(VALUE) yc_metamacro_if_eq_recursive6(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive8(VALUE) yc_metamacro_if_eq_recursive7(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive9(VALUE) yc_metamacro_if_eq_recursive8(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive10(VALUE) yc_metamacro_if_eq_recursive9(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive11(VALUE) yc_metamacro_if_eq_recursive10(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive12(VALUE) yc_metamacro_if_eq_recursive11(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive13(VALUE) yc_metamacro_if_eq_recursive12(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive14(VALUE) yc_metamacro_if_eq_recursive13(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive15(VALUE) yc_metamacro_if_eq_recursive14(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive16(VALUE) yc_metamacro_if_eq_recursive15(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive17(VALUE) yc_metamacro_if_eq_recursive16(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive18(VALUE) yc_metamacro_if_eq_recursive17(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive19(VALUE) yc_metamacro_if_eq_recursive18(yc_metamacro_dec(VALUE))
#define yc_metamacro_if_eq_recursive20(VALUE) yc_metamacro_if_eq_recursive19(yc_metamacro_dec(VALUE))

// yc_metamacro_take expansions
#define yc_metamacro_take0(...)
#define yc_metamacro_take1(...) yc_metamacro_head(__VA_ARGS__)
#define yc_metamacro_take2(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take1(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take3(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take2(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take4(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take3(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take5(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take4(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take6(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take5(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take7(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take6(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take8(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take7(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take9(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take8(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take10(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take9(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take11(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take10(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take12(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take11(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take13(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take12(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take14(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take13(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take15(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take14(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take16(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take15(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take17(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take16(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take18(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take17(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take19(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take18(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_take20(...) yc_metamacro_head(__VA_ARGS__), yc_metamacro_take19(yc_metamacro_tail(__VA_ARGS__))

// yc_metamacro_drop expansions
#define yc_metamacro_drop0(...) __VA_ARGS__
#define yc_metamacro_drop1(...) yc_metamacro_tail(__VA_ARGS__)
#define yc_metamacro_drop2(...) yc_metamacro_drop1(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop3(...) yc_metamacro_drop2(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop4(...) yc_metamacro_drop3(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop5(...) yc_metamacro_drop4(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop6(...) yc_metamacro_drop5(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop7(...) yc_metamacro_drop6(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop8(...) yc_metamacro_drop7(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop9(...) yc_metamacro_drop8(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop10(...) yc_metamacro_drop9(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop11(...) yc_metamacro_drop10(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop12(...) yc_metamacro_drop11(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop13(...) yc_metamacro_drop12(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop14(...) yc_metamacro_drop13(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop15(...) yc_metamacro_drop14(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop16(...) yc_metamacro_drop15(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop17(...) yc_metamacro_drop16(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop18(...) yc_metamacro_drop17(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop19(...) yc_metamacro_drop18(yc_metamacro_tail(__VA_ARGS__))
#define yc_metamacro_drop20(...) yc_metamacro_drop19(yc_metamacro_tail(__VA_ARGS__))

#endif /* YCNetworkMacro_h */
