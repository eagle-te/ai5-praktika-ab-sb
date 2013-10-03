%%%-------------------------------------------------------------------
%%% @author Sven
%%% @copyright (C) 2013, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Okt 2013 22:28
%%%-------------------------------------------------------------------
-module(messageServer).
-author("Sven").

%% API
-export([doStartUp/1,doStartUp/0]).


%% VERTEILTES ERLANG(for shorties mit nodes):
%% node wird durch -sname <parameter> gesetzt, host ist der Rechnername || longname warscheinlich über verteilte netze
%% <Prozessname> wird durch register(<Prozessname>,<ProzessID>) festgelegt, ProzessID wird durch den Aufruf spawn/1 übergeben
%% {Prozessname, node@host}! {ProzessId,{Message}}.
%% BEISPIEL:
%% {tipOfTheDaymessageServer,messageServer@PIGPEN} ! {prozessname_vom_sender,{getMsgId,node()}}.

doStartUp() ->
  ServerPid = spawn(fun() -> doStartUp([]) end),
    register(tipOfTheDaymessageServer,ServerPid),
  ServerPid
.
doStartUp(Args) ->
  DefaultConfigFile = "serverconfig.cfg",
  ConfigFile = file:consult(DefaultConfigFile),
  case ConfigFile of
    {ok,ConfigList} ->
      ServerTimeout = get_value_of(serverTimeout,ConfigList),
      ClientTimeout = get_value_of(clientTimeout,ConfigList),
      MaxMessageCount = get_value_of(maxMessageCount,ConfigList),

      debugOutput("ConfigList",ConfigList),
      debugOutput("ServerTimeout",ServerTimeout),
      debugOutput("ClientTimeout",ClientTimeout),
      debugOutput("MaxMessageCount",MaxMessageCount),

      {ok,ST} = ServerTimeout,
      {ok,CT} = ClientTimeout,
      {ok,MMC} = MaxMessageCount,
      case true of
        true ->
          MaxIdleTimeServer_TimerRef = erlang:start_timer(ST,self(),shutdownTimeout),

          %%(Clients,DeliveryQueue,HoldbackQueue,MaxIdleTimeServer,MaxIdleTimeServer_TimerRef,ClientTimeout,MaxDQSize,MsgID)
          serverLoop([],[{12,{12,"Text qwe 121212,",12331}},{11,{11,"Text qwe 8888,",1111}},{10,{10,"Text qwe 101019,",12331}}]
            ,[],ST,MaxIdleTimeServer_TimerRef,CT,MMC,0);
        false -> io:format(" reason :~p\n", ["Configfile values arent ok!"])

      end;

    %% enoent seams to be the file not found / exsists error, see file:consult(...) docu
    {error,enoent} ->
      defaultServerSetup(DefaultConfigFile),
      doStartUp(Args);
    {error,ErrMsg}->
      io:format("Loading config file failed, reason :~p\n", [ErrMsg])
  end, 0
.

defaultServerSetup(FileName) ->
  InitConfig = "{serverTimeout, 400000}.\n{clientTimeout, 12000}.\n{maxMessageCount, 125}.\n",
  file:write_file(FileName, InitConfig, [append])
.
%%%%  aus der BA_Erlang von Klauck entnommen
get_value_of(_Key, []) ->
  {error, not_found};
get_value_of(Key, [{Key, Value} | _Tail]) ->
  {ok, Value};
get_value_of(Key, [{_Other, _Value} | Tail]) ->
  get_value_of(Key, Tail).

getLastMessageOfClient(Clients, RechnerID) ->
8.

setLastMessageOfClient(Clients, RechnerID, NewLastSendedMessageID) ->
  0.
addMesseageToHBQ(HoldbackQueue, MsgID, Msg, ReceiveTime) ->
  erlang:error(not_implemented).

%% DeliveryQueue(sortedlist)  :: [{ElemNr,{ID,Msg,DeliveryTime}}]
%% HoldbackQueue(sortedlist) :: [{ElemNr,{ID,Msg,ReceiveTime}}]
%% Clients :: [{RechnerID,{lastSendedMessageID,TimerRef}}]

