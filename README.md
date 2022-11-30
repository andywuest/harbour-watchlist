# Watchlist

This repository contains the sources of the watchlist application for Sailfish OS.

At the moment there are two backends that provide the data. There are the public
rest services that the page https://www.euroinvestor.dk/ uses. The other backend is
the offical Moscow Exchange API backend. In the future i plan
to support more backend, e.g. Deutsche Boerse, so you can get more stocks for your
specific market country. Additionally there is a news backend with provides some
stock news (however in German only). The market overview page also allows
you to display market indices and crypto currencies.

## Features

- Market data overview page with indices / currencies / crypto currencies.
- Watchlist with stocks from all over the world.
- Add / Remove stocks
- Update Quotes
- Add alarms to individual stocks
- Two different data backend (Euroinvestor / Moscow Exchange)
- Show charts for the securities in the watchlist for different periods of time
- Show upcoming dividend payments for the securities in the watchlist 


## Author
Andreas Wüst [andreas.wuest.freelancer@gmail.com](mailto:andreas.wuest.freelancer@gmail.com)

## Screenshots

![Market data](/screenshots/watchlist6.png?raw=true "Market data view")
![Market data selection](/screenshots/watchlist5.png?raw=true "Market data selection")
![Stock overview](/screenshots/watchlist2.png?raw=true "Stock overview")
![Stock search](/screenshots/watchlist1.png?raw=true "Stock search")
![Alarm configuration](/screenshots/watchlist3.png?raw=true "Alarm configuration")
![Stock details](/screenshots/watchlist4.png?raw=true "Stock details")
![Security charts](/screenshots/watchlist7.png?raw=true "Security charts")
![Dividend payments](/screenshots/watchlist8.png?raw=true "Dividend payments")

## Build
Simply clone this repository.

## Debugging

### SQLite Database

For easier analysis just copy the database to your local machine to you can check it with a db tool of 
your choice: 

```
scp -P 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/sdk defaultuser@localhost:~/.local/share/harbour-watchlist/harbour-watchlist/QML/OfflineStorage/Databases/* ~/projects/sailfishos/github/harbour-watchlist/
```

## License
Licensed under GNU GPLv3

## Translations

Watchlist was translated to several languages. Thanks to all contributors!
- German: me :-)
- Chinese: [dashinfantry](https://github.com/dashinfantry)
- Russian: [Viacheslav Dikonov](https://github.com/ApostolosB)
- Swedish: [Åke Engelbrektson](https://github.com/eson57)
- French: [Patrick Hervieux](https://github.com/pherjung)
