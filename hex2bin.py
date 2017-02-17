# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'hex2bin.ui'
#
# Created by: PyQt4 UI code generator 4.11.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui
import sys ,os 
from threads import BigWorkThread

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s 

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_dialog(QtGui.QWidget):
    def setupUi(self, dialog):
        dialog.setFixedSize(400,300)
        dialog.setObjectName(_fromUtf8("dialog"))
        dialog.resize(400, 300)
        dialog.setWindowIcon(QtGui.QIcon('Word.png'))
        self.startButton = QtGui.QPushButton(dialog)
        self.startButton.setGeometry(QtCore.QRect(140, 70, 101, 61))
        self.startButton.setObjectName(_fromUtf8("startButton"))
        self.progressBar = QtGui.QProgressBar(dialog)
        self.progressBar.setEnabled(True)
        self.progressBar.setGeometry(QtCore.QRect(30, 140, 351, 23))
        self.progressBar.setProperty("value", 0)
        self.progressBar.setTextVisible(True)
        self.progressBar.hide()
        self.progressBar.setObjectName(_fromUtf8("progressBar"))
        self.lineEdit = QtGui.QLineEdit(dialog)
        self.lineEdit.setGeometry(QtCore.QRect(30, 30, 251, 20))
        self.lineEdit.setObjectName(_fromUtf8("lineEdit"))
        self.selectButton = QtGui.QPushButton(dialog)
        self.selectButton.setGeometry(QtCore.QRect(290, 30, 91, 23))
        self.selectButton.setObjectName(_fromUtf8("selectButton"))
        self.textBrowser = QtGui.QTextBrowser(dialog)
        self.textBrowser.setGeometry(QtCore.QRect(30, 170, 321, 91))
        self.textBrowser.setObjectName(_fromUtf8("textBrowser"))

        self.retranslateUi(dialog) 
        QtCore.QMetaObject.connectSlotsByName(dialog)
        
        #信号列表：
        QtCore.QObject.connect(self.startButton, QtCore.SIGNAL(_fromUtf8("clicked()")), self.start_update_ui)
        QtCore.QObject.connect(self.selectButton, QtCore.SIGNAL(_fromUtf8("clicked()")), self.showDialog)

    def retranslateUi(self, dialog):
        dialog.setWindowTitle(_translate("dialog", "hex2bin转换软件", None))
        self.startButton.setText(_translate("dialog", "开始转换", None))
        self.selectButton.setText(_translate("dialog", "选择txt文件", None))
        self.textBrowser.setHtml(_translate("dialog", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'SimSun\'; font-size:9pt; font-weight:400; font-style:normal;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-weight:600;\">软件说明：</span></p>\n"
"<p align=\"center\" style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" color:#ff0000;\">***.txt</span><span style=\" color:#0000ff;\">  </span><span style=\" color:#000000;\">==&gt;&gt;</span><span style=\" color:#0000ff;\">   ***.dat</span></p>\n"
"<p align=\"center\" style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">----------------------------------</p>\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">本软件适用于将声纳的十六进制幅相校正悉数文件转换为适用于写入声纳flash中的文件。</p>\n"
"<p align=\"right\" style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\">---Powered by Root_lee</p></body></html>", None))

    #子进程处理数据
    def subprocess(self):
        file_path = str(self.lineEdit.text().toLocal8Bit())
        
        self.bwThread = BigWorkThread(file_path)
        self.connect(self.bwThread,QtCore.SIGNAL("where"),self.update)
        self.connect(self.bwThread,QtCore.SIGNAL("finish_show"),self.finish_show)
        self.bwThread.start()
    def start_update_ui(self):
        self.progressBar.show()  #显示进度条
        #self.label_4.show()   #显示“替换中”文本
        #self.label_5.hide()  #隐藏替换完成按钮 
        #self.pushButton_2.hide()   #隐藏“确定”按钮
        self.startButton.setEnabled(False) #不使能开始按钮
        self.startButton.setText(_translate("dialog", "转换中...", None))  #将按钮改成转换中
        #for progress_value in range(99):
        #    self.progressBar.setProperty("value", progress_value)
        self.subprocess()   #创建新进程     

    #文件打开框        
    def showDialog(self):
        #filename = QtGui.QFileDialog.getExistingDirectory(self, 'Open file','/home')
        filename = QtGui.QFileDialog.getOpenFileName(self, 'Open file','C:',"Text files (*.txt)")
        self.lineEdit.setText("%s" %filename)
    def update(self,where):
        self.progressBar.setProperty("value",where)
    
    def finish_show(self):

        self.startButton.setEnabled(True) #使能开始按钮
        self.progressBar.setProperty("value",100)
        self.startButton.setText(_translate("dialog", "开始转换", None))
        QtGui.QMessageBox.information(self, u'文件转换完成', u'文件已经转换完成！\n<幅相系数记录.dat>文件存放在本软件目录！')
        self.progressBar.hide()
if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    dialog = QtGui.QDialog()
    ui = Ui_dialog()
    ui.setupUi(dialog)
    dialog.show()
    sys.exit(app.exec_())

