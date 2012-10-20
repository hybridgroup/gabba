# Gabba

Simple class to send custom server-side events to Google Analytics

Heavily influenced by the http://code.google.com/p/serversidegoogleanalytics

## Examples

### Track page views

```ruby
Gabba::Gabba.new("UT-1234", "mydomain.com").page_view("something", "track/me")
```

### Track custom events

```ruby
Gabba::Gabba.new("UT-1234", "mydomain.com").event("Videos", "Play", "ID", "123", true)
```

### Works with existing client-side Google Analytics cookies

```ruby
gabba = Gabba::Gabba.new("UT-1234", "mydomain.com")

# grab the __utma and (optionally) __utmz unique identifiers
gabba.identify_user(cookies[:__utma], cookies[:__utmz])

# trigger actions as normal
gabba.page_view("something", "track/me")
```

### Setting custom vars

```ruby
# Index: 1 through 50
index = 1

# Scope: VISITOR, SESSION or PAGE
scope = Gabba::Gabba::VISITOR

# Set var
gabba.set_custom_var(index, 'Name', 'Value', scope)

# Track the event (all vars will be included)
gabba.event(...)

# Track the page view (all vars will be included)
gabba.page_view(...)
```

### Removing custom vars

```ruby
# Index: 1 through 50
index = 1

# Delete var with this index
gabba.delete_custom_var index
```

### Track ecommerce transactions

```ruby
g = Gabba::Gabba.new("UT-6666", "myawesomeshop.net")
g.transaction("123456789", "1000.00", 'Acme Clothing', '1.29', '5.00', 'Los Angeles', 'California', 'USA')
```
