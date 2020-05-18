{   Public include file for the flexible string library.  Flexible strings use
*   storage in small incremental chunks.  The strings grow arbitrarily long, and
*   characters can be inserted and deleted on the fly.
}
const
  strflex_subsys_k = -71;              {subsystem ID for the STRFLEX library}

  strflex_blkchars = 32;               {max characters a block can hold}

type
  strflex_mem_p_t = ^strflex_mem_t;
  strflex_p_t = ^strflex_t;
  strflex_block_p_t = ^strflex_block_t;

  strflex_mem_t = record               {dynamic memory info for a set of flex strings}
    mem_p: util_mem_context_p_t;       {points to dynamic memory context}
    free_p: strflex_block_p_t;         {points to start of free blocks chain}
    end;

  strflex_t = record                   {base descriptor for a flex string}
    strmem_p: strflex_mem_p_t;         {points to dynamic memory state}
    first_p: strflex_block_p_t;        {points to first block of the string}
    last_p: strflex_block_p_t;         {points to last block of the string}
    len: sys_int_machine_t;            {string length}
    end;

  strflex_block_t = record             {one block of a string}
    prev_p: strflex_block_p_t;         {points to previous block of this string}
    next_p: strflex_block_p_t;         {poitns to next block of this string}
    nch: sys_int_machine_t;            {number of characters in this block}
    ch: array[1 .. strflex_blkchars] of char; {characters of this block}
    end;

  strflex_pos_p_t = ^strflex_pos_t;
  strflex_pos_t = record               {character position within a flex string}
    str_p: strflex_p_t;                {points to the string}
    ind: sys_int_machine_t;            {index into string, LEN+1 for past end}
    blk_p: strflex_block_p_t;          {pnt to curr block, NIL for no blocks}
    blkn: sys_int_machine_t;           {index into block, 1 when no blocks}
    end;
{
*   Functions and subroutines.
}
procedure strflex_append_char (        {append a character to the end of a flex string}
  in out  str: strflex_t;              {flex string to append to}
  in      c: char);                    {character to append to end of string}
  val_param; extern;

procedure strflex_append_str (         {append Pascal/C string to end of flex string}
  in out  str: strflex_t;              {flex string to append to}
  in      s: string);                  {string to append, blank padded or NULL term}
  val_param; extern;

procedure strflex_append_t_vstr (      {append flex string to end of var string}
  in      str: strflex_t;              {source flex string}
  in out  vstr: univ string_var_arg_t); {destination var string}
  val_param; extern;

procedure strflex_append_vstr (        {append var string to end of flex string}
  in out  str: strflex_t;              {flex string to append to}
  in      vstr: univ string_var_arg_t); {string to append}
  val_param; extern;

function strflex_char (                {get string character at current position}
  in      pos: strflex_pos_t)          {position into string}
  :char;                               {character at position, NULL past end of string}
  val_param; extern;

function strflex_char_inc (            {get character at curr position, then increment pos}
  in out  pos: strflex_pos_t)          {position into string}
  :char;                               {character at position, NULL past end of string}
  val_param; extern;

procedure strflex_clear (              {clear existing string to empty}
  in out  str: strflex_t);             {string to clear, will have 0 length}
  val_param; extern;

procedure strflex_copy_f_vstr (        {copy var string into flex string}
  in      vstr: univ string_var_arg_t; {source var string}
  in out  str: strflex_t);             {destination flex string}
  val_param; extern;

procedure strflex_copy_f_str (         {copy Pascal/C string into flex string}
  in      s: string;                   {source string}
  in out  str: strflex_t);             {destination flex string}
  val_param; extern;

procedure strflex_copy_t_vstr (        {copy flex string into var string}
  in      str: strflex_t;              {source flex string}
  in out  vstr: univ string_var_arg_t); {destination var string}
  val_param; extern;

procedure strflex_del_bak (            {delete curr char, back to previous}
  in out  pos: strflex_pos_t);         {position into string}
  val_param; extern;

