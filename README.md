# lucky_search

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

```crystal
require "lucky_search"
```
to the shards.cr

Add `include Searchable` to the operations for the models you want to add to elaticsearch. It adds hooks to update the index on saves and delete on delete.
You also need to have a `search_data` method in the model class that returns an hash of data you want to index. Example:
```crystal

def search_data
  {
    name: name,
    last_campaign: get_last_campaign,
    age: age
  }
end
``` 

Now you need to have a query class you can use for search, example of a classname would be `SearchUser < User::BaseQuery` 

Include `LuckySearch` in the query.

You can now search by: `SearchUser.search("name")`

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
