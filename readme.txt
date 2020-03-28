> ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost
> cd /home/src1/projects/sailfishos/github/harbour-watchlist
> mb2 -t SailfishOS-2.2.0.29-armv7hl build
> mb2 --no-snapshot -t SailfishOS-3.2.1.20-armv7hl build
> cd RPMS
> scp harbour-watchlist-0.0.1-1.armv7hl.rpm wuesand@192.168.123.128:



MOEX: 
 * switch of backend does not properly reset watchlist content in some cases (multiple switches of backend)
   -> reload is triggered, before the onVisibleChanged is executed of the closing page
 * Intraday chart / 1 Year+ charts not implemented
 





NOTE:
 * Timeouts for xmlhttprequests are not yet supported: https://bugreports.qt.io/browse/QTBUG-50275

TODO  watchlist

+ consolidate Notification -> same code in Cover and Watchlist Page (-> new component)
+ icon broken for notifications (-> link to wrong image)
+ copyright headers
+ no signal slots -> lamba
+ i18n (more languages)
+ multiple backends
+ multiple watchlists


# generate or remove license header -via maven plugin
mvn license:format
mvn license:remove



