#ifndef INGDIBABACKENDTEST_H
#define INGDIBABACKENDTEST_H

#include <QObject>
#include "src/securitydata/ingdibabackend.h"

class IngDibaBackendTests : public QObject {
    Q_OBJECT

private:
    IngDibaBackend *ingDibaBackend;

private slots:
    void init();
    void testIngConvertTimestampToLocalTimestamp();
    void testIsValidSecurityCategory();
    void testProcessSearchResult();

};

#endif // INGDIBABACKENDTEST_H
