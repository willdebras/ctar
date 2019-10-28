
# {ctar}

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

You can also use a `.Renviron` file to have R automatically set the
environment variable at startup. The package `usethis` can be handy for
this.

``` r
usethis::edit_r_environ()
```

This will open a .Renviron file for you. Add a line like this, but
substitute your API key:

`ctar_api_key="xxxxxxxxxxxxx"`

Save the file then restart your R session

``` r
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

arrivals_18th <- get_arrivals(route = "pink", stop = 30162, key = Sys.getenv("ctar_api_key"))

kable(head(arrivals_18th))
```

| staId | stpId | staNm | stpDe                      | rn  | rt   | destSt | destNm      | trDr | prdt                | arrT                | isApp | isSch | isDly | isFlt | flags | lat      | lon        | heading |
| :---- | :---- | :---- | :------------------------- | :-- | :--- | :----- | :---------- | :--- | :------------------ | :------------------ | :---- | :---- | :---- | :---- | :---- | :------- | :--------- | :------ |
| 40830 | 30162 | 18th  | Service toward 54th/Cermak | 307 | Pink | 30114  | 54th/Cermak | 5    | 2019-10-03 14:04:19 | 2019-10-03 14:10:19 | 0     | 0     | 0     | 0     | NA    | 41.88531 | \-87.66697 | 268     |
| 40830 | 30162 | 18th  | Service toward 54th/Cermak | 306 | Pink | 30114  | 54th/Cermak | 5    | 2019-10-03 14:04:41 | 2019-10-03 14:19:41 | 0     | 0     | 0     | 0     | NA    | 41.87695 | \-87.63365 | 307     |

The response columns in the returned dataframe correspond with the
response fields of the API. Detailed information about the response
fields is below or available on the API website.

<img src="./images/ctar_responses.png" width="100%" />

With this function, the route is optional. For stations with multiple
routes, we can request data from all of the routes. For example, let’s
use the station argument for the State/Lake stop so we get data from
both directions and let’s call it without a route so we get data from
all lines.

``` r

arrivals_lake <- get_arrivals(station = 40260, key = Sys.getenv("ctar_api_key"))

kable(head(arrivals_lake))
```

| staId | stpId | staNm      | stpDe                          | rn  | rt   | destSt | destNm        | trDr | prdt                | arrT                | isApp | isSch | isDly | isFlt | flags | lat      | lon        | heading |
| :---- | :---- | :--------- | :----------------------------- | :-- | :--- | :----- | :------------ | :--- | :------------------ | :------------------ | :---- | :---- | :---- | :---- | :---- | :------- | :--------- | :------ |
| 40260 | 30051 | State/Lake | Service at Outer Loop platform | 007 | G    | 30004  | Harlem/Lake   | 1    | 2019-10-01 09:57:17 | 2019-10-01 10:00:17 | 0     | 0     | 0     | 0     | NA    | 41.87452 | \-87.62655 | 33      |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 609 | G    | 30139  | Cottage Grove | 5    | 2019-10-01 09:57:18 | 2019-10-01 10:00:18 | 0     | 0     | 0     | 0     | NA    | 41.8857  | \-87.64069 | 89      |
| 40260 | 30051 | State/Lake | Service at Outer Loop platform | 409 | Brn  | 30249  | Kimball       | 1    | 2019-10-01 09:55:09 | 2019-10-01 09:59:09 | 0     | 0     | 0     | 0     | NA    | 41.87694 | \-87.62738 | 88      |
| 40260 | 30051 | State/Lake | Service at Outer Loop platform | 412 | Brn  | 30249  | Kimball       | 1    | 2019-10-01 09:57:12 | 2019-10-01 10:01:12 | 0     | 0     | 0     | 0     | NA    | 41.87689 | \-87.62908 | 88      |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 310 | Pink | 30114  | 54th/Cermak   | 5    | 2019-10-01 09:57:09 | 2019-10-01 10:01:09 | 0     | 0     | 0     | 0     | NA    | 41.88566 | \-87.64782 | 89      |
| 40260 | 30050 | State/Lake | Service at Inner Loop platform | 716 | Org  | 30182  | Midway        | 5    | 2019-10-01 09:56:26 | 2019-10-01 10:05:26 | 0     | 0     | 0     | 0     | NA    | 41.87691 | \-87.6282  | 267     |

## Locations API

The locations API produces a list of trains and their locations on a
single L route. This function takes a route argument and a key argument
to produce a list of all trains on that line. It acts similarly to the
arrivals API without a stop or station id in providing coordinates,
geospatial heading, train attributes, and next stop information.

``` r

locations_blue <- get_locations(route = "blue", key = Sys.getenv("ctar_api_key"))

kable(head(locations_blue))
```

