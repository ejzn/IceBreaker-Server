IceBreaker-Server
=================

The Server side component of the IceBreaker application. This provides the ability to the endpoints to register, and request information from the Server itself for Geolocation based data.


ERLANG General Tips

1. Patern matching and functions: These fuckers give you best of breed ability to avoid if statements, try and think how you can return something from a case, without error or need for an if, ie: match undefined -> then define it. Match a success, then do something with it.

2. Wathch your periods, commas and semi-colons. Erlang has an interesting syntax that takes some serious getting used to.

3. Save records in Chicago Boss, make sure on Save, that you can a proper calback. Erlang is built with high concurrency so it won't help you out and wait for anything. It will give you a return value if it saved something, but it won't give you a reference to your stored value.

4. Learn about Boss Records and Erlang with reference to the DB. This has a lot to do with the inspiration from Ruby on Rails active records. Learn the synta.

5. Passing "id" inte a record:new call will use the special auto generated function call for the record.

Docs:

The docs for the API are available aut-generated at <server-root>/docs. They provide a handy object reference on Erlang as well as a listing of the functions available for each, usually based on Boss Records.
