
# ctar

{ctar} is an R package designed to interface with the Chicago Transit
Authority train tracker API. In order to use this R package you will
need to apply for a key. Applications for an API key can be found on the
[CTA
website](https://www.transitchicago.com/developers/traintrackerapply/).

CTA train tracker offers three APIs, the arrivals API, the locations
API, and the Follow This Train API. This package has functions to
interface with each of the three APIs.

## Installation

You can install the released version of ctar from
[Github](https://github.com/willdebras/ctar) with:

``` r
library(remotes)
install_github("willdebras/ctar")
```

## API keys

The functions for each of the three APIs have a `key` argument that
defaults to an object called `ctar_api_key`. We can use the function
argument to manually include the key, such as:

`get_arrivals(route = "red", key = xxxxxxxxxxxxx)`

Alternatively, we can assign the key to an object called `ctar_api_key`
and leave the `key` argument blank, such as:

`ctar_api_key <- xxxxxxxxxxxxx`

The best method to store this key though is probably to set it to an
environment variable and call it later, such as:

``` r

Sys.setenv(ctar_api_key="xxxxxxxxxxxxx")

get_arrivals(route = "red", key = Sys.getenv("ctar_api_key"))
```

## Arrivals API

The arrivals API produces a list of arrival predictions for all
platforms at a given train station. The arrivals takes a single argument
of either a map id (a station) or a stop id (a station and direction
combination).

We can reference these stop and station ids with the stop\_ids dataset.

``` r
library(ctar)
data("stop_ids")

kable(head(stop_ids[1:6]))
```

| STOP\_ID | DIRECTION\_ID | STOP\_NAME                        | STATION\_NAME        | STATION\_DESCRIPTIVE\_NAME        | STATION\_ID |
| -------: | :------------ | :-------------------------------- | :------------------- | :-------------------------------- | ----------: |
|    30162 | W             | 18th (54th/Cermak-bound)          | 18th                 | 18th (Pink Line)                  |       40830 |
|    30161 | E             | 18th (Loop-bound)                 | 18th                 | 18th (Pink Line)                  |       40830 |
|    30022 | N             | 35th/Archer (Loop-bound)          | 35th/Archer          | 35th/Archer (Orange Line)         |       40120 |
|    30023 | S             | 35th/Archer (Midway-bound)        | 35th/Archer          | 35th/Archer (Orange Line)         |       40120 |
|    30214 | S             | 35-Bronzeville-IIT (63rd-bound)   | 35th-Bronzeville-IIT | 35th-Bronzeville-IIT (Green Line) |       41120 |
|    30213 | N             | 35-Bronzeville-IIT (Harlem-bound) | 35th-Bronzeville-IIT | 35th-Bronzeville-IIT (Green Line) |       41120 |

Now we can get some basic data about arrivals with the `get_arrivals()`
function.

``` r

arrivals_18th <- get_arrivals <- get_arrivals(route = "pink", stop = 30162, key = Sys.getenv("ctar_api_key"))

kable(head(arrivals_18th))
```

| staId | stpId | staNm | stpDe                      | rn  | rt   | destSt | destNm      | trDr | prdt                | arrT                | isApp | isSch | isDly | isFlt | flags | lat      | lon        | heading |
| :---- | :---- | :---- | :------------------------- | :-- | :--- | :----- | :---------- | :--- | :------------------ | :------------------ | :---- | :---- | :---- | :---- | :---- | :------- | :--------- | :------ |
| 40830 | 30162 | 18th  | Service toward 54th/Cermak | 307 | Pink | 30114  | 54th/Cermak | 5    | 2019-09-30 15:38:58 | 2019-09-30 15:43:58 | 0     | 0     | 0     | 0     | NA    | 41.88531 | \-87.66697 | 268     |
| 40830 | 30162 | 18th  | Service toward 54th/Cermak | 313 | Pink | 30114  | 54th/Cermak | 5    | 2019-09-30 15:39:55 | 2019-09-30 15:55:55 | 0     | 0     | 0     | 0     | NA    | 41.87695 | \-87.63365 | 307     |

With this function, the route is optional. For stations with multiple
routes, we can request data from all of the routes. For example, let’s
use the station argument for the State/Lake stop so we get data from
both directions and let’s call it without a route so we get data from
all lines.

``` r

arrivals_lake <- get_arrivals <- get_arrivals(station = 40260, key = Sys.getenv("ctar_api_key"))

kable(head(arrivals_lake))
```

| staId | stpId | staNm      | stpDe                          | rn  | rt   | destSt | destNm       | trDr | prdt                | arrT                | isApp | isSch | isDly | isFlt | flags | lat      | lon        | heading |
| :---- | :---- | :--------- | :----------------------------- | :-- | :--- | :----- | :----------- | :--- | :------------------ | :------------------ | :---- | :---- | :---- | :---- | :---- | :------- | :--------- | :------ |
| 40260 | 30051 | State/Lake | Service at Outer Loop platform | 415 | Brn  | 30249  | Kimball      | 1    | 2019-09-30 15:44:06 | 2019-09-30 15:45:06 | 1     | 0     | 0     | 0     | NA    | 41.88261 | \-87.62617 | 358     |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 513 | P    | 30203  | Linden       | 5    | 2019-09-30 15:44:16 | 2019-09-30 15:46:16 | 0     | 0     | 0     | 0     | NA    | 41.88572 | \-87.63391 | 89      |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 017 | G    | 30057  | Ashland/63rd | 5    | 2019-09-30 15:43:34 | 2019-09-30 15:47:34 | 0     | 0     | 0     | 0     | NA    | 41.8857  | \-87.64069 | 89      |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 715 | Org  | 30182  | Midway       | 5    | 2019-09-30 15:43:50 | 2019-09-30 15:49:50 | 0     | 0     | 0     | 0     | NA    | 41.87872 | \-87.63374 | 357     |
| 40260 | 30051 | State/Lake | Service at Outer Loop platform | 015 | G    | 30004  | Harlem/Lake  | 1    | 2019-09-30 15:44:06 | 2019-09-30 15:52:06 | 0     | 0     | 0     | 0     | NA    | 41.85683 | \-87.62647 | 359     |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 312 | Pink | 30114  | 54th/Cermak  | 5    | 2019-09-30 15:44:11 | 2019-09-30 15:53:11 | 0     | 0     | 0     | 0     | NA    | 41.88574 | \-87.62758 | 90      |
