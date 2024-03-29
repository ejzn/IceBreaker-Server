-module(icebreaker_client_controller, [Req]).
-compile(export_all).


index('GET', []) ->
    {output, "There is no front end for the API"}.

list('GET', []) ->
    Clients = boss_db:find(client, []),
    case Clients of
            [] ->
                {output, <<"[]">>, [{"Content-Type", "application/json"}]};
            _Else ->
                {json, [{success, true}, {code, 1}, {clients, Clients}]}
    end.

activity('GET', []) ->
    Activity = boss_db:find(activity, []),
    case Activity of
            [] ->
                {output, <<"[]">>, [{"Content-Type", "application/json"}]};
            _Else ->
                {json, [{success, true}, {code, 1}, {activity, Activity}]}
    end;

activity('POST', [ClientId]) ->

    Latitude = Req:post_param("latitude"),
    Longitude = Req:post_param("longitude"),

    % Check the API token as needed
    NewActivity = activity:new(id, ClientId, Latitude, Longitude),
    case NewActivity:save() of
        {ok, SavedActivity} ->
            {json, [{success, true}, {code, 1}]};
        {error, Reason} ->
            {json, [{success, false}, {code, 3}, {messsage, Reason}]}

    end.

register('GET', []) ->
    ok;

register('GET', [Id]) ->
    ok;

register('POST', []) ->
    Firstname = Req:post_param("firstname"),
    Lastname = Req:post_param("lastname"),
    ImageUrl = Req:post_param("image_url"),
    Headline = Req:post_param("headline"),
    Status = Req:post_param("status"),
    NewClient = client:new(id, Firstname, Lastname, ImageUrl, Status, Headline),

    %Token = token:new(NewClient:id(), edate:shift(erlang:localtime(), +1, months), base64:encode(crypto:strong_rand_bytes(Bytes)))

    case NewClient:save() of
        {ok, SavedClient} ->
            {json, [{success, true}, {client, SavedClient}]};
        {error, Reason} ->
            {json, [{success, false}]}
    end;

register('POST', [Id]) ->

    Token = Req:post_param("api_token"),
    % Now we need to check the token is valid...

    case boss_db:find(Id) of
        [Client] ->
            NewClient = Client:set([{firstname, Req:post_param("firstname")}, {lastname, Req:post_param("lastname")}, {imageurl, Req:post_param("imageurl")}, {status, Req:post_params("status")}]),
            case NewClient:save() of
                {ok, SavedClient} ->
                    {json, [{success, true}, {client_id , 1}]};
                {error, Reason} ->
                    {json, [{success, false}]}
            end;
        [] ->
            {json, [{success, false}]}
     end.