| rn  | destSt | destNm                  | trDr | nextStaId | nextStpId | nextStaNm                 | prdt                | arrT                | isApp | isDly | flags | lat      | lon        | heading |
| :-- | :----- | :---------------------- | :--- | :-------- | :-------- | :------------------------ | :------------------ | :------------------ | :---- | :---- | :---- | :------- | :--------- | :------ |
| 103 | 30077  | Forest Park             | 5    | 40350     | 30069     | UIC-Halsted               | 2019-10-01 10:16:05 | 2019-10-01 10:18:05 | 0     | 0     | NA    | 41.87551 | \-87.64244 | 270     |
| 104 | 30077  | Forest Park             | 5    | 40060     | 30013     | Belmont                   | 2019-10-01 10:16:14 | 2019-10-01 10:18:14 | 0     | 0     | NA    | 41.94644 | \-87.71833 | 142     |
| 106 | 30077  | Forest Park             | 5    | 40810     | 30158     | Illinois Medical District | 2019-10-01 10:16:18 | 2019-10-01 10:17:18 | 1     | 0     | NA    | 41.87582 | \-87.66457 | 269     |
| 110 | 30077  | Forest Park             | 5    | 41280     | 30248     | Jefferson Park            | 2019-10-01 10:15:44 | 2019-10-01 10:20:44 | 0     | 0     | NA    | 41.98233 | \-87.80815 | 89      |
| 113 | 30077  | Forest Park             | 5    | 40230     | 30045     | Cumberland                | 2019-10-01 10:15:35 | 2019-10-01 10:17:35 | 0     | 0     | NA    | 41.98351 | \-87.85939 | 87      |
| 114 | 0      | Rosemont (for OâHare) | 1    | 41330     | 30259     | Montrose                  | 2019-10-01 10:16:17 | 2019-10-01 10:17:17 | 1     | 0     | NA    | 41.95604 | \-87.73464 | 297     |

### Note on routes

The `route` argument in each function will try to match to the full name
of the line. While the API accepts only specific calls for route like
“Org” for orange, “Y” for yellow, or “Red” for red, the functions for
the arrivals and locations APIs in this package will match “y”, “yellow”
or “yell” for yellow. It will always accept the full color spelled out
and will try to match abbreviations if they are unique. For example, it
will not match “b” to blue or brown, but it will match “br” to brown.

## Follow This Train API

The follow This Train API, or the “Follow the Damn Train, CJ” API,
produces arrival predictions for a single train at all stations on its
route until the end of its trip. This API requires a knowledge of run
number associated with a train, which changes daily.

We can use information from the arrivals or locations APIs above to
access run number and then get information on the single train. We can
call query information about its anticipated arrivals.

``` r

run_104 <- get_train(run_number = 104, key = Sys.getenv("ctar_api_key"))

kable(head(run_104))
```

| staId | stpId | staNm                       | stpDe                          | rn  | rt        | destSt | destNm      | trDr | prdt                | arrT                | isApp | isSch | isDly | isFlt | flags |
| :---- | :---- | :-------------------------- | :----------------------------- | :-- | :-------- | :----- | :---------- | :--- | :------------------ | :------------------ | :---- | :---- | :---- | :---- | :---- |
| 40920 | 30180 | Pulaski                     | Service toward Forest Park     | 104 | Blue Line | 30077  | Forest Park | 5    | 2019-10-01 10:54:16 | 2019-10-01 10:57:16 | 0     | 0     | 0     | 0     | NA    |
| 40970 | 30188 | Cicero                      | Service toward Forest Park     | 104 | Blue Line | 30077  | Forest Park | 5    | 2019-10-01 10:54:16 | 2019-10-01 11:00:16 | 0     | 0     | 0     | 0     | NA    |
| 40010 | 30002 | Austin                      | Service toward Forest Park     | 104 | Blue Line | 30077  | Forest Park | 5    | 2019-10-01 10:54:16 | 2019-10-01 11:04:16 | 0     | 0     | 0     | 0     | NA    |
| 40180 | 30035 | Oak Park                    | Service toward Forest Park     | 104 | Blue Line | 30077  | Forest Park | 5    | 2019-10-01 10:54:16 | 2019-10-01 11:06:16 | 0     | 0     | 0     | 0     | NA    |
| 40980 | 30190 | Harlem (Forest Park Branch) | Service toward Forest Park     | 104 | Blue Line | 30077  | Forest Park | 5    | 2019-10-01 10:54:16 | 2019-10-01 11:09:16 | 0     | 0     | 0     | 0     | NA    |
| 40390 | 30077 | Forest Park                 | Forest Park (Terminal Arrival) | 104 | Blue Line | 30077  | Forest Park | 5    | 2019-10-01 10:54:16 | 2019-10-01 11:10:16 | 0     | 0     | 0     | 0     | NA    |

We can also singularly query information about its
position.

``` r
run_104_position <- get_train_position(run_number = 104, key = Sys.getenv("ctar_api_key"))

kable(head(run_104_position))
```

