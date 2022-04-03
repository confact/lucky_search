# lucky_search
This is a WIP - feel free to help out!


Easy plugin and play elasticsearch library for Lucky framework. Highly inspired by [Searchkick](https://github.com/ankane/searchkick) but are still lacking some of the advanced features searchkick have. Now you can just index and search.

I also got a lot of help and borrowed code from [neuroplastic](https://github.com/place-labs/neuroplastic) - Thank you Place Labs!
I also borrowed some of the analysis from Searchkick to get stemming and so on. Thank you Searchkick!

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     lucky_search:
       github: confact/lucky_search
   ```

2. Run `shards install`

## Usage

Add following
```crystal
require "lucky_search"
```
to the shards.cr

### Settings
We use ENV variables for the elasticsearch settings:
- ELASTIC_URI                 - default: nil
- ELASTIC_HOST                - default: 127.0.0.1
- ELASTIC_PORT                - default: 9200
- ELASTIC_TLS                 - default: false
- ELASTIC_POOLED              - default: false
- ELASTIC_CONN_POOL           - default: 10
- ELASTIC_IDLE_POOL           - default: 10
- ELASTIC_CONN_POOL_TIMEOUT   - default: 5.0

You can also set this in a config file, like below:
LuckySearch::Client.configure do |config|
  config.uri = URI.parse("https://elastic:PrHfasu6fssfsd@localhost:9200")
end

config variables for the env above are:
- uri
- host
- port
- tls
- pooled
- pool_size
- idle_pool_size
- pool_timeout

Good to know:
- TLS will be automatically set to true if uri is set and the scheme is `https`
- we support basic auth in the URI


### Operations and Model
Add `include Searchable` to the operations for the models you want to add to elaticsearch. It adds hooks to update the index on saves and delete on delete.


You also need to have a `search_data` method in the model class that returns an hash of data you want to index. Example:
```crystal

def search_data
  {
    "name" => name,
    "last_campaign" => get_last_campaign,
    "age" => age
  }
end
``` 

Right now it has to be an flat data (no hash in the hash)

index all your data:
```
lucky search:reindex user
```

### Query
To do searches we use Lucky's query classes. We created a macro to generate methods for you.

Use existing query or create a new `SearchUser` query class.

add `luckySearchQuery(model)` to the class, example below:

```crystal
class UserQuery < User::BaseQuery
  luckySearchQuery(User)
end
``` 

You can now search by: `UserQuery.search("name")`

### Advanced queries
Our Query class and wrapper around it comes from [neuroplastic](https://github.com/place-labs/neuroplastic) and works similar, I have done some changes but works more or less the same.

You take out a Query class and set the filters and so on and then send it in the search method:
```crystal
query = UserQuery.search_empty_query
query.must({"visits" => ["monthly"]})
records = UserQuery.search(query)
```

check more in the [Query documentation](https://confact.github.io/lucky_search/LuckySearch/Query.html)

## Development

install elasticsearch and the shards by `shards install`
run the tests with `crystal spec` 

## Contributing

1. Fork it (<https://github.com/confact/lucky_search/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Håkan Nylén](https://github.com/confact) - creator and maintainer
- [Caspian Baska](https://github.com/Caspiano) - creator and maintainer of Neuroplastic which this is paste on
