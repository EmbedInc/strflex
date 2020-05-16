{   Routines that deal with flex string memory blocks.
}
module strflex_block;
define strflex_block_new;
define strflex_block_unuse;
define strflex_block_remove;
%include 'strflex2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRFLEX_BLOCK_NEW (STRMEM, BLOCK_P)
*
*   Get a new or unused flex string memory block.  STRMEM is the memory state to
*   get the block from.  BLOCK_P is returned pointing to the new block.  The new
*   block will be initialized to empty and unlinked.
}
procedure strflex_block_new (          {get a new or free flex string memory block}
  in out  strmem: strflex_mem_t;       {memory state to get the block from}
  out     block_p: strflex_block_p_t); {pointer to new block, block initialized}
  val_param;

var
  ii: sys_int_machine_t;

begin
  if strmem.free_p <> nil
    then begin                         {a free block is available, return it}
      block_p := strmem.free_p;        {return the first block on the free chain}
      strmem.free_p := strmem.free_p^.next_p; {remove this block from free chain}
      end
    else begin                         {no free block available, allocate a new one}
      util_mem_grab (                  {allocate a new block}
        sizeof(block_p^),              {amount of memory to allocate}
        strmem.mem_p^,                 {memory context to allocate under}
        false,                         {will not need to individually deallocate}
        block_p);                      {returned pointer to the new memory}
      end
    ;

  block_p^.prev_p := nil;              {initialize the block to empty}
  block_p^.next_p := nil;
  block_p^.nch := 0;
  for ii := 1 to strflex_blkchars do begin
    block_p^.ch[ii] := chr(0);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_BLOCK_UNUSE (STRMEM, BLOCK_P)
*
*   Release a flex string memory block by indicating it is not used.  STRMEM is
*   the memory state the block was created from.  BLOCK_P points to the block on
*   entry, and is returned NIL
}
procedure strflex_block_unuse (        {indicate a flex string mem block no longer used}
  in out  strmem: strflex_mem_t;       {memory state the block came from}
  in out  block_p: strflex_block_p_t); {pointer to the block, returned NIL}
  val_param;

begin
  block_p^.next_p := strmem.free_p;    {link new block to start of free chain}
  strmem.free_p := block_p;
  block_p := nil;                      {invalidate caller's pointer to the block}
  end;
{
********************************************************************************
*
*   Subroutine STRFLEX_BLOCK_REMOVE (STR, BLOCK_P)
*
*   Remove a block from a string by unlinking it, then release the block by
*   unusing it.  STR is the flex string the block is in.
*
*   BLOCK_P is a pointer to the block.  BLOCK_P will be copied before use, so
*   can be one of the pointers that get modified when the block is unlinked.
}
procedure strflex_block_remove (       {remove block from string, release block}
  in out  str: strflex_t;              {string the block is in}
  in      block_p: strflex_block_p_t); {pointer to block, copied before use}
  val_param;

var
  blk_p: strflex_block_p_t;            {local copy of pointer to the block}

begin
  blk_p := block_p;                    {make local copy of pointer to the block}
  if blk_p = nil then return;          {no block, nothing to do ?}

  if blk_p^.prev_p = nil
    then begin                         {this is first block in chain}
      str.first_p := blk_p^.next_p;
      end
    else begin                         {there is a previous block}
      blk_p^.prev_p^.next_p := blk_p^.next_p;
      end
    ;

  if blk_p^.next_p = nil
    then begin                         {this is last block in chain}
      str.last_p := blk_p^.prev_p;
      end
    else begin                         {there is a following block}
      blk_p^.next_p^.prev_p := blk_p^.prev_p;
      end;
    ;

  strflex_block_unuse (str.strmem_p^, blk_p); {the block is now unused}
  end;