| lat      | lon        | heading |
| :------- | :--------- | :------ |
| 41.87401 | \-87.71586 | 269     |

## Additional features and info

### stop\_ids dataset

The {ctar} package features a lot of additional data about individual
stops found in the `stop_ids` dataset. A general explanation of the
dataset can be found with the help command `?stop_ids`. In addition to
the main variables, the dataset contains the zip code, ward, and census
track of each stop and station, as well as binary indicators about
whether each line stops at these locations and if they are ADA
accessible.

## Using the Bus Tracker API

There are currently 5 functions implemented for getting data from the
CTA Bus Tracker API:

  - `get_bus_tracker_system_time()` - used to make sure your computer
    and the CTA server are in sync
  - `get_bus_routes()` - returns a dataframe of all the CTA bus routes
  - `get_bus_route_directions()` - returns a dataframe of the directions
    an individual bus route travels in
  - `get_bus_route_stops()` - returns a dataframe with the locations of
    stops along an individual bus route with direction
  - `get_bus_location()` - returns a dataframe with the last location of
    currently operating buses

### Bus Tracker examples

Get the difference between my computer’s clock and the CTA Bus Tracker
server clock

``` r
my_time <- Sys.time()
bus_time <- get_bus_system_time(key=Sys.getenv("ctar_api_key"))

paste("My time: ", my_time, ", Bus server time: ", bus_time)
#> [1] "My time:  2019-10-25 22:31:31 , Bus server time:  2019-10-25 22:31:32"
```

Get all the CTA Bus Routes and print out a handful

``` r
cta_bus_routes <- get_bus_routes()
sample_of_buses <- c(8, 12, 20, 49)

kable(cta_bus_routes[cta_bus_routes$rt %in% sample_of_buses, ])
```

|    | rt | rtnm      | rtclr    | rtdd |
| -- | :- | :-------- | :------- | :--- |
| 8  | 8  | Halsted   | \#ff00ff | 8    |
| 13 | 12 | Roosevelt | \#33ccff | 12   |
| 18 | 20 | Madison   | \#336633 | 20   |
| 36 | 49 | Western   | \#336633 | 49   |

Find out what directions a bus route travels

``` r
route_directions <- get_bus_route_directions(route = 8)

print(route_directions)
#>          dir
#> 1 Northbound
#> 2 Southbound
```

``` r
route_stops <- get_bus_route_stops(route = 8, direction = "n")

most_south <- min(route_stops$lat)
most_north <- max(route_stops$lat)

route_stop_ends <- rbind(
  route_stops[route_stops$lat == most_south, ],
  route_stops[route_stops$lat == most_north, ]
)

kable(route_stop_ends)
```

|    | stpid | stpnm                                |      lat |        lon |
| -- | :---- | :----------------------------------- | -------: | ---------: |
| 55 | 3681  | Halsted & 79th Street Terminal       | 41.74973 | \-87.64365 |
| 96 | 5756  | Halsted & Waveland/Broadway Terminal | 41.94977 | \-87.64889 |

Find out where buses on a route actually are

``` r
bus_locations <- get_bus_location(routes = 8)

# Transpose just to make it easier to see all the columns
kable(t(bus_locations[1:3, ]))
```

|           | 1                   | 2                   | 3                   |
| --------- | :------------------ | :------------------ | :------------------ |
| vid       | 7938                | 1219                | 7970                |
| tmstmp    | 2019-10-25 22:31:04 | 2019-10-25 22:31:11 | 2019-10-25 22:31:07 |
| lat       | 41.949771881103516  | 41.92406120300293   | 41.8552885055542    |
| lon       | \-87.64889526367188 | \-87.64871215820312 | \-87.64659118652344 |
| hdg       | 88                  | 178                 | 179                 |
| pid       | 9368                | 9368                | 9368                |
| rt        | 8                   | 8                   | 8                   |
| des       | 79th                | 79th                | 79th                |
| pdist     | 0                   | 9629                | 34932               |
| dly       | FALSE               | FALSE               | FALSE               |
| tatripid  | 1078428             | 1078427             | 1078425             |
| tablockid | 8 -713              | 8 -704              | 8 -715              |
| zone      |                     |                     |                     |

### API documentation

While the {ctar} package has data to reference stop and station ids and
intuitively returns API error codes when you run into them, it can be
useful to have readable tables explaining and documenting these. The
[CTA developer page](https://www.transitchicago.com/developers/ttdocs/)
contains reference to all of these tables and includes additional
documentation of running individual queries outside of the context of
this package.

## Future plans

  - Potentially adding the bus tracker and customer alerts APIs  
  - Allowing some fuzzy matching for station and stop calls for ease of
    use
  - Unit tests/CRAN submission :^)

## Issues

If you have an issue, feature suggestion, or question regarding use,
feel free to open an issue here on github or tweet at me
@[\_willdebras](https://twitter.com/_willdebras).
