QT += qml testlib network sql
QT -= gui

CONFIG += c++11 qt

SOURCES += testmain.cpp \
    watchlisttests.cpp

HEADERS += \
    watchlisttests.h

INCLUDEPATH += ../../
include(../../harbour-watchlist.pri)

TARGET = WatchlistTests

DISTFILES += \
    testdata/ie00b57x3v84.json \
    testdata/ing_news.json \
    testdata/divvydiary.json

DEFINES += UNIT_TEST
