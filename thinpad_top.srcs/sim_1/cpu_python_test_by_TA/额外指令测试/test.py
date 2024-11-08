from TestcaseBase import *
import random
import traceback
import enum
import time
import struct
import binascii
import os
from timeit import default_timer as timer


class Ins(enum.Flag):
    PCNT = enum.auto()  # popcnt, counts the number of 1 bits in a register
    ANDN = enum.auto()  # rd <= rs1 & ~rs2
    XNOR = enum.auto()  # rd <= rs1 ^ ~rs2
    CLZ = enum.auto()   # counts number of 0 bits at MSB end
    CTZ = enum.auto()   # counts number of 0 bits at LSB end
    PACK = enum.auto()    # packs the XLEN/2-bit lower halves as {rs2, rs1}
    MIN = enum.auto()   # min(rs1, rs2) signed
    MINU = enum.auto()  # min(rs1, rs2) unsigned
    SBSET = enum.auto()  # single bit set
    SBCLR = enum.auto()  # single bit clear


class Testcase(TestcaseBase):
    testLog = ''
    score = 0

    def log(self, s: str):
        self.testLog += s + '\n'

    def endTest(self, err: str = None, details=None):
        if err:
            self.log(err)
        self.finish(self.score, {'reason': self.testLog, 'details': details})

    def onStart(self):
        self.log(f"INFO: CPU test started by user {USERNAME}, group {GROUPNAME}")

        if GROUPNAME not in EXTRA_INSTR_TABLE:
            return self.endTest("This test isn't for you.")
        selection = 0
        result = 0x55555555
        rnd = random.getrandbits(32)
        for i in EXTRA_INSTR_TABLE[GROUPNAME]:
            selection |= i.value
        DIP << 2
        Reset << 1
        ExtRAM[::False] = os.urandom(16*1024) # 16KB random data
        # Load the test program (at 0x80000000)
        BaseRAM[::False] = TEST_PROGRAM
        # Arguments passed to test program (at 0x80100000)
        BaseRAM[0x100000::True] = struct.pack('<III', result, selection, rnd)
        self.log(f"Arguments: {hex(result)} {hex(selection)} {hex(rnd)}")
        Reset << 0
        # Wait for test program running
        time.sleep(0.5)
        # Retrieve results
        n = 4 + len(EXTRA_INSTR_TABLE[GROUPNAME])
        rdata = struct.unpack(
            '<'+'I'*n, BaseRAM[0x100000: 0x100000+n*4: False])
        self.log("Results: " + " ".join([hex(v) for v in rdata]))
        if rdata[1] != selection or rdata[2] != rnd:
            return self.endTest("Values have been accidentally changed.")
        if rdata[0] == result:
            return self.endTest("Test program hasn't been executed.")
        else:
            details = {}
            result = rdata[0] ^ rnd
            if result >> 16 != 0xfeed or result & 0xffff | selection != selection:
                return self.endTest(f"Invalid result code: {result:#08x}")
            rdata = rdata[4:]
            passed = 0
            for i in list(Ins):
                if (result & i.value):
                    self.log(
                        f"Verifying {i.name} (result {hex(rdata[0])}) on server")
                    if VERIFIER[i.value](rnd, rdata[0]):
                        passed |= i.value
                    rdata = rdata[1:]
            for i in EXTRA_INSTR_TABLE[GROUPNAME]:
                ok = int(passed & i.value != 0)
                self.score += ok
                self.log(f"{i.name}: {'PASS' if ok else 'FAIL'}")
                details[i.name] = ok
            self.score /= len(EXTRA_INSTR_TABLE[GROUPNAME])
            self.endTest(details=details)

def clx32(a, c):
    try:
        return f"{a:032b}".index(c)
    except ValueError:
        return 32


def int32(a):
    return (a ^ 0x80000000) - 0x80000000


