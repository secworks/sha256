#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#=======================================================================
#
# sha256.py
# ---------
# Simple, pure Python model of the SHA-256 hash function. Used as a
# reference for the HW implementation. The code follows the structure
# of the HW implementation as much as possible.
#
#
# Author: Joachim Strömbergson
# Copyright (c) 2013 Secworks Sweden AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#=======================================================================

#-------------------------------------------------------------------
# Python module imports.
#-------------------------------------------------------------------
import sys


#-------------------------------------------------------------------
# Constants.
#-------------------------------------------------------------------
VERBOSE = True
HUGE = False

#-------------------------------------------------------------------
# SHA256()
#-------------------------------------------------------------------
class SHA256():
    def __init__(self, mode="sha256", verbose = 0):
        if mode not in ["sha224", "sha256"]:
            print("Error: Given %s is not a supported mode." % mode)
            return 0

        self.mode = mode
        self.verbose = verbose
        self.H = [0] * 8
        self.t1 = 0
        self.t2 = 0
        self.a = 0
        self.b = 0
        self.c = 0
        self.d = 0
        self.e = 0
        self.f = 0
        self.g = 0
        self.h = 0
        self.w = 0
        self.W = [0] * 16
        self.k = 0
        self.K = [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
                  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
                  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
                  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
                  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
                  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
                  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
                  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
                  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
                  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
                  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
                  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
                  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
                  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
                  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
                  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]


    def init(self):
        if self.mode == "sha256":
            self.H = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]
        else:
            self.H = [0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939,
                      0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4]

    def next(self, block):
        self._W_schedule(block)
        self._copy_digest()
        if self.verbose:
            print("State after init:")
            self._print_state(0)

        for i in range(64):
            self._sha256_round(i)
            if self.verbose:
                self._print_state(i)

        self._update_digest()


    def get_digest(self):
        return self.H


    def _copy_digest(self):
        self.a = self.H[0]
        self.b = self.H[1]
        self.c = self.H[2]
        self.d = self.H[3]
        self.e = self.H[4]
        self.f = self.H[5]
        self.g = self.H[6]
        self.h = self.H[7]


    def _update_digest(self):
        self.H[0] = (self.H[0] + self.a) & 0xffffffff
        self.H[1] = (self.H[1] + self.b) & 0xffffffff
        self.H[2] = (self.H[2] + self.c) & 0xffffffff
        self.H[3] = (self.H[3] + self.d) & 0xffffffff
        self.H[4] = (self.H[4] + self.e) & 0xffffffff
        self.H[5] = (self.H[5] + self.f) & 0xffffffff
        self.H[6] = (self.H[6] + self.g) & 0xffffffff
        self.H[7] = (self.H[7] + self.h) & 0xffffffff


    def _print_state(self, round):
        print("State at round 0x%02x:" % round)
        print("t1 = 0x%08x, t2 = 0x%08x" % (self.t1, self.t2))
        print("k  = 0x%08x, w  = 0x%08x" % (self.k, self.w))
        print("a  = 0x%08x, b  = 0x%08x" % (self.a, self.b))
        print("c  = 0x%08x, d  = 0x%08x" % (self.c, self.d))
        print("e  = 0x%08x, f  = 0x%08x" % (self.e, self.f))
        print("g  = 0x%08x, h  = 0x%08x" % (self.g, self.h))
        print("")


    def _sha256_round(self, round):
        self.k = self.K[round]
        self.w = self._next_w(round)
        self.t1 = self._T1(self.e, self.f, self.g, self.h, self.k, self.w)
        self.t2 = self._T2(self.a, self.b, self.c)
        self.h = self.g
        self.g = self.f
        self.f = self.e
        self.e = (self.d + self.t1) & 0xffffffff
        self.d = self.c
        self.c = self.b
        self.b = self.a
        self.a = (self.t1 + self.t2) & 0xffffffff


    def _next_w(self, round):
        if (round < 16):
            return self.W[round]

        else:
            tmp_w = (self._delta1(self.W[14]) +
                     self.W[9] +
                     self._delta0(self.W[1]) +
                     self.W[0]) & 0xffffffff
            for i in range(15):
                self.W[i] = self.W[(i+1)]
            self.W[15] = tmp_w
            return tmp_w


    def _W_schedule(self, block):
        for i in range(16):
            self.W[i] = block[i]


    def _Ch(self, x, y, z):
        return (x & y) ^ (~x & z)


    def _Maj(self, x, y, z):
        return (x & y) ^ (x & z) ^ (y & z)

    def _sigma0(self, x):
        return (self._rotr32(x, 2) ^ self._rotr32(x, 13) ^ self._rotr32(x, 22))


    def _sigma1(self, x):
        return (self._rotr32(x, 6) ^ self._rotr32(x, 11) ^ self._rotr32(x, 25))


    def _delta0(self, x):
        return (self._rotr32(x, 7) ^ self._rotr32(x, 18) ^ self._shr32(x, 3))


    def _delta1(self, x):
        return (self._rotr32(x, 17) ^ self._rotr32(x, 19) ^ self._shr32(x, 10))


    def _T1(self, e, f, g, h, k, w):
        return (h + self._sigma1(e) + self._Ch(e, f, g) + k + w) & 0xffffffff


    def _T2(self, a, b, c):
        return (self._sigma0(a) + self._Maj(a, b, c)) & 0xffffffff


    def _rotr32(self, n, r):
        return ((n >> r) | (n << (32 - r))) & 0xffffffff


    def _shr32(self, n, r):
        return (n >> r)


