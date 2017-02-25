# -*- coding: utf-8 -*-
from PyQt4 import QtCore, QtGui
#from win32com.client import Dispatch
#import win32com
import time,os

#继承 QThread 类
class BigWorkThread(QtCore.QThread):
    """docstring for BigWorkThread"""
    def __init__(self, file_path = []):
        super(BigWorkThread, self).__init__(None)
        self.path = file_path
    
    def run(self): 
        self.gen_txt_file()
        input = open(u'幅相系数记录.txt','r')
        raw = input.read()
        output = open(u'幅相系数记录.dat','wb+')
        for i in range(len(raw)/2):
            output.write(chr(int(raw[2*i:2*i+2],16)))
            j = int(2*i/len(raw)*100)
            self.emit(QtCore.SIGNAL("where"),j)
        self.emit(QtCore.SIGNAL("finish_show"))
        
    def gen_txt_file(self):
        from win32com.client import Dispatch, constants
        h = Dispatch("Matlab.application")  #打开Matlab进程
        h.Visible = 0  #隐藏Matlab界面
        h.Feval('cd',0,0,os.getcwd())  #Matlab工作路径切换到当前软件目录
        h.Feval('generate',0,0,self.path)  #调用generate.m中的函数，产生txt格式文件