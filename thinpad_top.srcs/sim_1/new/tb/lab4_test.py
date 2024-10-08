# by TA

from TestcaseBase import *
from bitarray import bitarray, util
import struct
import random

NAME = 'lab4'

MEM_EMPTY = b'\x00'*4*1024*1024  # 4MB empty memory

class Lfsr():
    def __init__(self, seed=0x0, lfsr_poly=0xea000001, data_width=32):
        self.state = util.int2ba(seed, length=data_width)
        self.state[data_width-1] = 1
        self.lfsr_poly = util.int2ba(lfsr_poly, length=data_width)
        self.data_width = data_width
        self.lfsr_mask_state = [self.data_width *
                                bitarray('0') for i in range(self.data_width)]
        self.init_lfsr_mask()

    def init_lfsr_mask(self):
        for i in range(self.data_width):
            self.lfsr_mask_state[i][i] = 1
        for i in range(self.data_width-1, -1, -1):
            state_val = self.lfsr_mask_state[self.data_width-1]
            for j in range(1, self.data_width):
                if self.lfsr_poly[self.data_width-j-1]:
                    state_val = self.lfsr_mask_state[j-1] ^ state_val
            for j in range(self.data_width-1, -1, -1):
                self.lfsr_mask_state[j] = self.lfsr_mask_state[j-1]
            self.lfsr_mask_state[0] = state_val
        for i in range(self.data_width//2):
            state_val = self.lfsr_mask_state[i]
            self.lfsr_mask_state[i] = self.lfsr_mask_state[self.data_width-i-1]
            self.lfsr_mask_state[self.data_width-i-1] = state_val

    def gen_data(self):
        data_out = self.data_width*bitarray('0')
        for i in range(self.data_width):
            if ((self.state & self.lfsr_mask_state[i]).count(1)) % 2 == 0:
                data_out[i] = 0
            else:
                data_out[i] = 1
        self.state = data_out
        data_out.reverse()
        return util.ba2int(data_out)


class Testcase(TestcaseBase):
    '''
    测试流程
    1. 按复位按钮，复位设计
    2. 在拨码开关上设置一个随机数种子，按开始测试按钮
    3. 等待一段时间，读取 sram_tester 返回的 LED 状态
    4. 生成与 sram_tester 一致的随机序列，读取 SRAM 中的数据，判断是否正确
    '''

    seed = 1
    lfsr_data = None
    lfsr_addr = None

    nRounds = 1000
    nErrors = 0

    @staticmethod
    def _calc_mask(addr: int):
        offset = addr % 4
        masks = [0xffffffff, 0x0000ff00, 0xffff0000, 0xff000000]
        return masks[offset]

    def onStart(self):
        self.seed = 0x0001  # fixed seed for easy debugging
        self.log(f'Start lab4 test with seed 0x{self.seed:08x}')

        # Initialize SRAM with all zeros
        BaseRAM[:] = MEM_EMPTY
        ExtRAM[::True] = MEM_EMPTY

        # Initialize LFSR
        self.lfsr_data = Lfsr(seed=self.seed, lfsr_poly=0xea000001, data_width=32)
        self.lfsr_data.gen_data()   # skip first data
        self.lfsr_addr = Lfsr(seed=self.seed & 0x7fffff, lfsr_poly=0x40001, data_width=23)
        self.lfsr_addr.gen_data()   # skip first data

        # Set seed on switches and reset design
        self.setAllDIPSwitches(self.seed)
        ~Reset
        time.sleep(0.01)

        if LED[0] == 1 or LED[1] == 1:
            self.log('ERR: Reset failed, done or error LED is on')
            self.finish(0.0)
            return

        # Press push_btn, start test
        ~Clock
        time.sleep(0.1)

        # Read LED status
        if LED[1] == 1:
            self.log('ERR: SRAM Tester reported error on LED')
            self.finish(0.1)
            return

        if LED[0] == 0:
            self.log('ERR: SRAM Tester not finished')
            self.finish(0.1)
            return

        # Read SRAM data
        self.log('SRAM Tester finished, reading SRAM data')
        memArray = list(BaseRAM[:BaseRAM.cap:False]) + list(ExtRAM[:ExtRAM.cap:False])
        for i in range(self.nRounds):
            addr = self.lfsr_addr.gen_data()
            mask = self._calc_mask(addr)
            _addr = addr & 0xfffffffc   # 32-bit aligned
            data = self.lfsr_data.gen_data()
            read_data = struct.unpack('<I', bytearray(memArray[_addr:_addr+4]))[0]
            if (read_data & mask) != (data & mask):
                if self.nErrors < 20:
                    self.log(
                        f'ERR: [Round {i}] SRAM data mismatch at address 0x{0x8000_0000+addr:08x}, expected 0x{data:08x}, got 0x{read_data:08x} (mask 0x{mask:08x})')

                self.nErrors += 1
        
        if self.nErrors >= 20:
            self.log(f'ERR: {self.nErrors} errors found, only first 20 are shown')
        
        if self.nErrors == 0:
            self.log('PASS: All SRAM data correct')
            self.finish(1.0)
        else:
            self.log(f'FAIL: {self.nErrors} errors found in SRAM data')
            score = 0.2 + 0.8 * (self.nRounds - self.nErrors) / self.nRounds
            self.finish(score)
