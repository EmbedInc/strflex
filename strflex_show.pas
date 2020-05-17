{   Routines to show various internal state, usually for debugging.
}
module strflex_show;
define strflex_show_str;
define strflex_show_pos;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Local subroutine WADR (PNT)
*
*   Write a address in HEX.
}
procedure wadr (                       {write address}
  in      pnt: univ_ptr);              {pointer to the address}
  val_param; internal;

var
  tk: string_var32_t;

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_int32h (tk, sys_int_adr_t(pnt)); {make 8 char HEX string}
  write (tk.str:tk.len);               {write it to standard output}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_SHOW_STR (STR)
*
*   Show the details and internal state of the flex string STR to standard
*   output.
}
procedure strflex_show_str (           {show detailed flex string state}
  in      str: strflex_t);             {string to show internal details of}
  val_param;

var
  s: string_var8192_t;                 {scratch var string}
  ii: sys_int_machine_t;               {scratch integer and loop counter}
  blk_p: strflex_block_p_t;            {pointer to current string block}

begin
  s.max := size_char(s.str);

  strflex_copy_t_vstr (str, s);        {get string contents into S}
  writeln ('String "', s.str:s.len, '"');

  ii := 0;                             {init number of blocks in the string}
  blk_p := str.first_p;                {init to first block in string}
  while blk_p <> nil do begin          {loop over all the blocks}
    ii := ii + 1;                      {count one more block in the string}
    blk_p := blk_p^.next_p;            {to next block}
    end;                               {back to do this next block}

  write ('  length ', str.len, ', ', ii, ' block');
  if ii <> 1 then begin
    write ('s');
    end;
  write (', first ');
  wadr (str.first_p);
  write (', last ');
  wadr (str.last_p);
  writeln;

  blk_p := str.first_p;                {init to first block in string}
  while blk_p <> nil do begin          {loop over all the blocks}
    write ('  block ');
    wadr (blk_p);
    write (', prev ');
    wadr (blk_p^.prev_p);
    write (', next ');
    wadr (blk_p^.next_p);
    writeln;

    write ('    ', blk_p^.nch, ' char');
    if blk_p^.nch <> 1 then write ('s');
    if blk_p^.nch > 0 then begin
      write (': "');
      for ii := 1 to blk_p^.nch do begin
        write (blk_p^.ch[ii]);
        end;
      write ('"');
      end;
    writeln;

    blk_p := blk_p^.next_p;            {to next block}
    end;                               {back to do this next block}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_SHOW_POS (POS)
*
*   Show the details of a flex string and the position within it to standard
*   output.
}
procedure strflex_show_pos (           {show detailed string and position state}
  in      pos: strflex_pos_t);         {position within the string}
  val_param;

begin
  strflex_show_str (pos.str_p^);       {show the string}

  write ('  At string index ', pos.ind, ', block ');
  wadr (pos.blk_p);
  write (' char ', pos.blkn);
  if strflex_pos_eos (pos)
    then begin                         {past end of string}
      write (' EOS');
      end
    else begin                         {at a real character}
      write (' "', strflex_char(pos), '"');
      end
    ;
  writeln;
  end;
