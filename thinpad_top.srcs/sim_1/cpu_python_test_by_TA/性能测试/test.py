#=# oj.resources.kernel_bin = https://cloud.tsinghua.edu.cn/f/2bb118f1c71347ada365/?dl=1
#=# oj.board.n = 5
from TestcaseBase import *
import random
import traceback
import enum
import time
import struct
import base64
import os
from timeit import default_timer as timer


class Testcase(TestcaseBase):
    class State(enum.Enum):
        WaitBoot = enum.auto()
        GetXlen = enum.auto()
        RunG = enum.auto()
        WaitG = enum.auto()
        Done = enum.auto()

    bootMessage = b'MONITOR for RISC-V - initialized.'
    maxRunTime = 30000
    recvBuf = b''

    @staticmethod
    def int2bytes(val):
        return struct.pack('<I', val)

    @staticmethod
    def bytes2int(val):
        return struct.unpack('<I', val)[0]

    def endTest(self, timeout=False):
        elapsed = None
        if self.state in [self.State.WaitBoot, self.State.RunG]:
            score = 0
        elif timeout or self.state == self.State.Done:
            elapsed = timer() - self.time_start
            self.log(
                f"Test {self.utest[0]} run for {elapsed:.3f}s {'(Timeout)' if timeout else ''}")
            score = 1
        else:
            score = 0

        self.finish(score, {
            'details': {
                'name': self.utest[0],
                'max': self.maxRunTime//1000,
                'elapsed': elapsed
            }
        })
        return True

    def stateChange(self, received: bytes):
        if self.state == self.State.WaitBoot:
            bootMsgLen = len(self.bootMessage)
            self.log(f"Boot message: {str(self.recvBuf)[1:]}")
            if received != self.bootMessage:
                self.log('ERROR: incorrect message')
                return self.endTest()
            elif len(self.recvBuf) > bootMsgLen:
                self.log('WARNING: extra bytes received')
            self.recvBuf = b''

            self.state = self.State.GetXlen
            Serial << b'W'
            self.recvBuf = b''
            self.expectedLen = 1

        elif self.state == self.State.GetXlen:
            xlen = received[0]
            if xlen == 4:
                self.log('INFO: running in 32bit, xlen = 4')
                self.recvBuf = b''

                self.state = self.State.RunG
                Serial << b'G'
                Serial << self.int2bytes(self.utest[1])
                self.expectedLen = 1

            elif xlen == 8:
                self.log('INFO: running in 64bit, xlen = 8')
                self.log('ERROR: rv64 is unsupported on online judge')
                return self.endTest()
            elif xlen < 20:
                self.log('ERROR: got unexpected XLEN: {}'.format(xlen))
                return self.endTest()
            else:
                self.recvBuf = b''
                self.expectedLen = 1

        elif self.state == self.State.RunG:
            if received == b'\x80':
                self.log('ERROR: exception occurred')
                return self.endTest()
            elif received != b'\x06':
                self.log('ERROR: start mark should be 0x06')
                return self.endTest()
            self.recvBuf = self.recvBuf[1:]
            self.time_start = timer()
            self.state = self.State.WaitG
            self.expectedLen = 1
            self.setupTimer(self.maxRunTime)  # override timer settings

        elif self.state == self.State.WaitG:
            self.recvBuf = self.recvBuf[1:]
            if received == b'\x80':
                self.log('ERROR: exception occurred')
                return self.endTest()
            elif received == b'\x07':
                self.state = self.State.Done
                return self.endTest()

    @Serial  # On receiving from serial port
    def recv(self, dataBytes):
        self.recvBuf += dataBytes
        while len(self.recvBuf) >= self.expectedLen:
            end = self.stateChange(self.recvBuf[:self.expectedLen])
            if end:
                break

    @Timer
    def timeout(self):
        self.log(f"ERROR: timeout during {self.state.name}")
        self.endTest(True)

    @started
    def initialize(self):
        self.utest = UTEST_ENTRY[IBOARD]
        self.state = self.State.WaitBoot
        self.expectedLen = len(self.bootMessage)
        self.log(f"=== Test {self.utest[0]} ===")
        DIP << 0
        +Reset
        # Write kernel to BaseRAM
        BaseRAM[::False] = base64.b64decode(RESOURCES['kernel_bin'])
        ExtRAM[:] = os.urandom(16*1024) # 16KB random data
        Serial.open(1, baud=115200)
        -Reset
        # booting timeout in 2 seconds
        Timer.oneshot(2000)


MAX_RUN_TIME = 34000

# > make ON_FPGA=y
# 1:80001000 <UTEST_SIMPLE>:
# 2:80001008 <UTEST_1PTB>:
# 3:80001024 <UTEST_2DCT>:
# 4:80001064 <UTEST_3CCT>:
# 5:80001080 <UTEST_4MDCT>:
# 6:800010a8 <UTEST_CRYPTONIGHT>:
UTEST_ENTRY = [('1PTB', 0x80001008),
               ('2DCT', 0x80001024),
               ('3CCT', 0x80001064),
               ('4MDCT', 0x80001080),
               ('CRYPTONIGHT', 0x800010a8)]