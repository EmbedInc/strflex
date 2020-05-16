{   Program TEST_STRFLEX
*
*   Program for testing the various facilities in the STRFLEX library.
}
program test_strflex;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'strflex.ins.pas';
%include 'builddate.ins.pas';

var
  strmem: strflex_mem_t;               {our flex string memory state}
  str: strflex_t;                      {the string under test}
  pos: strflex_pos_t;                  {position into the test string}
  pos_valid: boolean;                  {POS is valid, STR not changed out from under}
  cmds:                                {the possible commands, upper case}
    %include '(cog)lib/string8192.ins.pas';

  prompt:                              {prompt string for entering command}
    %include '(cog)lib/string4.ins.pas';
  cmd:                                 {command name, upper case}
    %include '(cog)lib/string_treename.ins.pas';
  parm:                                {command parameter}
    %include '(cog)lib/string_treename.ins.pas';
  pick: sys_int_machine_t;             {number of token picked from list}
  stat: sys_err_t;                     {completion status code}

label
  loop_cmd, done_cmd, err_extra, bad_cmd, bad_parm, err_cmparm, leave;

%include '(cog)lib/wout_local.ins.pas'; {define std out writing routines}
%include '(cog)lib/nextin_local.ins.pas'; {define command reading routines}
{
********************************************************************************
*
*   Subroutine COMMAND (NAME)
*
*   Add the command NAME to the list of possible commands.
}
procedure command (                    {add command to list of possible commands}
  in      name: string);               {command name}
  val_param; internal;

var
  cmd: string_var32_t;                 {var string command name}

begin
  cmd.max := size_char(cmd.str);       {init local var string}

  string_vstring (cmd, name, size_char(name)); {make var string version of command name}
  string_upcase (cmd);
  string_append_token (cmds, cmd);     {add this command to the list}
  end;
{
********************************************************************************
*
*   Start of main routine.
}
begin
  writeln ('Program STRFLEX, built ', build_dtm_str);
  writeln;

  string_cmline_end_abort;             {no command line arguments allowed}

  command ('HELP');                    {1}
  command ('?');                       {2}
  command ('QUIT');                    {3}
  command ('Q');                       {4}
  command ('APP');                     {5}
  command ('DEL');                     {6}
  command ('INS');                     {7}
  command ('INC');                     {8}
  command ('DEC');                     {9}
  command ('LAST');                    {10}
  command ('EOS');                     {11}
  command ('TO');                      {12}

  wout_init;                           {init output writing state}

  strflex_strmem_create (              {create mem state for flex string}
    util_top_mem_context,              {parent memory context}
    strmem);                           {new flex string memory state}
  strflex_str_create (strmem, str);    {create the flex string to test}
  pos_valid := false;                  {init to POS not valid}

  string_vstring (prompt, ': '(0), -1); {set command prompt string}
loop_cmd:                              {back here to get each new command}
  if not pos_valid then begin
    strflex_pos_init (str, pos);       {init position within the test string}
    pos_valid := true;
    end;

  lockout;
  strflex_show_pos (pos);              {show detailed string and position state}
  string_prompt (prompt);              {prompt the user for a command}
  newline := false;                    {indicate STDOUT not at start of new line}
  unlockout;

  string_readin (inbuf);               {get command from the user}
  newline := true;                     {STDOUT now at start of line}
  p := 1;                              {init BUF parse index}
  next_keyw (cmd, stat);               {extract command name into OPT}
  if string_eos(stat) then goto loop_cmd;
  if sys_error_check (stat, '', '', nil, 0) then begin
    goto loop_cmd;
    end;
  string_tkpick (cmd, cmds, pick);     {pick command name from list}
  case pick of                         {which command is it}
{
**********
*
*   HELP
}
1, 2: begin
  if not_eos then goto err_extra;

  lockout;                             {acquire lock for writing to output}
  writeln;
  writeln ('HELP or ?      - Show this list of commands.');
  writeln ('APP chars      - Append chars to end of string.');
  writeln ('DEL BAK|FWD    - Delete curr char, backward or forward after');
  writeln ('INS BEF|AFT chars - Insert chars before/after curr position');
  writeln ('INC            - Increment current position');
  writeln ('DEC            - Decrement current position');
  writeln ('LAST           - To last character of string');
  writeln ('EOS            - To past end of string');
  writeln ('TO n           - To character position N');
  writeln ('Q or QUIT      - Exit the program');
  unlockout;                           {release lock for writing to output}
  end;
{
**********
*
*   QUIT
}
3, 4: begin
  if not_eos then goto err_extra;

  goto leave;
  end;
{
**********
*
*   Unrecognized command name.
}
otherwise
    goto bad_cmd;
    end;

done_cmd:                              {done processing this command}
  if sys_error(stat) then goto err_cmparm;

  if not_eos then begin                {extraneous token after command ?}
err_extra:
    lockout;
    writeln ('Too many parameters for this command.');
    unlockout;
    end;
  goto loop_cmd;                       {back to process next command}

bad_cmd:                               {unrecognized or illegal command}
  lockout;
  writeln ('Huh?');
  unlockout;
  goto loop_cmd;

bad_parm:                              {bad parameter, parmeter in PARM}
  lockout;
  writeln ('Bad parameter "', parm.str:parm.len, '"');
  unlockout;
  goto loop_cmd;

err_cmparm:                            {parameter error, STAT set accordingly}
  lockout;
  sys_error_print (stat, '', '', nil, 0);
  unlockout;
  goto loop_cmd;

leave:
  end.
