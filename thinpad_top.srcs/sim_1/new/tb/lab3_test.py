# 助教所写

from TestcaseBase import Reset, TestcaseBase
import random
import traceback
import enum
import time

NAME = 'lab3'


class Testcase(TestcaseBase):
    '''
    测试流程
    1. 上电时首先使用 SAVE 初始化全部寄存器数值
    2. 测试脚本随机生成计算指令，执行前、后分别使用 LOAD 读取目标寄存器值
    3. 比较执行后的寄存器值与预期数值，若不一致则测试失败
    '''

    nRegs = 32
    regs = [0 for _ in range(nRegs)]

    @staticmethod
    def rtype_inst(op, rd, rs1, rs2):
        return (rs2 << 20) | (rs1 << 15) | (rd << 7) | (op << 3) | 0b001

    @staticmethod
    def save_inst(rd, imm):
        return (imm << 16) | (rd << 7) | 0b0001_010

    @staticmethod
    def load_inst(rd):
        return (rd << 7) | 0b0010_010

    class ALU_OP(enum.Enum):
        # Operand, Expression
        ADD = (1, lambda a, b: (a + b) & 0xFFFF)
        SUB = (2, lambda a, b: a - b + (0x10000 if a - b < 0 else 0))
        AND = (3, lambda a, b: a & b)
        OR = (4, lambda a, b: a | b)
        XOR = (5, lambda a, b: a ^ b)
        NOT = (6, lambda a, b: 0xFFFF & ~a)
        SLL = (7, lambda a, b: 0xFFFF & (a << (b & 0xF)))
        SRL = (8, lambda a, b: a >> (b & 0xF))
        SRA = (9, lambda a, b: (a >> (b & 0xF)) | (
            (0x10000 - (0x10000 >> (b & 0xF))) if a & 0x8000 else 0))
        ROL = (10, lambda a, b: 0xFFFF & (
            a << (b & 0xF)) | (a >> (16 - (b & 0xF))))

    # check value of a register
    def checkRegValue(self, reg, expected):
        # register 0 is always 0
        if reg == 0:
            expected = 0

        # run LOAD instruction
        inst = self.load_inst(reg)
        self.setAllDIPSwitches(inst)
        self.clickClockButton(1)
        val = self.getLEDBitmask()

        self.log(
            f'checking x{reg}, expected 0x{expected:04x}, actual 0x{val:04x}')

        if val != expected:
            self.log(
                f'ERR: register x{reg} expected 0x{expected:04x} but got 0x{val:04x}')
            return False
        return True

    # write a value to a register
    def writeReg(self, reg, val):
        self.log(f'writing x{reg} = 0x{val:04x}')

        inst = self.save_inst(reg, val)
        self.setAllDIPSwitches(inst)
        self.clickClockButton(1)

    # run test for one random instruction, return score (0-1)
    def runRandomInstr(self):
        op = random.choice(list(self.ALU_OP))
        rd = random.randrange(self.nRegs)
        rs1 = random.randrange(self.nRegs)
        rs2 = random.randrange(self.nRegs)

        inst = self.rtype_inst(op.value[0], rd, rs1, rs2)

        self.log(
            f'\nrunning x{rd} = x{rs1} {op.name} x{rs2}, inst 0x{inst:08x}')

        # check value of rs1 and rs2
        if not self.checkRegValue(rs1, self.regs[rs1]):
            self.log(f'ERR: rs1 x{rs1} mismatch')
            return 0.0

        if not self.checkRegValue(rs2, self.regs[rs2]):
            self.log(f'ERR: rs2 x{rs2} mismatch')
            return 0.0

        self.setAllDIPSwitches(inst)
        self.clickClockButton(1)

        # check value of rd
        expected_rd = op.value[1](self.regs[rs1], self.regs[rs2])
        if not self.checkRegValue(rd, expected_rd):
            self.log(f'ERR: rd x{rd} mismatch')
            return 0.5

        # update register values
        self.regs[rd] = expected_rd

        return 1.0

    score = 0.0
    nRounds = 100

    def onStart(self):
        random.seed(260817)  # reproducible random number for the test

        ~Reset  # reset the design

        # initialize all registers to random values
        # NOTE: we will try to write x0, and expect it to be ignored
        self.log('initializing registers')
        for reg in range(self.nRegs):
            val = random.randrange(0x10000)
            self.writeReg(reg, val)
            self.regs[reg] = val if reg != 0 else 0

        # check all registers once, 0.32 points total
        self.log('\nchecking all registers')
        for reg in range(self.nRegs):
            if self.checkRegValue(reg, self.regs[reg]):
                self.score += 0.01

        # run random instructions, 0.68 points total
        self.log('\nrunning random instructions')
        for _ in range(self.nRounds):
            self.score += self.runRandomInstr() * 0.68 / self.nRounds
        
        if self.score > 0.999:
            self.score = 1.0 # floating point error

        self.log(f'Test finished, score = {self.score:.2f}')
        self.finish(self.score)

# result: 100 points