VERIFIER = {
    Ins.PCNT.value: lambda a, v: v == bin(a).count('1'),
    Ins.ANDN.value: lambda a, v: v == a & 0xFFFF0000,
    Ins.XNOR.value: lambda a, v: v == a ^ 0xFFFF0000,
    Ins.CLZ.value: lambda a, v: v == clx32(a, '1'),
    Ins.CTZ.value: lambda a, v: v == clx32(int('{:032b}'.format(a)[::-1], 2), '1'),
    Ins.PACK.value: lambda a, v: v == 0x55550000 | (a & 0xFFFF),
    Ins.MIN.value: lambda a, v: int32(v) == min(int32(a), int32(0xAAAA5555)),
    Ins.MINU.value: lambda a, v: v == min(a, 0xAAAA5555),
    Ins.SBSET.value: lambda a, v: v == 0xAAAA5555 | (1 << (a & 0x1f)),
    Ins.SBCLR.value: lambda a, v: v == 0xAAAA5555 & ~(1 << (a & 0x1f))
}

TEST_PROGRAM = binascii.unhexlify(
    # Source file: https://gist.github.com/gaoyichuan/71c1acc53bb21ff817c3c1cc9eb84e1d
    '370410809304000083254400032684009301040193f21500638c02023703'
    '0100130303ff131323609303c00063127302130370001313236093033000'
    '631a73001313266023a061009381410093e4140093f22500638e02021303'
    '1000337363409303000063167302130300023373034093030002631e7300'
    '370301001303f3ff3373664023a061009381410093e4240093f245006384'
    '020637c3b2a11303433d334363409303f0ff631a730437c3b2a11303433d'
    '9303f0ff33437340b7c3b2a19383433d631c730237332211130343349303'
    '000033437340b7d3ddee9383b3cb631e7300b70301009383f3ff33437640'
    '23a061009381410093e4440093f28500638c02023703ffff131303609303'
    '000063147302370301001303f3ff1313036093030001631a730013130660'
    '23a061009381410093e4840093f20501638c02023703ffff131313609303'
    '000163147302370301001303f3ff1313136093030000631a730013131660'
    '23a061009381410093e4040193f20502638a02043703ffff130323009303'
    '300033437308b703030093832300631c730213033000b713ffff93832311'
    '33437308b703121193833300631e7300b753aaaa938353553343760823a0'
    '61009381410093e4040293f20504638c020413031000930320003343730a'
    '930310006312730413032000930310003343730a93031000631873021303'
    'f0ff930310003343730a9303f0ff631e73003753aaaa130353553343660a'
    '23a061009381410093e4040493f20508638c020413031000930320003363'
    '730a930310006312730413032000930310003363730a9303100063187302'
    '1303f0ff930310003363730a93031000631e73003753aaaa130353553363'
    '660a23a061009381410093e4040893f20510638e020413030000b70300ff'
    '331373289303100063147304370334129303000233137328b70334129383'
    '130063187302370334129303f00133137328b7033492631e73003753aaaa'
    '130353553313c32823a061009381410093e4041093f20520638002061303'
    'f0ffb70300ff331373489303e0ff63167304370335121303f3ff93030002'
    '33137348b70335129383e3ff63187302370300809303f001331373489303'
    '0000631e73003753aaaa130353553313c34823a061009381410093e40420'
    'b702edfeb3e29200b3c2c20023205400232634006f000000'
)

