// .pragma library

Qt.include("constants.js")
Qt.include('functions.js');

var SORT_BY_NAME_ASC = " name ASC ";
var SORT_BY_CHANGE_ASC = " changeRelative ASC ";
var SORT_BY_CHANGE_DESC = " changeRelative DESC ";

// basic database functions
function getOpenDatabase() {
    var db = LocalStorage.openDatabaseSync(
                "harbour-watchlist", "1.0",
                "Database for the harbour-watchlist!", 10000000)
    return db
}

function executeInsertUpdateDeleteForTable(tableName, query, parameters, successMessage, failureMessage) {
    var result = ""
    try {
        var db = getOpenDatabase()

        var numberOfColumnsInTable = countTableColumns(db, tableName);

        db.transaction(function (tx) {
            tx.executeSql(query, parameters);
        })
        result = qsTr(successMessage);
    } catch (err) {
        result = qsTr(failureMessage);
        console.log(result + err)
    }
    return result
}

function deleteTableEntry(id, tableName) {
    var query = 'DELETE FROM ' + tableName + ' WHERE id = ?';
    var parameters = [id];
    executeInsertUpdateDeleteForTable(tableName, query, parameters, "", "");
    /*
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var result = tx.executeSql('DELETE FROM ' + tableName + ' WHERE id = ?', [id]);
            log("deleted entry with id " + id + " from " + tableName);
        })
    } catch (err) {
        log("Error deleting entry from " + tableName  + " table: " + err)
    }
    */
}

// drops all application tables
function resetApplication() {
    try {
        var db = getOpenDatabase()
        console.log("Dropping all tables of the application!")
        db.transaction(function (tx) {
            tx.executeSql('DROP TABLE IF EXISTS stockdata');
            tx.executeSql('DROP TABLE IF EXISTS watchlist');
            tx.executeSql('DROP TABLE IF EXISTS backend');
            tx.executeSql('DROP TABLE IF EXISTS alarm');
            tx.executeSql('DROP TABLE IF EXISTS marketdata');
        })
    } catch (err) {
        console.log("Error deleting tables for application in database : " + err)
    }
}

// initializes all application tables
function initApplicationTables() {
    try {
        // TODO debug scheint viel zu oft aufgerufen zu werden !!
        var db = getOpenDatabase()
        console.log("Creating all tables of the application if they do not yet exist!")
        db.transaction(function (tx) {
            // backend
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS backend'
                        + ' (id INTEGER, name text NOT NULL, PRIMARY KEY (id))');
            tx.executeSql('INSERT INTO backend (name) VALUES ("Euroinvestor")');
            // watchlist
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS watchlist'
                        + ' (id INTEGER, backendId INTEGER NOT NULL, name text NOT NULL, PRIMARY KEY (id), '
                        + ' FOREIGN KEY(backendId) REFERENCES backend(id))');
            tx.executeSql('INSERT INTO watchlist (name, backendId) VALUES ("DEFAULT", (SELECT id FROM backend WHERE name = "Euroinvestor"))');
            // stockdata - TODO unique constraint (watchlistId, extRefId)
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS stockdata'
                        + ' (id INTEGER, name text, extRefId text NOT NULL, currency text, stockMarketSymbol text, stockMarketName text, '
                        + ' isin text, symbol1 text, symbol2 text, '
                        + ' price real DEFAULT 0.0, changeAbsolute real DEFAULT 0.0, changeRelative real DEFAULT 0.0, '
                        + ' ask real DEFAULT 0.0, bid real DEFAULT 0.0, high real DEFAULT 0.0, low real DEFAULT 0.0, '
                        + ' open real DEFAULT 0.0, previousClose real DEFAULT 0.0, volume INTEGER DEFAULT 0, '
                        + ' quoteTimestamp text, lastChangeTimestamp text, watchlistId INTEGER NOT NULL, '
                        + ' PRIMARY KEY(id), FOREIGN KEY(watchlistId) REFERENCES watchlist(id))');
            // alarm
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS alarm'
                        + ' (id INTEGER, minimumPrice real DEFAULT null, maximumPrice real DEFAULT null, triggered INTEGER NOT NULL, '
                        + ' PRIMARY KEY(id))');
            // market data
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS marketdata'
                        + ' (id text NOT NULL, typeId INTEGER NOT NULL, name text, longName text, extRefId text NOT NULL, currency text, '
                        + ' symbol text, stockMarketSymbol text, stockMarketName text, '
                        + ' last real DEFAULT 0.0, changeAbsolute real DEFAULT 0.0, changeRelative real DEFAULT 0.0, '
                        + ' quoteTimestamp text, lastChangeTimestamp text, '
                        + ' PRIMARY KEY(id)) WITHOUT ROWID');
        })
    } catch (err) {
        console.log("Error creating tables for application in database : " + err)
    }
}

