#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pa ebin

main(Files) ->
    code:ensure_loaded(sql_lexer),
    code:ensure_loaded(sql_codec),
    lists:foreach(
      fun(File) ->
	      try
		  {ok, Data} = file:read_file(File),
		  {ok, Toks, _} = sql_lexer:string(binary_to_list(Data)),
		  {ok, _Result} = sql_codec:parse(Toks),
		  ok
	      catch _:{badmatch, {error, {Line, Mod, Reason}}} ->
		      format_error(File, Line, Mod, Reason);
		    _:{badmatch, {error, {Line, Mod, Reason}, Line}} ->
		      format_error(File, Line, Mod, Reason)
	      end
      end, Files).

format_error(File, Line, Mod, Reason) ->
    io:format("~s:~B: ~s~n", [File, Line, Mod:format_error(Reason)]).
