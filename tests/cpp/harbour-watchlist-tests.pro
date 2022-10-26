QT += qml testlib network sql
QT -= gui

CONFIG += c++11 qt

SOURCES += testmain.cpp \
    ingdibabackendtests.cpp

HEADERS += \
    ingdibabackendtests.h

INCLUDEPATH += ../../
include(../../harbour-watchlist.pri)

TARGET = IngDibaBackendTest

DISTFILES += \
    testdata/ie00b57x3v84.json \
    testdata/ing_news.json \
    testdata/divvydiary.json

DEFINES += UNIT_TEST