procedure strflex_del_fwd (            {delete curr char, forward to next}
  in out  pos: strflex_pos_t);         {position into string}
  val_param; extern;

procedure strflex_insaft_char (        {insert character after current}
  in out  pos: strflex_pos_t;          {pos to insert after, returned at new char}
  in      c: char);                    {character to insert}
  val_param; extern;

procedure strflex_insaft_str (         {insert Pascal/C string after current char}
  in out  pos: strflex_pos_t;          {pos to insert after, at last new char}
  in      s: string);                  {string to insert, blank padded or NULL term}
  val_param; extern;

procedure strflex_insaft_vstr (        {insert var string after current char}
  in out  pos: strflex_pos_t;          {pos to insert after, at last new char}
  in      vstr: univ string_var_arg_t); {string to insert}
  val_param; extern;

procedure strflex_insbef_char (        {insert character before current}
  in out  pos: strflex_pos_t;          {pos to insert before, returned on original char}
  in      c: char);                    {character to insert}
  val_param; extern;

procedure strflex_insbef_str (         {insert Pascal/C string before current char}
  in out  pos: strflex_pos_t;          {pos to insert before, returned on original char}
  in      s: string);                  {string to insert, blank padded or NULL term}
  val_param; extern;

procedure strflex_insbef_vstr (        {insert var string before current char}
  in out  pos: strflex_pos_t;          {pos to insert before, returned on original char}
  in      vstr: univ string_var_arg_t); {string to insert}
  val_param; extern;

function strflex_len (                 {get string length}
  in      str: strflex_t)              {the string}
  :sys_int_machine_t;                  {0-N number of characters in the string}
  val_param; extern;

function strflex_pos (                 {get current string position}
  in      pos: strflex_pos_t)          {string position descriptor}
  :sys_int_machine_t;                  {1-N, never more than one past end}
  val_param; extern;

procedure strflex_pos_dec (            {decrement position to prev char, unless at start}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param; extern;

procedure strflex_pos_end (            {position to after end of string}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param; extern;

function strflex_pos_eos (             {find whether past end of string}
  in      pos: strflex_pos_t)          {string position descriptor}
  :boolean;                            {FALSE within string, TRUE past end of string}
  val_param; extern;

procedure strflex_pos_inc (            {increment position to next char, unless past end}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param; extern;

procedure strflex_pos_init (           {init position state within a flex string}
  in var  str: strflex_t;              {string to position within}
  out     pos: strflex_pos_t);         {initialized, at first char}
  val_param; extern;

procedure strflex_pos_last (           {position to last character of string, if any}
  in out  pos: strflex_pos_t);         {string position to update}
  val_param; extern;

procedure strflex_pos_set (            {set absolute string position}
  in out  pos: strflex_pos_t;          {string position to set}
  in      ind: sys_int_machine_t);     {1-N index to set pos to, clipped at length + 1}
  val_param; extern;

procedure strflex_show_pos (           {show detailed string and position state}
  in      pos: strflex_pos_t);         {position within the string}
  val_param; extern;

procedure strflex_show_str (           {show detailed flex string state}
  in      str: strflex_t);             {string to show internal details of}
  val_param; extern;

procedure strflex_str_create (         {create a new flex string}
  in out  strmem: strflex_mem_t;       {memory state new string will use}
  out     str: strflex_t);             {returned initialized, zero length}
  val_param; extern;

procedure strflex_str_delete (         {delete a flex string}
  in out  str: strflex_t);             {returned invalid, all dynamic memory released}
  val_param; extern;

procedure strflex_strmem_create (      {create memory state for flex strings}
  in out  mem: util_mem_context_t;     {system memory context, will create subordinate}
  out     strmem: strflex_mem_t);      {returned initialized flex string memory state}
  val_param; extern;

procedure strflex_strmem_delete (      {delete flex string mem state and all its strings}
  in out  strmem: strflex_mem_t);      {returned invalid, all str using this block invalid}
  val_param; extern;
