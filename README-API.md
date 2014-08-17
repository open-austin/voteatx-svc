# VoteATX Service API

## Response Entities

### Location

A location, with name and address.

* name -- Location name, such as "Fiesta Mart Central".
* address -- Location street address, such as "3909 North IH 35".
* city -- Location city, such as "Austin".
* state -- Location state, such as "TX".
* zip -- Location zip code, such as "78722"
* latitude -- Location latitude in degrees, such as 30.29642.
* longitude -- Location longitude in degrees, such as -97.71764

Example:

    {
        "name" : "Fiesta Mart Central",
        "state" : "TX",
        "zip" : "78722",
        "city" : "Austin",
        "address" : "3909 North IH 35",
        "latitude" : 30.29642,
        "longitude" : -97.71764
     },
    
### Place

A voting place.

* id -- Unique identifier for the place.
* title -- Title for the place, such as "Voting place for precinct 275"
    or "Early voting location".
* info -- An HTML string, that can be presented to the user, such as in
    a map info window.
* is_open -- Indicates whether this place is open at the time of the
    query. Boolean "true" or "false" value.
* type -- Type of voting place. One of the following: "ELECTION_DAY",
    "EARLY_VOTING_FIXED", or "EARLY_VOTING_MOBILE"
* location -- A _Location_ entity for this voting place.

Example:

    {
       "id" : 2,       
       "title" : "Early voting location"
       "type" : "EARLY_VOTING_FIXED",
       "location" : {
          "name" : "Fiesta Mart Central",
          "state" : "TX",
          "zip" : "78722",
          "city" : "Austin",
          "address" : "3909 North IH 35",
          "latitude" : 30.29642,
          "longitude" : -97.71764
       },
       "info" : "<b>Early Voting Location</b> ... <DELETED> ...",
       "is_open" : false,
    }

### Region

A map region, expressed as a list of vertices.

* type -- The region type type, typically "Polygon".
* coordinates -- An array of [longitude,latitude] coordinates.

Example:

    {
       "type" : "Polygon",
       "coordinates" : [[[-97.727049999582,30.3030389998156], ...<DELETED> ... [-97.727049999582,30.3030389998156]]]
    }
    
    
### District

A district or some regional area.

* id -- Unique identifier for this district.
* region -- A _Region_ entity, describing the map region.


Example:

    {
       "id" : "275",
       "region" : {
          "type" : "Polygon",
          "coordinates" : [[[-97.727049999582,30.3030389998156], ...<DELETED> ... [-97.727049999582,30.3030389998156]]]
       }
    }
    
### Message

A message to be displayed to the user.

* severity -- Message severity. Possible values are: "ERROR", "WARNING",
    "INFO".
* content -- Message content in HTML.

Example:

    {
       "severity" : "WARNING",
       "content" : "<p>Beware of low flying armadillos.</p>"
    }

## Requests


### GET /search

Searches for best voting places near a given location.

#### Request Parameters

* latitude [required] -- Latitude of the search location, in degrees.

* longitude [required] -- Longitude of the search location, in degrees.

* time [options] -- Search locates best voting places for the given time.
Default is now. Time is specified in a format understood by the Ruby
Time#parse function. This primarily is used for testing.

* max_distance [options] -- Consider only voting places within this distance
(in miles) of the given location. Default is 12 miles.

* max_locations [options] -- Maximum number of early voting locations
returned in the results. Default is 4.

#### Response

The response entity contains attributes:

* districts -- A keyed list of _District_ entitities. The keys are
    district type, such as "precinct" or "city_council".
* places -- An array of _Place_ entities, indicating the best voting
    places for this location.
* message -- An optional _Message_ entity.

To make applications more performant, extremely large polygons are
removed from the _District_ entities. In this case, the "region" value
will be true, instead of a _Region_ entity that contains a polygon. If
the polygon is needed, a seperate query for that region will be required.
For an example of this, see the "districts.city_council.region" parameter
in the example below.


#### Example

    GET http://svc.voteatx.us/search?latitude=30.30403242619467&longitude=-97.72785186767578

    {
       "places" : [
          {
             "title" : "Voting place for precinct 275",
             "info" : "<b>Precinct 275</b> ... <DELETED> ...",
             "is_open" : false,
             "type" : "ELECTION_DAY",
             "location" : {
                "longitude" : -97.73588,
                "latitude" : 30.30393,
                "zip" : "78751",
                "address" : "3908 Avenue B (Enter off of 39th Street)",
                "city" : "Austin",
                "state" : "TX",
                "name" : "Baker Center"
             },
             "id" : 1
          },
          {
             "id" : 2,
             "location" : {
                "name" : "Fiesta Mart Central",
                "state" : "TX",
                "zip" : "78722",
                "city" : "Austin",
                "address" : "3909 North IH 35",
                "latitude" : 30.29642,
                "longitude" : -97.71764
             },
             "type" : "EARLY_VOTING_FIXED",
             "info" : "<b>Early Voting Location</b> ... <DELETED> ...",
             "is_open" : false,
             "title" : "Early voting location"
          }
       ],
       "districts" : {
          "city_council" : {
             "region" : true,
             "id" : 9
          },
          "precinct" : {
             "id" : "275",
             "region" : {
                "type" : "Polygon",
                "coordinates" : [[[-97.727049999582,30.3030389998156], ...<DELETED> ... [-97.727049999582,30.3030389998156]]]
             }
          }
       },
       "message" : {
          "severity" : "WARNING",
          "content" : "<p>This app is displaying voting place information for the May 2014 election.</p>\n            <p>We will update this app once voting place information for the Nov 4, 2014 election is released.</p>"
       }
    }


### GET /districts/:type/:id

Retrieves a specified district.

#### Request Parameters

* :type -- The district type. Supported values are "precinct" and
    "city_council".
* :id -- The district identifier.

#### Response

The response is a _District_ entity.

#### Exammple

    GET /districts/precinct/275
    {
       "id" : "275",
       "region" : {
          "type" : "Polygon",
          "coordinates" : [[[-97.727049999582,30.3030389998156], ...<DELETED> ... [-97.727049999582,30.3030389998156]]]
       }
    }

### GET /places/:id

Not implemented yet.

