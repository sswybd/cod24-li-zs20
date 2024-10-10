# by TA

from TestcaseBase import *
import random
import traceback
import time


class Testcase(TestcaseBase):
    nRound = 5
    finishedRound = 0
    roundPassed = 0

    def launchTest(self):
        BaseRAM[:1024] = b'\x00' * 1024   # clear first 1K bytes of BaseRAM
        ExtRAM[:1024:True] = b'\x00' * 1024    # clear first 1K bytes of ExtRAM

        self.start_addr = random.getrandbits(7)
        self.in_baseram = bool(random.getrandbits(1))
        self.wb_start_addr = (0x8000_0000 if self.in_baseram else 0x8040_0000) + self.start_addr * 4
        self.send_data = bytes([random.getrandbits(8) for _ in range(10)])
        self.log(f"## Test round {self.finishedRound} with Addr={self.wb_start_addr:#08x} in {'BaseRAM' if self.in_baseram else 'ExtRAM'}")

        # Set initial memory address (wishbone address)
        DIP << self.wb_start_addr
        ~Reset
        self.recvBuf = b''
        Serial.open(1, baud=115200)
        time.sleep(0.1)

        # Send 10 bytes
        for data in self.send_data:
            Serial << data
            time.sleep(0.001)

        # Wait for receiving data, timeout in 200ms
        Timer.oneshot(2000)
    
    # On receiving from serial port
    @Serial
    def on_serial(self, dataBytes):
        self.recvBuf += dataBytes
        if len(self.recvBuf) >= 10:
            -Timer
            self.nextRound(False)

    @Timer
    def on_timer(self):
        self.nextRound(True)

    def nextRound(self, timeout: bool):
        Serial.close()

        if self.in_baseram:
            # Read the data in BaseRAM
            memData = list(BaseRAM[self.start_addr*4: (self.start_addr+len(self.send_data))*4])
        else:
            # Read the data in ExtRAM
            memData = list(ExtRAM[self.start_addr*4: (self.start_addr+len(self.send_data))*4])
        memData = memData[::4]

        self.log(f"Data Sent:       {list(self.send_data)}")
        self.log(f"Data in {'BaseRAM' if self.in_baseram else 'ExtRAM '}: {memData}")
        self.log(f"Received:        {list(self.recvBuf)} {'(Timeout)' if timeout else ''}")

        # Compare the data
        failed = timeout or self.send_data != self.recvBuf or self.send_data != bytes(memData)
        if failed:
            self.log("FAILED\n")
        else:
            self.roundPassed += 1
            self.log("PASSED\n")

        self.finishedRound += 1
        if self.finishedRound == self.nRound:
            self.finish(self.roundPassed / self.nRound)
            Serial.close()
        else:
            self.launchTest()

    @started
    def initialize(self):
        random.seed(260817)  # deterministic random number
        self.launchTest()