#-------------------------------------------------------------------
# print_digest()
#
# Print the given digest.
#-------------------------------------------------------------------
def print_digest(digest):
    print("0x%08x, 0x%08x, 0x%08x, 0x%08x" %\
          (digest[0], digest[1], digest[2], digest[3]))
    print("0x%08x, 0x%08x, 0x%08x, 0x%08x" %\
          (digest[4], digest[5], digest[6], digest[7]))
    print("")


#-------------------------------------------------------------------
# compare_digests()
#
# Check that the given digest matches the expected digest.
#-------------------------------------------------------------------
def compare_digests(digest, expected, length = 8):
    correct = True
    for i in range(length):
        if digest[i] != expected[i]:
            correct = False

    if (not correct):
        print("Error:")
        print("Got:")
        print_digest(digest)
        print("Expected:")
        print_digest(expected)

    else:
        print("Test case ok.")


#-------------------------------------------------------------------
# sha224_tests()
#
# Tests for the SHA224 mode.
#-------------------------------------------------------------------
def sha224_tests():
    print("Running test cases for SHA224:")
    my_sha224 = SHA256(mode="sha224", verbose=0)

    # TC1: NIST testcase with message "abc"
    print("TC1: Single block message test specified by NIST.")
    TC1_block = [0x61626380, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000018]

    TC1_expected = [0x23097D22, 0x3405D822, 0x8642A477, 0xBDA255B3,
                    0x2AADBCE4, 0xBDA0B3F7, 0xE36C9DA7]

    my_sha224.init()
    my_sha224.next(TC1_block)
    my_digest = my_sha224.get_digest()
    compare_digests(my_digest, TC1_expected, 7)
    print("")


    # TC2: NIST testcase with double block message."
    print("TC2: Double block message test specified by NIST.")
    TC2_1_block = [0x61626364, 0x62636465, 0x63646566, 0x64656667,
                   0x65666768, 0x66676869, 0x6768696A, 0x68696A6B,
                   0x696A6B6C, 0x6A6B6C6D, 0x6B6C6D6E, 0x6C6D6E6F,
                   0x6D6E6F70, 0x6E6F7071, 0x80000000, 0x00000000]


    TC2_2_block = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                   0x00000000, 0x00000000, 0x00000000, 0x00000000,
                   0x00000000, 0x00000000, 0x00000000, 0x00000000,
                   0x00000000, 0x00000000, 0x00000000, 0x000001C0]

    TC2_1_expected = [0x8250e65d, 0xbcf62f84, 0x66659c33, 0x33e5e91a,
                      0x10c8b7b0, 0x95392769, 0x1f1419c2]

    TC2_2_expected = [0x75388b16, 0x512776cc, 0x5dba5da1, 0xfd890150,
                      0xb0c6455c, 0xb4f58b19, 0x52522525]


    my_sha224.init()
    my_sha224.next(TC2_1_block)
    my_digest = my_sha224.get_digest()
    compare_digests(my_digest, TC2_1_expected, 7)

    my_sha224.next(TC2_2_block)
    my_digest = my_sha224.get_digest()
    compare_digests(my_digest, TC2_2_expected, 7)
    print("")


    if (HUGE):
        # TC3: Huge message with n blocks
        n = 1000
        print("TC3: Huge message with %d blocks test case." % n)
        TC3_block = [0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f,
                    0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f,
                    0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f,
                    0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f]

        TC3_expected = [0x7638f3bc, 0x500dd1a6, 0x586dd4d0, 0x1a1551af,
                        0xd821d235, 0x2f919e28, 0xd5842fab, 0x03a40f2a]

        my_sha224.init()
        for i in range(n):
            my_sha224.next(TC3_block)
        my_digest = my_sha224.get_digest()
        if (VERBOSE):
            print("Digest for block %d:" % i)
            print_digest(my_digest)
        compare_digests(my_digest, TC3_expected)
        print("")