function loadTriggeredAlarms(watchlistId, lower) {
    var result = [];
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var query = 'SELECT s.id AS id, s.name AS name, s.price as price, s.currency as currency, a.minimumPrice as minimumPrice, a.maximumPrice as maximumPrice '
                    + ' FROM alarm a INNER JOIN stockdata s ON a.id = s.id'
                    + ' WHERE s.watchlistId = ? AND s.price > ? AND a.triggered = ? '
                    + ' AND ' + (lower ? ' s.price < a.minimumPrice AND a.minimumPrice <> "" ' : ' s.price > a.maximumPrice AND a.maximumPrice <> "" ');
            console.log("query : " + query);
            var dbResult = tx.executeSql(query, [watchlistId, 0.0, SQL_FALSE]);
            if (dbResult.rows.length > 0) {
                console.log("triggers alarm row count : " + dbResult.rows.length);
                for (var i = 0; i < dbResult.rows.length; i++) {
                    var triggeredAlarm = {};
                    triggeredAlarm.id = dbResult.rows.item(i).id;
                    triggeredAlarm.name = dbResult.rows.item(i).name;
                    triggeredAlarm.currency = dbResult.rows.item(i).currency;
                    triggeredAlarm.maximumPrice = dbResult.rows.item(i).maximumPrice;
                    triggeredAlarm.minimumPrice = dbResult.rows.item(i).minimumPrice;
                    console.log("triggered alarm is " + JSON.stringify(triggeredAlarm));
                    result.push(triggeredAlarm);
                }
            } else {
                console.log("alarms  not triggered !");
            }
        })
    } catch (err) {
        console.log("Error selecting triggred alarms id from database: " + err)
    }
    return result;
}

function loadAlarm(id) {
    var result = null;
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var dbResult = tx.executeSql(
                        'SELECT minimumPrice, maximumPrice FROM alarm WHERE id = ?',
                        [id]);
            if (dbResult.rows.length > 0) {
                console.log("alarm row count : " + dbResult.rows.length);
                var alarm = {};
                alarm.id = id;
                alarm.minimumPrice = dbResult.rows.item(0).minimumPrice;
                alarm.maximumPrice = dbResult.rows.item(0).maximumPrice;
                alarm.triggered = dbResult.rows.item(0).triggered;
                console.log("alarm is " + JSON.stringify(alarm));
                result = alarm;
            } else {
                console.log("alarm not found !");
            }
        })
    } catch (err) {
        console.log("Error selecting alarm id from database: " + err)
    }
    return result;
}

function countTableColumns(db, tableName) {
    var columns = 0;
    db.transaction(function (tx) {
        var results = tx.executeSql('SELECT COUNT(*) as count FROM alarm');
        columns = results.rows.item(0).count;
    })
    log("number of persisted columns for " + tableName + " : " + columns);
    return columns;
}

function saveAlarm(alarm) {
    var query = 'INSERT OR REPLACE INTO alarm(id, minimumPrice, maximumPrice, triggered) VALUES (?, ?, ?, ?)';
    var parameters = [alarm.id, alarm.minimumPrice, alarm.maximumPrice, SQL_FALSE];
    return executeInsertUpdateDeleteForTable("alarm", query, parameters, qsTr("Alarm added"), qsTr("Error adding alarm"));

/*
    var result = ""
    try {
        var db = getOpenDatabase()
        console.log("trying to insert row for alarm  " + alarm.id + ", " + alarm.minimumPrice + ", and maxprice : " + alarm.minimumPrice);
        console.log("final alarm id " + alarm.id);

        var numberOfPersistedAlarms = countTableColumns(db, "alarm");

        db.transaction(function (tx) {
            tx.executeSql('INSERT OR REPLACE INTO alarm(id, minimumPrice, maximumPrice, triggered) '
                        + 'VALUES (?, ?, ?, ?)'
                        ,
                        [alarm.id, alarm.minimumPrice, alarm.maximumPrice, SQL_FALSE])
        })
        result = qsTr("Alarm added")
    } catch (err) {
        result = qsTr("Error adding alarm")
        console.log(result + err)
    }
    return result
    */
}

function disableAlarm(id) {
    var query = 'UPDATE alarm SET triggered = ? WHERE id = ?';
    var parameters = [SQL_TRUE, id];
    return executeInsertUpdateDeleteForTable("alarm", query, parameters, qsTr("Alarm disabled"), qsTr("Error disabling alarm"));
    /*
    var result = ""
    try {
        var db = getOpenDatabase()


        db.transaction(function (tx) {
            tx.executeSql(query, [SQL_TRUE, id]);
        })
        result = qsTr("Alarm disabled")
    } catch (err) {
        result = qsTr("Error disabling alarm")
        console.log(result + err)
    }
    return result
    */
}

