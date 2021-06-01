#ifndef ING_DIBA_BACKEND_TEST_H
#define ING_DIBA_BACKEND_TEST_H

#include <QObject>

#include "src/securitydata/ingdibabackend.h"
#include "src/newsdata/ingdibanews.h"

class IngDibaBackendTests : public QObject {
    Q_OBJECT

private:
    IngDibaBackend *ingDibaBackend;
    IngDibaNews *ingDibaNews;

protected:

    QByteArray readFileData(QString fileName);

private slots:
    void init();

    // ING-DIBA Security Backend
    void testIngDibaBackendConvertTimestampToLocalTimestamp();
    void testIngDibaBackendIsValidSecurityCategory();
    void testIngDibaBackendProcessSearchResult();

    // ING-DIBA News Backend
    void testIngDibaNewsProcessSearchResult();
};

#endif // ING_DIBA_BACKEND_TEST_H