sendMessage(From,Client, DeliveryQueue ) ->
  %%%% Wir kennen den Client
  {RechnerID,{LastSendedMessageID,TimerRef}} = Client,
  HighestMessageID = werkzeug:maxNrSL(DeliveryQueue),
  LowestMessageID = werkzeug:minNrSL(DeliveryQueue),

  case LastSendedMessageID < HighestMessageID andalso HighestMessageID >= 0 of
    %%% es gibt mindestens eine neue Message
    true ->
      case LastSendedMessageID >= LowestMessageID of
        true ->
          {Nr,{ID,Msg,_DeliveryTime}} = werkzeug:findSL(DeliveryQueue,LastSendedMessageID + 1);
        false ->
          {Nr,{ID,Msg,_DeliveryTime}} = werkzeug:findSL(DeliveryQueue,LowestMessageID)
      end,

      {From,RechnerID} ! {getMsg,ID, Msg,(HighestMessageID-ID) > 0},
      debugOutput("send Message",{getMsg,ID, Msg,(HighestMessageID-ID) > 0}),
      {RechnerID,{ID,TimerRef}};

    %%% es keine neuen  Messages
    false ->
      {From,RechnerID} ! {getMsg,-1, "dummy message ..."},
      debugOutput("send Message",{getMsg,-1, "dummy message ..."}),
      {RechnerID,{LastSendedMessageID,TimerRef}}
  end
.

serverLoop(Clients,DeliveryQueue,HoldbackQueue,MaxIdleTimeServer,MaxIdleTimeServer_TimerRef,ClientTimeout,MaxDQSize,MsgID) ->
  receive
    {From,{getMsgId,RechnerID}} ->
      debugOutput("getMsgId called",From),
      NewMsgID = MsgID + 1,
      debugOutput("send getMsgId ",[{From,RechnerID},{getMsgId,NewMsgID}]),
      serverLoop(Clients,DeliveryQueue,HoldbackQueue,MaxIdleTimeServer,MaxIdleTimeServer_TimerRef,ClientTimeout,MaxDQSize,NewMsgID);


    %%% mit {tipOfTheDaymessageServer,'messageServer@Sven-PC'} ! {eval_loop,{getMsg,node()}}. aufrufen
    %%% bei aktuellem Setup funktioniert es
    {From,{getMsg,RechnerID}} ->
      debugOutput("getMsg called",From),
      debugOutput("current Client",werkzeug:findSL(Clients,RechnerID)),
      case werkzeug:findSL(Clients,RechnerID) of
          %%%% Wir kennen den Client noch nicht !
          {-1,nok} ->
              Client = sendMessage(From,{RechnerID,{-1, erlang:start_timer(ClientTimeout,self(),clientTimeout)}},DeliveryQueue),
              NewClients = werkzeug:pushSL(Clients,Client);
          %%% Wir kennen den Client !
          {RechnerID,{LastSendedMessageID,TimerRef}} ->
              NewTimerRef = refreshTimer(TimerRef,ClientTimeout,clientTimeout),
              Client = sendMessage(From,{RechnerID,{LastSendedMessageID,NewTimerRef}},DeliveryQueue),
              NewClients = werkzeug:pushSL(lists:filter(fun(Item)-> {ItemRechnerID,{_MsgID,_TimerRef}} = Item,  RechnerID =/= ItemRechnerID end,Clients),Client)
      end,
      debugOutput("updated Client",Client),
      serverLoop(NewClients,DeliveryQueue,HoldbackQueue,MaxIdleTimeServer,MaxIdleTimeServer_TimerRef,ClientTimeout,MaxDQSize,MsgID);


    {From,{dropMsg,SenderID, AbsendeZeit, Msg,MsgID}}->
      debugOutput("dropMsg called",From),

      NewHBQ = addMesseageToHBQ(HoldbackQueue, MsgID, Msg, time()),
      serverLoop(Clients,DeliveryQueue,NewHBQ,MaxIdleTimeServer,MaxIdleTimeServer_TimerRef,ClientTimeout,MaxDQSize,MsgID);

    {timeout,ClientTimerRef,clientTimeout} ->
      debugOutput("client timeout",ClientTimerRef),
      NewClients = lists:filter(fun(Item)-> {_RechnerID,{_MsgID,TimerRef}} = Item, TimerRef =/= ClientTimerRef end,Clients),
      serverLoop(NewClients,DeliveryQueue,HoldbackQueue,MaxIdleTimeServer,MaxIdleTimeServer_TimerRef,ClientTimeout,MaxDQSize,MsgID);
    {timeout,ServerTimerRef,shutdownTimeout} ->
      debugOutput("server timeout",[]);

    ANY -> debugOutput("server recived ",ANY)
  end
.
debugOutput(MSG,ANY) ->
  io:format("debug output: ~p :: ~p\n", [MSG,ANY])
.



refreshTimer(TimerRef,TimeInMsec,Msg) ->
  erlang:cancel_timer(TimerRef),
  erlang:start_timer(TimeInMsec,self(),Msg)
.