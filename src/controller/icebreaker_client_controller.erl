-module(icebreaker_client_controller, [Req]).
-compile(export_all).


index('GET', []) ->
    {output, "There is no front end for the API"}.

list('GET', []) ->
    Clients = boss_db:find(client, [{firstname, 'not_equals', "(null)"}]),
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

messagesbythread('GET', []) ->
    ThreadId = Req:param("thread_id"),
    Messages = boss_db:find(message, [{thread_id, 'equals', ThreadId}]),
    io:format("Thread:  ~p~n", [ThreadId]),
    case Messages of
            undefined ->
                {output, <<"[]">>, [{"Content-Type", "application/json"}]};
            _Else ->
                %io:format("Thread Messages:  ~p~n", Messages),
                {json, [{success, true}, {code, 1}, {messages, Messages}]}
    end.


threadlist('GET', []) ->
    PhoneId = Req:param("phone_id"),

    ThreadList = boss_db:find(thread, [{dest_phone_id, PhoneId}]),
    case ThreadList of
            [] ->
                {output, <<"[]">>, [{"Content-Type", "application/json"}]};
            _Else ->

                {json, [{success, true}, {code, 1}, {threads, ThreadList}]}
    end.

messagelist('GET', []) ->

    PhoneId = Req:param("phone_id"),
    io:format("Getting messages for phone_id: ~p~n", [PhoneId]),
    GroupBy = Req:param("group_id"),
    SortBy = Req:param("sort_by"),

    Messages = boss_db:find(message, [{dest_phone, 'equals', PhoneId}]),
    case Messages of
            [] ->
                {output, <<"[]">>, [{"Content-Type", "application/json"}]};
            _Else ->

                {json, [{success, true}, {code, 1}, {messages, Messages}]}
    end.

messageindex('GET', []) ->
    ok.

message('POST', []) ->

    SourcePhone = Req:post_param("source_phone_id"),
    DestPhone = Req:post_param("dest_phone_id"),
    ThreadId = Req:post_param("thread_id"),
    MsgThread = boss_db:find(ThreadId),
    Text = Req:post_param("text"),

    error_logger:info_msg("Thread found as ~p", [MsgThread]),


    NewMessage = case MsgThread of
        undefined ->
            NewThread = thread:new(id, SourcePhone, DestPhone, erlang:now(), false),
            case NewThread:save() of
                {ok, SavedThread} ->
                    io:format("Saving thread as ~p", [SavedThread]),
                    message:new(id, SourcePhone, DestPhone, Text, erlang:now(), false, SavedThread:id())
            end;
        _Else ->
            message:new(id, SourcePhone, DestPhone, Text, erlang:now(), false, MsgThread:id())
    end,

    error_logger:info_msg("Message Saved as ~p", [NewMessage]),

    case NewMessage:save() of
        {ok, SavedMessage} ->
            {json, [{success, true}, {message, SavedMessage}]};
        {error, Reason} ->
            {json, [{success, false}]}
    end;

message('GET', []) ->
    MessageId = Req:post_param("message_id"),
    Message = boss_db:find(message, [{messageid, 'equals', MessageId}]),
    case Message of
        [] ->
            ok;
        _Else ->
            {json, [{success, true}, {code, 1}, {message, Message}]}
    end.
