{   Routines for inserting characters into flex strings.
}
module strflex_ins;
define strflex_insbef_char;
define strflex_insbef_vstr;
define strflex_insbef_str;
define strflex_insaft_char;
define strflex_insaft_vstr;
define strflex_insaft_str;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Local subroutine ADD_BLOCK_FIRST (POS)
*
*   Add the first block to a flex string that has no blocks.  The block will be
*   empty.  POS is returned at the end of the string, but at character 1 of the
*   new (empty) block.
*
*   It is the caller's resposibility to make sure the string has no blocks.
}
procedure add_block_first (            {add first block to empty string}
  in out  pos: strflex_pos_t);         {will be a pos 1 in the empty block}
  val_param; internal;

begin
  strflex_block_new (                  {create new block}
    pos.str_p^.strmem_p^,              {flex string memory state}
    pos.blk_p);                        {returned pointer to new empty block}

  pos.str_p^.first_p := pos.blk_p;     {set as first and last block of the string}
  pos.str_p^.last_p := pos.blk_p;
  pos.blkn := 1;                       {at index 1 of this empty block}
  end;
{
********************************************************************************
*
*   Local subroutine ADD_BLOCK_BEF (POS)
*
*   Add a empty block before the one POS is in.  POS is not changed.  POS must
*   be pointing to a block.
}
procedure add_block_bef (              {add new empty block before current}
  in out  pos: strflex_pos_t);         {must be in a block, not changed}
  val_param; internal;

var
  blk_p: strflex_block_p_t;            {pointer to the new block}

begin
  strflex_block_new (pos.str_p^.strmem_p^, blk_p); {get a new empty block}
{
*   Insert the new block into the chain before the current block.
}
  blk_p^.next_p := pos.blk_p;          {new block points forward to curr block}

  blk_p^.prev_p := pos.blk_p^.prev_p;  {set backward links}
  pos.blk_p^.prev_p := blk_p;

  if blk_p^.prev_p = nil
    then begin                         {new block is first block of chain}
      pos.str_p^.first_p := blk_p;
      end
    else begin                         {chaining after existing block}
      blk_p^.prev_p^.next_p := blk_p;
      end
    ;
  end;
{
********************************************************************************
*
*   Local subroutine ADD_BLOCK_AFT (POS)
*
*   Add a empty block after the one POS is in.  POS is not changed.  POS must
*   be pointing to a block.
}
procedure add_block_aft (              {add new empty block after current}
  in out  pos: strflex_pos_t);         {must be in a block, not changed}
  val_param; internal;

var
  blk_p: strflex_block_p_t;            {pointer to the new block}

begin
  strflex_block_new (pos.str_p^.strmem_p^, blk_p); {get a new empty block}
{
*   Insert the new block into the chain after the current block.
}
  blk_p^.prev_p := pos.blk_p;          {new block points backward to curr block}

  blk_p^.next_p := pos.blk_p^.next_p;  {set forward links}
  pos.blk_p^.next_p := blk_p;

  if blk_p^.next_p = nil
    then begin                         {new block is at end of chain}
      pos.str_p^.last_p := blk_p;
      end
    else begin
      blk_p^.next_p^.prev_p := blk_p;
      end
    ;
  end;
{
********************************************************************************
*
*   Local subroutine ADD_CHAR (BLK, IND)
*
*   Add a new character to the block BLK at index IND.  Characters at a higher
*   index within the block, if any, are shifted to the end of the block.
*
*   The block must not be full, and IND must not be more than one past the last
*   used index.
*
*   The character at the new vacant position IND is not initialized.
}
procedure add_char (                   {add char position to block, shift as needed}
  in out  blk: strflex_block_t;        {block to add char to, must not be full}
  in      ind: sys_int_machine_t);     {index to create new char position at}
  val_param; internal;

var
  ii: sys_int_machine_t;

begin
  blk.nch := blk.nch + 1;              {grow the block by one character}

  if ind >= blk.nch then return;       {no later characters to move ?}

  for ii := blk.nch downto ind+1 do begin {shift the later characters up}
    blk.ch[ii] := blk.ch[ii-1];
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_INSBEF_CHAR (POS, C)
*
*   Insert the character C into the flex string immediately before the position
*   POS.  POS will remain on the original character.
}
procedure strflex_insbef_char (        {insert character before current}
  in out  pos: strflex_pos_t;          {pos to insert before, returned on original char}
  in      c: char);                    {character to insert}
  val_param;