function getCurrentWatchlistId() {
    var result = null;
    try {
        var db = Database.getOpenDatabase();
        db.transaction(function (tx) {
            var dbResult = tx.executeSql(
                        'SELECT id FROM watchlist WHERE name = ?',
                        ['DEFAULT']);
            if (dbResult.rows.length > 0) {
                console.log("watchlist row count : " + dbResult.rows.length);
                var watchlistId = dbResult.rows.item(0).id;
                console.log("watchlistId is " + watchlistId);
                result = watchlistId;
            } else {
                console.log("watchlistId not found !");
            }
        })
    } catch (err) {
        console.log("Error selecting watchlistId from database: " + err)
    }
    return result;
}

function persistMarketdata(data) {
    var query = 'INSERT OR REPLACE INTO marketdata(id, typeId, name, longName, extRefId, currency, symbol, stockMarketSymbol, stockMarketName, '
                        + 'last, changeAbsolute, changeRelative, quoteTimestamp, lastChangeTimestamp) '
                        + 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,  ?, ?)';
    var parameters = [data.id, data.typeId, data.name, data.longName, '' + data.extRefId, data.currency, data.symbol, data.stockMarketSymbol, data.stockMarketName,
                         data.last, data.changeAbsolute, data.changeRelative, data.quoteTimestamp, data.lastChangeTimestamp];
    return executeInsertUpdateDeleteForTable("marketdata", query, parameters, qsTr("Market data added"), qsTr("Error adding market data"));
}

// persists the stock data - either insert or update
function persistStockData(data, watchlistId) {
    var result = ""
    try {
        var db = getOpenDatabase()
        // TODO (watchlistId) ? :
        var finalWatchlistId = (watchlistId === null || watchlistId === undefined) ? data.watchlistId : watchlistId;
        console.log("trying to insert row for " + data.symbol + ", " + data.name + ", and watchlist : " + watchlistId + ", " + data.watchlistId);
        console.log("final watchlist id " + finalWatchlistId);

        var numberOfPersistedStockData = countTableColumns(db, "stockdata");

        db.transaction(function (tx) {
            tx.executeSql(
                        'INSERT OR REPLACE INTO stockdata(id, extRefId, name, currency, stockMarketSymbol, stockMarketName, isin, symbol1, symbol2, '
                        + 'price, changeAbsolute, changeRelative, quoteTimestamp, lastChangeTimestamp, currency, high, low, ask, bid, volume, watchlistId) '
                        + 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [data.id, '' + data.extRefId, data.name, data.currency, data.stockMarketSymbol, data.stockMarketName, data.isin, data.symbol1, data.symbol2,
                         data.price, data.changeAbsolute, data.changeRelative, data.quoteTimestamp, data.lastChangeTimestamp, data.currency, data.high,
                         data.low, data.ask, data.bid, data.volume, finalWatchlistId])
        })
        result = qsTr("Stock added")
    } catch (err) {
        result = qsTr("Error adding stock")
        console.log(result + err)
    }
    return result
}

// TODO rename for more consistency - change parameter to alarm.id
function removeAlarm(alarm) {
    deleteTableEntry(alarm.id, "alarm");
}

function deleteMarketData(marketDataId) {
    deleteTableEntry(marketDataId, "marketdata");
}

function deleteStockData(stockDataId) {
    deleteTableEntry(stockDataId, "stockdata");
}

function loadMarketDataBy(extRefId) {
    var result;
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var query = 'SELECT id, typeId FROM marketdata WHERE extRefId = ?';
            console.log("query : " + query);
            console.log("query : " + extRefId);
            var dbResult = tx.executeSql(query, [extRefId])
            // create same object as from json response
            if (dbResult.rows.length > 0) {
                console.log("stockdata row count : " + dbResult.rows.length);
                var row = dbResult.rows.item(0);
                var entry = {};
                entry.id = row.id;
                entry.typeId = row.typeId;
                result = entry;
                console.log("loading single market data from database done");
            } else {
                console.log("no market data found for extRefId");
            }
        })
    } catch (err) {
        console.log("Error loading single market data from database: " + err)
    }
    return result;
}


function loadStockBy(watchlistId, extRefId) {
    var result;
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var query = 'SELECT id, watchlistId FROM stockdata WHERE extRefId = ? and watchlistId = ?';
            console.log("query : " + query);
            console.log("query : " + extRefId);
            console.log("query : " + watchlistId);
            var dbResult = tx.executeSql(query, [extRefId, watchlistId])
            // create same object as from json response
            if (dbResult.rows.length > 0) {
                console.log("stockdata row count : " + dbResult.rows.length);
                    var row = dbResult.rows.item(0);
                    var entry = {};
                    entry.id = row.id;
                    entry.watchlistId = row.watchlistId;
                result = entry;
                console.log("loading single stockdata data from database done");
            } else {
                console.log("no stockdata found for extRefId");
            }
        })
    } catch (err) {
        console.log("Error loading single stockdata from database: " + err)
    }
    return result;
}

