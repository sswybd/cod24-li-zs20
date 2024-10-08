# by TA

from TestcaseBase import *
import random

NAME = 'lab2'


class Testcase(TestcaseBase):
    '''
    测试流程
    1. 按复位按钮，复位设计
    2. 按 20 次计数按钮，系统判断是否计数正确
    3. 按复位按钮
    4. 随机按 N 次计数按钮，判断计数及复位是否正确
    '''

    def getDpyValue(self):
        dpy = self.getDecodedSegdisp(string=False)
        if dpy == "error":
            return "unknown"
        return f'{dpy[2]:x}'

    def testRound(self, round, clicks, minScore, roundScore):
        self.log(f'[Round{1+round}] Start testing with {clicks} clicks...')

        ~Reset
        value = self.getDpyValue()
        if value != '0':
            self.finish(
                minScore, {'reason': f'[Round{1+round}] DPY reset value 0x{value} is not 0.'})
            return True

        for i in range(clicks):
            expected = f'{i:x}' if i <= 15 else 'f'
            got = self.getDpyValue()
            if expected != got:
                reason = f'[Round{1+round}] Expected DPY 0x{expected} before click {i}, got 0x{got}.'
                self.finish(minScore+roundScore/clicks*i, {'reason': reason})
                return True

            ~Clock

        return False

    def onStart(self):
        self.log('Start testing...')
        if self.testRound(1, 20, 0, 0.3):
            return True

        for round in range(5):
            click = random.randint(0, 25)
            if self.testRound(round+1, click, 0.3+round/10, 0.1):
                return True

        self.log('[Final] Testing reset...')

        ~Reset
        value = self.getDpyValue()
        if value != '0':
            self.finish(
                0.8, {'reason': f'[Final] DPY reset value 0x{value} is not 0.'})
            return True

        self.finish(1.0, {'reason': 'All tests passed.'})
        return True
    
# result: 100 points