# Server

### Runnig:
1.`./compile.sh`

2.`./start.sh 8000`


### Max Connections:
This is a fixed variable within the program which is set to <b>200.


### Requests & Responses:

`"HELO text\n"`
> <b>Response:<b>
>
	1. Respond with "HELO text\nIP:[ip address]
	\nPort:[port number]\nStudentID:[your student ID]\n"
	2. Close connection


`"ANYTHING goes here\n"`
> <b>Response:<b>
>
	No response

`"KILL_SERVICE\n"`
> Response:
>
	The server should shutdown.