EXTRA_INSTR_TABLE = {
    "cod24-grp01": [Ins.MIN, Ins.ANDN, Ins.SBCLR],
    "cod24-grp02": [Ins.SBCLR, Ins.CTZ, Ins.XNOR],
    "cod24-grp03": [Ins.XNOR, Ins.PCNT, Ins.CTZ],
    "cod24-grp04": [Ins.PCNT, Ins.SBCLR, Ins.CTZ],
    "cod24-grp05": [Ins.MIN, Ins.MINU, Ins.XNOR],
    "cod24-grp06": [Ins.PACK, Ins.MIN, Ins.CLZ],
    "cod24-grp07": [Ins.PACK, Ins.SBCLR, Ins.XNOR],
    "cod24-grp08": [Ins.PCNT, Ins.SBSET, Ins.CTZ],
    "cod24-grp09": [Ins.PCNT, Ins.MINU, Ins.CLZ],
    "cod24-grp10": [Ins.ANDN, Ins.SBSET, Ins.SBCLR],
    "cod24-grp11": [Ins.CLZ, Ins.CTZ, Ins.SBCLR],
    "cod24-grp12": [Ins.CTZ, Ins.PCNT, Ins.PACK],
    "cod24-grp13": [Ins.SBCLR, Ins.ANDN, Ins.XNOR],
    "cod24-grp14": [Ins.ANDN, Ins.PCNT, Ins.SBCLR],
    "cod24-grp15": [Ins.CTZ, Ins.SBCLR, Ins.MIN],
    "cod24-grp16": [Ins.XNOR, Ins.SBCLR, Ins.MIN],
    "cod24-grp17": [Ins.SBSET, Ins.PACK, Ins.ANDN],
    "cod24-grp18": [Ins.CLZ, Ins.MINU, Ins.SBCLR],
    "cod24-grp19": [Ins.PACK, Ins.PCNT, Ins.ANDN],
    "cod24-grp20": [Ins.XNOR, Ins.CLZ, Ins.SBCLR],
    "cod24-grp21": [Ins.SBSET, Ins.XNOR, Ins.PCNT],
    "cod24-grp22": [Ins.MINU, Ins.XNOR, Ins.MIN],
    "cod24-grp23": [Ins.PCNT, Ins.ANDN, Ins.MINU],
    "cod24-grp24": [Ins.XNOR, Ins.CLZ, Ins.MINU],
    "cod24-grp25": [Ins.CLZ, Ins.ANDN, Ins.MINU],
    "cod24-grp26": [Ins.SBCLR, Ins.SBSET, Ins.PCNT],
    "cod24-grp27": [Ins.ANDN, Ins.PCNT, Ins.CLZ],
    "cod24-grp28": [Ins.MINU, Ins.MIN, Ins.CTZ],
    "cod24-grp29": [Ins.PCNT, Ins.CLZ, Ins.CTZ],
    "cod24-grp30": [Ins.ANDN, Ins.SBCLR, Ins.PACK],
    "cod24-grp31": [Ins.MIN, Ins.PACK, Ins.MINU],
    "cod24-grp32": [Ins.MINU, Ins.XNOR, Ins.PACK],
    "cod24-grp33": [Ins.PCNT, Ins.XNOR, Ins.MIN],
    "cod24-grp34": [Ins.PCNT, Ins.SBSET, Ins.ANDN],
    "cod24-grp35": [Ins.CLZ, Ins.PCNT, Ins.SBCLR],
    "cod24-grp36": [Ins.PCNT, Ins.XNOR, Ins.SBCLR],
    "cod24-grp37": [Ins.PACK, Ins.SBCLR, Ins.CLZ],
    "cod24-grp38": [Ins.CLZ, Ins.MINU, Ins.ANDN],
    "cod24-grp39": [Ins.PACK, Ins.XNOR, Ins.CLZ],
    "cod24-grp40": [Ins.MIN, Ins.CTZ, Ins.MINU],
    "cod24-grp41": [Ins.MINU, Ins.PACK, Ins.XNOR],
    "cod24-grp42": [Ins.SBCLR, Ins.CTZ, Ins.CLZ],
    "cod24-grp43": [Ins.SBCLR, Ins.ANDN, Ins.MINU],
    "cod24-grp44": [Ins.PCNT, Ins.SBCLR, Ins.XNOR],
    "cod24-grp45": [Ins.PACK, Ins.SBSET, Ins.PCNT],
    "cod24-grp46": [Ins.MIN, Ins.SBSET, Ins.ANDN],
    "cod24-grp47": [Ins.MINU, Ins.CLZ, Ins.ANDN],
    "cod24-grp48": [Ins.CTZ, Ins.XNOR, Ins.SBSET],
    "cod24-grp49": [Ins.PCNT, Ins.CLZ, Ins.PACK],
    "cod24-grp50": [Ins.PACK, Ins.MIN, Ins.CTZ],
    "cod24-grp51": [Ins.PACK, Ins.MIN, Ins.XNOR],
    "cod24-grp52": [Ins.XNOR, Ins.CTZ, Ins.PCNT],
    "cod24-grp53": [Ins.CLZ, Ins.SBSET, Ins.MIN],
    "cod24-grp54": [Ins.CLZ, Ins.XNOR, Ins.SBSET],
    "cod24-grp55": [Ins.MIN, Ins.CLZ, Ins.PACK],
    "cod24-grp56": [Ins.CTZ, Ins.SBSET, Ins.SBCLR],
    "cod24-grp57": [Ins.ANDN, Ins.XNOR, Ins.CLZ],
    "cod24-grp58": [Ins.CTZ, Ins.PACK, Ins.MINU],
    "cod24-grp59": [Ins.MINU, Ins.SBSET, Ins.PCNT],
    "cod24-grp60": [Ins.CLZ, Ins.XNOR, Ins.CTZ],
    "cod24-grp61": [Ins.PCNT, Ins.ANDN, Ins.CTZ],
    "cod24-grp62": [Ins.PACK, Ins.MIN, Ins.XNOR],
    "cod24-grp63": [Ins.SBSET, Ins.MIN, Ins.CLZ],
    "cod24-grp64": [Ins.CTZ, Ins.PACK, Ins.CLZ],
    "cod24-grp65": [Ins.PACK, Ins.MIN, Ins.XNOR],
    "cod24-grp66": [Ins.ANDN, Ins.MINU, Ins.PACK],
    "cod24-grp67": [Ins.XNOR, Ins.PACK, Ins.CTZ],
    "cod24-grp68": [Ins.MIN, Ins.MINU, Ins.SBCLR],
    "cod24-grp69": [Ins.CTZ, Ins.MINU, Ins.XNOR],
    "cod24-grp70": [Ins.MINU, Ins.PACK, Ins.SBSET],
    "cod24-grp71": [Ins.MINU, Ins.PCNT, Ins.CTZ],
    "cod24-grp72": [Ins.CLZ, Ins.MIN, Ins.MINU],
    "cod24-grp73": [Ins.CTZ, Ins.PCNT, Ins.SBCLR],
    "cod24-grp74": [Ins.SBCLR, Ins.PACK, Ins.MINU],
    "cod24-grp75": [Ins.XNOR, Ins.CLZ, Ins.PCNT],
    "cod24-grp76": [Ins.ANDN, Ins.MINU, Ins.PCNT],
    "cod24-grp77": [Ins.MIN, Ins.SBCLR, Ins.CTZ],
    "cod24-grp78": [Ins.SBSET, Ins.PCNT, Ins.PACK],
    "cod24-grp79": [Ins.XNOR, Ins.PCNT, Ins.CTZ],
    "cod24-grp80": [Ins.MINU, Ins.CLZ, Ins.PACK],
    "cod24-grp81": [Ins.SBCLR, Ins.CTZ, Ins.MINU],
    "cod24-grp82": [Ins.CTZ, Ins.XNOR, Ins.SBCLR],
    "cod24-grp83": [Ins.CTZ, Ins.CLZ, Ins.SBSET],
    "cod24-grp84": [Ins.XNOR, Ins.PACK, Ins.ANDN],
    "cod24-grp85": [Ins.XNOR, Ins.PACK, Ins.CLZ],
    "cod24-grp86": [Ins.PACK, Ins.SBSET, Ins.MIN],
    "cod24-grp87": [Ins.MIN, Ins.CTZ, Ins.XNOR],
    "cod24-grp88": [Ins.MIN, Ins.XNOR, Ins.MINU],
    "cod24-grp89": [Ins.SBCLR, Ins.MINU, Ins.PCNT],
    "cod24-grp90": [Ins.SBSET, Ins.SBCLR, Ins.MIN],
    "cod24-grp91": [Ins.PCNT, Ins.CTZ, Ins.CLZ],
    "cod24-grp92": [Ins.MINU, Ins.SBCLR, Ins.PACK],
    "cod24-grp93": [Ins.SBCLR, Ins.PACK, Ins.MIN],
    "ta": [Ins.PCNT, Ins.ANDN, Ins.XNOR, Ins.CLZ, Ins.CTZ, Ins.PACK, Ins.MIN, Ins.MINU, Ins.SBSET, Ins.SBCLR]
}