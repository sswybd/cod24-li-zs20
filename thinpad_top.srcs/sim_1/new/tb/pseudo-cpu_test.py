# by TA

from TestcaseBase import *
import time
import struct
import binascii


class Testcase(TestcaseBase):
    testLog = ''
    score = 0

    def endTest(self):
        Serial.close()
        self.finish(self.score)

    def onStart(self):
        self.log(f"INFO: CPU test started by user {USERNAME}")

        Reset << 1
        Serial.open(1, baud=115200)
        self.recvBuf = b''

        BaseRAM[::False] = b'\x00'*16*1024  # 16KB zeroed RAM
        # Load the test program (at 0x80000000)
        BaseRAM[::] = TEST_PROGRAM
        Reset << 0

        # Wait for test program running
        time.sleep(0.2)

        # Retrieve 7 word of results (result, rnd, gp, dummy, value*3)
        result = struct.unpack('<I', BaseRAM[0x100: 0x100+4: False])[0]
        self.log(f"INFO: Result at BaseRAM[0x100] = 0x{result:08x}")

        if result == 0x000013ba:
            self.log("INFO: SRAM data match")
            self.score = 0.3
        else:
            self.log(
                f"ERR: SRAM data mismatch, expected 0x000013ba, got 0x{result:08x}")
            self.score = 0
            self.endTest()

        # Wait for UART
        Timer.oneshot(1000)

    # On receiving from serial port
    @Serial
    def on_serial(self, dataBytes):
        self.recvBuf += dataBytes
        self.log(f"INFO: Received {len(dataBytes)} bytes: {dataBytes}")

        if len(self.recvBuf) >= 5:
            -Timer
            if self.recvBuf == b'done!':
                self.log("INFO: UART data match")
                self.score = 0.6
            else:
                self.log(f"ERR: UART data mismatch: Got {self.recvBuf}")
            self.endTest()

    @Timer
    def on_timer(self):
        self.log("Timeout waiting for UART")
        self.endTest()


TEST_PROGRAM = binascii.unhexlify(
    # Source code:
    # https://lab.cs.tsinghua.edu.cn/cod-lab-docs-2022/labs/lab6/overview
    '93020000130340069303000093821200b383720063846200e30a00feb7020080'
    '23a07210b70200100383520013730302e30c03fe130540062380a20003835200'
    '13730302e30c03fe1305f0062380a2000383520013730302e30c03fe1305e006'
    '2380a2000383520013730302e30c03fe130550062380a2000383520013730302'
    'e30c03fe130510022380a20063000000'
)