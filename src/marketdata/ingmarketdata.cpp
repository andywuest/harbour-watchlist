#include "ingmarketdata.h"

IngMarketData::IngMarketData(const QString extRefId, const QString internalId, const QString indexName) {
    this->extRefId = extRefId;
    this->internalId = internalId;
    this->indexName = indexName;
}

QString IngMarketData::getExtRefId() const {
    return extRefId;
}

QString IngMarketData::getInternalId() const {
    return internalId;
}

QString IngMarketData::getIndexName() const {
    return indexName;
}
