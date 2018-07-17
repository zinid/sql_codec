%% -----------------------------------------------------------------------------
%% SQL lexer. The main code is borrowed from sqlparse
%%
%% Copyright (c) 2012-18 K2 Informatics GmbH.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -----------------------------------------------------------------------------

Definitions.

W = \s\r\n
A = [A-Za-z0-9,_{W}]
OS = (.*|[{W}]*)

Rules.

% database link
(\"@[A-Za-z0-9_\$#\.@]+\")                          : {token, {'DBLINK', TokenLine, TokenChars}}.

% strings
(\'([^\']*(\'\')*)*\')                              : {token, {'STRING', TokenLine, unquote(TokenChars)}}.
(\"((\$|[^\"]*)*(\"\")*)*\")                        : {token, {'NAME', TokenLine, unquote(TokenChars)}}.
(`((\$|[^`]*)*(``)*)*`)                             : {token, {'NAME', TokenLine, unquote(TokenChars)}}.

% hint
((\/\*)[^\*\/]*(\*\/))                              : {token, {'HINT', TokenLine, TokenChars}}.

% punctuation
(!=|\^=|<>|<|>|<=|>=)                               : {token, {'COMPARISON', TokenLine, list_to_atom(TokenChars)}}.
([=\|\-\+\*\/\(\)\,\.\;]|(\|\|)|(div))              : {token, {list_to_atom(TokenChars), TokenLine}}.

% names
[A-Za-z][A-Za-z0-9_\$@~]*                           : match_any(TokenChars, TokenLen, TokenLine, ?RESERVED).

% parameters
(\:[A-Za-z0-9_\.][A-Za-z0-9_\.]*)                   : {token, {'PARAMETER', TokenLine, TokenChars}}.

% numbers
([0-9]+)                                            : {token, {'INTNUM', TokenLine, TokenChars}}.
((([\.][0-9]+)|([0-9]+[\.]?[0-9]*))([eE][+-]?[0-9]+)?[fFdD]?)
                                                    : {token, {'APPROXNUM', TokenLine, TokenChars}}.

% skips
([\s\t\r\n]+)                                       : skip_token.    %% white space

% comments
%((\-\-).*[\n])                                     : {token, {'COMMENT', TokenLine, TokenChars}}.
((\-\-).*[\n])                                      : skip_token.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Erlang code.

%% -----------------------------------------------------------------------------
%%
%% sql_lexer.erl: SQL - lexer.
%%
%% Copyright (c) 2012-18 K2 Informatics GmbH.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -----------------------------------------------------------------------------

-export([reserved_keywords/0]).

-define(RESERVED,
	#{"action" => 'ACTION',
	  "add" => 'ADD',
          "admin" => 'ADMIN',
          "all" => 'ALL',
          "alter" => 'ALTER',
          "and" => 'AND',
          "any" => 'ANY',
          "as" => 'AS',
          "asc" => 'ASC',
          "authentication" => 'AUTHENTICATION',
          "authorization" => 'AUTHORIZATION',
	  "autoincrement" => 'AUTO_INCREMENT',
	  "auto_increment" => 'AUTO_INCREMENT',
          "bag" => 'BAG',
          "begin" => 'BEGIN',
          "between" => 'BETWEEN',
          "bigint" => 'BIGINT',
          "bitmap" => 'BITMAP',
          "by" => 'BY',
          "call" => 'CALL',
          "cascade" => 'CASCADE',
          "case" => 'CASE',
          "character" => 'CHARACTER',
          "check" => 'CHECK',
          "close" => 'CLOSE',
          "cluster" => 'CLUSTER',
          "collate" => 'COLLATE',
          "commit" => 'COMMIT',
          "connect" => 'CONNECT',
          "constraint" => 'CONSTRAINT',
          "constraints" => 'CONSTRAINTS',
          "continue" => 'CONTINUE',
          "create" => 'CREATE',
          "cross" => 'CROSS',
          "current" => 'CURRENT',
          "cursor" => 'CURSOR',
          "default" => 'DEFAULT',
          "delegate" => 'DELEGATE',
          "delete" => 'DELETE',
          "desc" => 'DESC',
          "directory" => 'DIRECTORY',
          "distinct" => 'DISTINCT',
          "double" => 'DOUBLE',
          "drop" => 'DROP',
          "else" => 'ELSE',
          "elsif" => 'ELSIF',
          "end" => 'END',
          "engine" => 'ENGINE',
          "enterprise" => 'ENTERPRISE',
          "escape" => 'ESCAPE',
          "except" => 'EXCEPT',
          "execute" => 'EXECUTE',
          "exists" => 'EXISTS',
          "expire" => 'EXPIRE',
          "externally" => 'EXTERNALLY',
          "fetch" => 'FETCH',
	  "filter_with" => 'FILTER_WITH',
          "force" => 'FORCE',
          "foreign" => 'FOREIGN',
          "found" => 'FOUND',
          "from" => 'FROM',
          "full" => 'FULL',
          "globally" => 'GLOBALLY',
	  "goto" => 'GOTO',
          "grant" => 'GRANT',
          "group" => 'GROUP',
          "hashmap" => 'HASHMAP',
          "having" => 'HAVING',
          "hierarchy" => 'HIERARCHY',
          "identified" => 'IDENTIFIED',
	  "identity" => 'IDENTITY',
          "if" => 'IF',
          "in" => 'IN',
          "index" => 'INDEX',
          "indicator" => 'INDICATOR',
          "inner" => 'INNER',
          "insert" => 'INSERT',
          "intersect" => 'INTERSECT',
          "into" => 'INTO',
          "is" => 'IS',
          "join" => 'JOIN',
          "key" => 'KEY',
          "keylist" => 'KEYLIST',
          "language" => 'LANGUAGE',
          "left" => 'LEFT',
          "like" => 'LIKE',
          "local" => 'LOCAL',
          "log" => 'LOG',
          "materialized" => 'MATERIALIZED',
          "minus" => 'MINUS',
          "natural" => 'NATURAL',
          "no" => 'NO',
          "nocycle" => 'NOCYCLE',
          "none" => 'NONE',
	  "norm_with" => 'NORM_WITH',
          "not" => 'NOT',
          "null" => 'NULLX',
          "of" => 'OF',
          "on" => 'ON',
          "open" => 'OPEN',
          "option" => 'OPTION',
          "or" => 'OR',
          "order" => 'ORDER',
	  "ordered_set" => 'ORDERED_SET',
          "outer" => 'OUTER',
          "partition" => 'PARTITION',
          %%"password" => 'PASSWORD',
          "precision" => 'PRECISION',
          "preserve" => 'PRESERVE',
          "primary" => 'PRIMARY',
          "prior" => 'PRIOR',
          "privileges" => 'PRIVILEGES',
          "profile" => 'PROFILE',
          "public" => 'PUBLIC',
          "purge" => 'PURGE',
          "quota" => 'QUOTA',
          "real" => 'REAL',
          "references" => 'REFERENCES',
          "required" => 'REQUIRED',
          "restrict" => 'RESTRICT',
          "return" => 'RETURN',
          "returning" => 'RETURNING',
          "reuse" => 'REUSE',
          "revoke" => 'REVOKE',
          "right" => 'RIGHT',
          "role" => 'ROLE',
          "roles" => 'ROLES',
          "rollback" => 'ROLLBACK',
          "schema" => 'SCHEMA',
          "select" => 'SELECT',
          "set" => 'SET',
          "some" => 'SOME',
          "sqlerror" => 'SQLERROR',
          "start" => 'START',
          "storage" => 'STORAGE',
          "table" => 'TABLE',
          "tablespace" => 'TABLESPACE',
          "temporary" => 'TEMPORARY',
          "then" => 'THEN',
          "through" => 'THROUGH',
          "to" => 'TO',
          "truncate" => 'TRUNCATE',
          "union" => 'UNION',
          "unique" => 'UNIQUE',
          "unlimited" => 'UNLIMITED',
          "unsigned" => 'UNSIGNED',
          "update" => 'UPDATE',
          "user" => 'USER',
          "users" => 'USERS',
          "using" => 'USING',
          "values" => 'VALUES',
          "view" => 'VIEW',
          "when" => 'WHEN',
          "whenever" => 'WHENEVER',
          "where" => 'WHERE',
          "with" => 'WITH',
          "work" => 'WORK',
	  %% Functions
	  "abs" => 'ABS',
          "acos" => 'ACOS',
          "asin" => 'ASIN',
          "atan" => 'ATAN',
          "atan2" => 'ATAN2',
          "avg" => 'AVG',
          "bool_and" => 'BOOL_AND',
          "bool_or" => 'BOOL_OR',
          "corr" => 'CORR',
          "cos" => 'COS',
          "cosh" => 'COSH',
          "cot" => 'COT',
          "count" => 'COUNT',
          "covar_pop" => 'COVAR_POP',
          "covar_samp" => 'COVAR_SAMP',
          "decode" => 'DECODE',
          "lower" => 'LOWER',
          "ltrim" => 'LTRIM',
          "max" => 'MAX',
          "median" => 'MEDIAN',
          "min" => 'MIN',
          "nvl" => 'NVL',
          "regr_avgx" => 'REGR_AVGX',
          "regr_avgy" => 'REGR_AVGY',
          "regr_count" => 'REGR_COUNT',
          "regr_intercept" => 'REGR_INTERCEPT',
          "regr_r2" => 'REGR_R2',
          "regr_slope" => 'REGR_SLOPE',
          "regr_sxx" => 'REGR_SXX',
          "regr_sxy" => 'REGR_SXY',
          "regr_syy" => 'REGR_SYY',
          "selectivity" => 'SELECTIVITY',
          "sin" => 'SIN',
          "sinh" => 'SINH',
          "stddev" => 'STDDEV',
          "stddev_pop" => 'STDDEV_POP',
          "stddev_samp" => 'STDDEV_SAMP',
          "sum" => 'SUM',
          "tan" => 'TAN',
          "tanh" => 'TANH',
          "to_char" => 'TO_CHAR',
          "to_date" => 'TO_DATE',
          "trunc" => 'TRUNC',
          "upper" => 'UPPER',
          "variance" => 'VARIANCE',
          "var_pop" => 'VAR_POP',
          "var_samp" => 'VAR_SAMP'}).

reserved_keywords() ->
    dict:values(?RESERVED).

match_any(TokenChars, TokenLen, TokenLine, Reserved) ->
    case maps:get(string:to_lower(TokenChars), Reserved, undefined) of
	undefined ->
	    {token, {'NAME', TokenLen, TokenChars}};
	T ->
	    {token, {T, TokenLine}}
    end.

unquote([C|_] = S) ->
    string:strip(S, both, C).

%% Local Variables:
%% mode: erlang
%% End:
%% vim: set filetype=erlang tabstop=8:
