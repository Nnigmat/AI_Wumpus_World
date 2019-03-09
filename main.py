import sys
from PyQt5 import QtGui, QtCore
from PyQt5.QtWidgets import QWidget, QApplication

class window(QWidget):

    def __init__(self, size):
        super().__init__()

        self.size = size 
        self.initUI()

    def initUI(self): 

        self.windowWidth = 500
        self.windowHeight = 500
        self.resize(self.windowWidth, self.windowHeight)

        self.show()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    w = window(5)
    sys.exit(app.exec_())