function loadAllMarketData() {
    var result = [];
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var query = 'SELECT id, typeId, extRefId, name, longName, currency, symbol, stockMarketSymbol, stockMarketName, last, changeAbsolute '
                    +' ,changeRelative, quoteTimestamp, lastChangeTimestamp FROM marketdata';
            console.log("query : " + query);
            var dbResult = tx.executeSql(query, [])
            // create same object as from json response
            if (dbResult.rows.length > 0) {
                console.log("marketdata row count : " + dbResult.rows.length);
                for (var i = 0; i < dbResult.rows.length; i++) {
                    var row = dbResult.rows.item(i);
                    var entry = {};
                    console.log("row : " + row.name);
                    entry.id = row.id;
                    entry.typeId = row.typeId;
                    entry.extRefId = row.extRefId;
                    entry.name = row.name;
                    entry.longName = row.longName;
                    entry.currency = (row.currency === null ? "-" : row.currency);
                    entry.symbol = row.symbol;
                    entry.stockMarketSymbol = row.stockMarketSymbol;
                    entry.stockMarketName = row.stockMarketName;
                    // nicht gesetzt attribute koennen speater nicht mehr gesetzt werden (wenn mal als model verwendet)
                    entry.last = (row.last === null ? 0.0 : row.last);
                    entry.changeAbsolute = (row.changeAbsolute === null ? 0.0 : row.changeAbsolute);
                    entry.changeRelative = (row.changeRelative === null ? 0.0 : row.changeRelative);
                    entry.quoteTimestamp = (row.quoteTimestamp === null ? "" : row.quoteTimestamp);
                    entry.lastChangeTimestamp = (row.lastChangeTimestamp === null ? "" : row.lastChangeTimestamp);
                    result.push(entry);
                }
                console.log("loading marketdata data from database done");
            } else {
                console.log("no marketdata found");
            }
        })
    } catch (err) {
        console.log("Error loading marketdata from database: " + err)
    }
    return result;
}

function loadAllStockData(watchListId, sortString) { // TODO implement watchlistid
    var result = [];
    try {
        var db = Database.getOpenDatabase()
        db.transaction(function (tx) {
            var query = 'SELECT id, extRefId, name, currency, stockMarketSymbol, stockMarketName, isin, symbol1, symbol2, price, changeAbsolute '
                    +' ,changeRelative, quoteTimestamp, lastChangeTimestamp, watchlistId '
                    +' ,ask, bid, high, low, volume '
                    +' FROM stockdata ORDER BY ' + sortString;
            console.log("query : " + query);
            var dbResult = tx.executeSql(query, [])
            // create same object as from json response
            if (dbResult.rows.length > 0) {
                console.log("stockdata row count : " + dbResult.rows.length);
                for (var i = 0; i < dbResult.rows.length; i++) {
                    var row = dbResult.rows.item(i);
                    var entry = {};
                    console.log("row : " + row.name + ", change rel : " + row.changeRelative);
                    entry.id = row.id;
                    entry.watchlistId = watchListId;
                    entry.extRefId = row.extRefId;
                    entry.name = row.name;
                    entry.currency = row.currency;
                    entry.stockMarketSymbol = row.stockMarketSymbol;
                    entry.stockMarketName = row.stockMarketName;
                    entry.isin = row.isin;
                    entry.symbol1 = row.symbol1;
                    entry.symbol2 = row.symbol2;
                    entry.ask = row.ask;
                    entry.bid = row.bid;
                    entry.high = row.high;
                    entry.low = row.low;
                    entry.volume = row.volume;
                    // nicht gesetzt attribute koennen speater nicht mehr gesetzt werden (wenn mal als model verwendet)
                    entry.price = (row.price === null ? 0.0 : row.price);
                    entry.changeAbsolute = (row.changeAbsolute === null ? 0.0 : row.changeAbsolute);
                    entry.changeRelative = (row.changeRelative === null ? 0.0 : row.changeRelative);
                    entry.quoteTimestamp = (row.quoteTimestamp === null ? "" : row.quoteTimestamp);
                    entry.lastChangeTimestamp = (row.lastChangeTimestamp === null ? "" : row.lastChangeTimestamp);
                    entry.watchlistId = row.watchlistId;
                    result.push(entry);
                }
                console.log("loading stockdata data from database done");
            } else {
                console.log("no stockdata found");
            }
        })
    } catch (err) {
        console.log("Error loading stockdata from database: " + err)
    }
    return result;
}