#-------------------------------------------------------------------
# sha256_tests()
#
# Tests for the SHA256 mode.
#-------------------------------------------------------------------
def sha256_tests():
    print("Running test cases for SHA256:")
    my_sha256 = SHA256(verbose=0)

    # TC1: NIST testcase with message "abc"
    print("TC1: Single block message test specified by NIST.")
    TC1_block = [0x61626380, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                 0x00000000, 0x00000000, 0x00000000, 0x00000018]

    TC1_expected = [0xBA7816BF, 0x8F01CFEA, 0x414140DE, 0x5DAE2223,
                    0xB00361A3, 0x96177A9C, 0xB410FF61, 0xF20015AD]

    my_sha256.init()
    my_sha256.next(TC1_block)
    my_digest = my_sha256.get_digest()
    compare_digests(my_digest, TC1_expected)
    print("")


    # TC2: NIST testcase with double block message."
    print("TC2: Double block message test specified by NIST.")
    TC2_1_block = [0x61626364, 0x62636465, 0x63646566, 0x64656667,
                   0x65666768, 0x66676869, 0x6768696A, 0x68696A6B,
                   0x696A6B6C, 0x6A6B6C6D, 0x6B6C6D6E, 0x6C6D6E6F,
                   0x6D6E6F70, 0x6E6F7071, 0x80000000, 0x00000000]


    TC2_2_block = [0x00000000, 0x00000000, 0x00000000, 0x00000000,
                   0x00000000, 0x00000000, 0x00000000, 0x00000000,
                   0x00000000, 0x00000000, 0x00000000, 0x00000000,
                   0x00000000, 0x00000000, 0x00000000, 0x000001C0]

    TC2_1_expected = [0x85E655D6, 0x417A1795, 0x3363376A, 0x624CDE5C,
                      0x76E09589, 0xCAC5F811, 0xCC4B32C1, 0xF20E533A]

    TC2_2_expected = [0x248D6A61, 0xD20638B8, 0xE5C02693, 0x0C3E6039,
                      0xA33CE459, 0x64FF2167, 0xF6ECEDD4, 0x19DB06C1]

    my_sha256.init()
    my_sha256.next(TC2_1_block)
    my_digest = my_sha256.get_digest()
    compare_digests(my_digest, TC2_1_expected)

    my_sha256.next(TC2_2_block)
    my_digest = my_sha256.get_digest()
    compare_digests(my_digest, TC2_2_expected)
    print("")


    if (HUGE):
        # TC3: Huge message with n blocks
        n = 1000
        print("TC3: Huge message with %d blocks test case." % n)
        TC3_block = [0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f,
                    0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f,
                    0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f,
                    0xaa55aa55, 0xdeadbeef, 0x55aa55aa, 0xf00ff00f]

        TC3_expected = [0x7638f3bc, 0x500dd1a6, 0x586dd4d0, 0x1a1551af,
                        0xd821d235, 0x2f919e28, 0xd5842fab, 0x03a40f2a]

        my_sha256.init()
        for i in range(n):
            my_sha256.next(TC3_block)
        my_digest = my_sha256.get_digest()
        if (VERBOSE):
            print("Digest for block %d:" % i)
            print_digest(my_digest)
        compare_digests(my_digest, TC3_expected)
        print("")


#-------------------------------------------------------------------
# main()
#
# If executed tests the ChaCha class using known test vectors.
#-------------------------------------------------------------------
def main():
    print("Testing the SHA-256 Python model.")
    print("---------------------------------")
    print

    sha224_tests()
    sha256_tests()


#-------------------------------------------------------------------
# __name__
# Python thingy which allows the file to be run standalone as
# well as parsed from within a Python interpreter.
#-------------------------------------------------------------------
if __name__=="__main__":
    # Run the main function.
    sys.exit(main())

#=======================================================================
# EOF sha256.py
#=======================================================================