var
  blk_p: strflex_block_p_t;            {scratch pointer to a string block}

label
  ins_this, into_next;

begin
  pos.ind := pos.ind + 1;              {update index to stay on existing char}
  pos.str_p^.len := pos.str_p^.len + 1; {the string will have one more character}

  if pos.str_p^.first_p = nil then begin {the string has no blocks ?}
    add_block_first (pos);             {make one}
    end;

  if pos.blk_p^.nch < strflex_blkchars then begin {current block is not full ?}
ins_this:                              {insert into current block}
    add_char (pos.blk_p^, pos.blkn);   {make new character position at BLKN}
    pos.blk_p^.ch[pos.blkn] := c;      {fill in the new character}
    pos.blkn := pos.blkn + 1;          {one forward to the original character}
    return;
    end;
{
*   The current block is full.
*
*   Add the character at the end of the previous block if we are at the start of
*   the current block, and the previous block has room.
}
  blk_p := pos.blk_p^.prev_p;          {get pointer to previous block}
  if
      (pos.blkn = 1) and               {inserting before start of this block ?}
      (blk_p <> nil) and then          {there is a previous block ?}
      (blk_p^.nch < strflex_blkchars)  {previous block is not full ?}
      then begin
    blk_p^.nch := blk_p^.nch + 1;      {make one more character in this block}
    blk_p^.ch[blk_p^.nch] := c;        {fill in the character}
    return;
    end;
{
*   Slosh characters into the next block if it has room.
}
  blk_p := pos.blk_p^.next_p;          {get pointer to next block}
  if
      (blk_p <> nil) and then          {there is a next block ?}
      (blk_p^.nch < strflex_blkchars)  {the next block is not full ?}
      then begin
    add_char (blk_p^, 1);              {make empty slot at start of next block}
into_next:                             {move chars into next block to make room}
    blk_p^.ch[1] := pos.blk_p^.ch[pos.blkn]; {copy last char of this block into next}
    if pos.blkn = pos.blk_p^.nch then begin {moved char was current char ?}
      pos.blk_p^.ch[pos.blk_p^.nch] := c; {fill vacated slot with new char}
      pos.blk_p := blk_p;              {original char is now first in next block}
      pos.blkn := 1;
      return;
      end;
    blk_p^.nch := blk_p^.nch - 1;      {update number of chars now in curr block}
    goto ins_this;                     {insert new char into the current block}
    end;
{
*   Both this and the next block are full.  Create a new block.
}
  if pos.blkn = 1
    then begin                         {adding right before this block}
      add_block_bef (pos);             {create new empty previous block}
      blk_p := pos.blk_p^.prev_p;      {get pointer to the new empty block}
      blk_p^.ch[1] := c;               {set new char as first in new block}
      blk_p^.nch := 1;
      end
    else begin                         {adding in middle or end of curr block}
      add_block_aft (pos);             {create new empty next block}
      goto into_next;                  {slosh into next block to make room}
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_INSBEF_VSTR (POS, VSTR)
*
*   Insert a var string before the position POS.  POS will remain on the
*   character that the string is inserted before.
}
procedure strflex_insbef_vstr (        {insert var string before current char}
  in out  pos: strflex_pos_t;          {pos to insert before, returned on original char}
  in      vstr: univ string_var_arg_t); {string to insert}
  val_param;

var
  ii: sys_int_machine_t;

begin
  for ii := 1 to vstr.len do begin
    strflex_insbef_char (pos, vstr.str[ii]);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_INSBEF_STR (POS, S)
*
*   Insert a Pascal/C string before the position POS.  POS will remain on the
*   character that the string is inserted before.
}
procedure strflex_insbef_str (         {insert Pascal/C string before current char}
  in out  pos: strflex_pos_t;          {pos to insert before, returned on original char}
  in      s: string);                  {string to insert, blank padded or NULL term}
  val_param;

var
  vstr: string_var80_t;

