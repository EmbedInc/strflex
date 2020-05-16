module strflex_clear;
define strflex_clear;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_CLEAR (STR)
*
*   Clear the string to 0 length.
}
procedure strflex_clear (              {clear existing string to empty}
  in out  str: strflex_t);             {string to clear, will have 0 length}
  val_param;

var
  blk_p: strflex_block_p_t;            {pointer to current string block}
  next_p: strflex_block_p_t;           {pointer to next block in list}

begin
  blk_p := str.first_p;                {init to first block in list}
  while blk_p <> nil do begin          {loop over all the blocks in the string}
    next_p := blk_p^.next_p;           {save pointer to next block}
    strflex_block_unuse (str.strmem_p^, blk_p); {release this block}
    blk_p := next_p;                   {on to next block}
    end;                               {back to handle this next block}

  str.first_p := nil;                  {update the string state}
  str.last_p := nil;
  str.len := 0;
  end;
