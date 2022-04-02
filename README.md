# lucky_search

Easy plugin and play elasticsearch library for Lucky framework. Highly inspired by searchkick but are still lacking some of the advanced features searchkick have. Now you can just index and search.

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

Add `include Searchable` to the operations you want to add to elaticsearch. It adds hooks to update the index on saves and delete on delete.
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

Right now it has to be an flat data (no hash in the hash)

index all your data:
```
lucky search:reindex user
```

Now you need to have a query class you can use for search, example of a classname would be `SearchUser < User::BaseQuery` 

Include `LuckySearch` in the query.

you can run `lucky gen.search User` to get the class above, `SearchUser` with the included `LuckySearch` already.

You can now search by: `SearchUser.search(data)`

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