begin
  vstr.max := size_char(vstr.str);     {init local var string}

  string_vstring (vstr, s, -1);        {convert input string to a var string}
  strflex_insbef_vstr (pos, vstr);     {insert the var string before current pos}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_INSAFT_CHAR (POS, C)
*
*   Insert the character C into the flex string after position POS, then set the
*   position to the new character.
*
*   If POS is at the end of the string, then the new character will be added to
*   the end of the string, and POS returned on the new character.
}
procedure strflex_insaft_char (        {insert character after current}
  in out  pos: strflex_pos_t;          {pos to insert after, returned at new char}
  in      c: char);                    {character to insert}
  val_param;

var
  blk_p: strflex_block_p_t;            {scratch pointer to a flex string block}

label
  ins_this, into_next;

begin
  if pos.str_p^.first_p = nil then begin {the string has no blocks ?}
    add_block_first (pos);             {make one}
    end;
{
*   Handle special case of adding to empty string.
}
  if pos.str_p^.len <= 0 then begin    {the string is empty ?}
    pos.blk_p^.ch[1] := c;             {fill in the character at start of block}
    pos.blk_p^.nch := 1;               {this block now has one character}
    pos.str_p^.len := 1;               {the string now has one character}
    pos.ind := 1;                      {set position within string}
    pos.blkn := 1;                     {set position within block}
    return;
    end;

  pos.str_p^.len := pos.str_p^.len + 1; {update final string length}
{
*   The existing string is not empty, and the string length has already been
*   updated.
*
*   Handle case where the current block has room for the new character.
}
  if pos.blk_p^.nch < strflex_blkchars then begin
ins_this:                              {add the new char to the current block}
    add_char (pos.blk_p^, pos.blkn);   {make room at the current position}
    pos.blk_p^.ch[pos.blkn] := c;      {write char into vacated spot}
    return;
    end;
{
*   The current block is full.
*
*   If the next block has room, slosh one character into it from the current
*   block, then add the new character to the current block.
}
  blk_p := pos.blk_p^.next_p;          {get pointer to the next block}
  if
      (blk_p <> nil) and then          {there is a next block ?}
      (blk_p^.nch < strflex_blkchars)  {the next block has room ?}
      then begin
into_next:                             {move a char into the next block}
    add_char (blk_p^, 1);              {vacate first position in next block}
    if pos.blkn >= pos.blk_p^.nch then begin {at end of current block ?}
      blk_p^.ch[1] := c;               {put new char at start of next block}
      pos.blk_p := blk_p;              {update position to the new char}
      pos.blkn := 1;
      return;
      end;
    blk_p^.ch[1] := pos.blk_p^.ch[pos.blk_p^.nch]; {last char into next block}
    pos.blk_p^.nch := pos.blk_p^.nch - 1;
    goto ins_this;                     {current block now has room}
    end;
{
*   Add a new block after the current.
}
  add_block_aft (pos);                 {create new empty block after current}
  goto into_next;                      {move char into next block to make room}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_INSAFT_VSTR (POS, VSTR)
*
*   Insert a var string after the position POS.  POS will be updated to the last
*   character of the inserted string.
}
procedure strflex_insaft_vstr (        {insert var string after current char}
  in out  pos: strflex_pos_t;          {pos to insert after, at last new char}
  in      vstr: univ string_var_arg_t); {string to insert}
  val_param;

var
  ii: sys_int_machine_t;

begin
  for ii := 1 to vstr.len do begin
    strflex_insaft_char (pos, vstr.str[ii]);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_INSAFT_STR (POS, S)
*
*   Insert the Pascal/C string after the position POS.  POS will be updated to
*   the last character of the inserted string.
}
procedure strflex_insaft_str (         {insert Pascal/C string after current char}
  in out  pos: strflex_pos_t;          {pos to insert after, at last new char}
  in      s: string);                  {string to insert, blank padded or NULL term}
  val_param;

var
  vstr: string_var80_t;

begin
  vstr.max := size_char(vstr.str);     {init local var string}

  string_vstring (vstr, s, -1);        {convert input string to a var string}
  strflex_insaft_vstr (pos, vstr);     {insert the var string after current pos}
  end;
