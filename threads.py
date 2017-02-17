# -*- coding: utf-8 -*-
from PyQt4 import QtCore, QtGui
import time,os

#继承 QThread 类
class BigWorkThread(QtCore.QThread):
    """docstring for BigWorkThread"""
    def __init__(self, file_path = []):
        super(BigWorkThread, self).__init__(None)
        self.path = file_path
    
    def run(self): 
        input = open(self.path,'r')
        raw = input.read()
        output = open(u'幅相系数记录.dat','wb+')
        for i in range(len(raw)/2):
            output.write(chr(int(raw[2*i:2*i+2],16)))
            j = int(2*i/len(raw)*100)
            self.emit(QtCore.SIGNAL("where"),j)
        self.emit(QtCore.SIGNAL("finish_show"))