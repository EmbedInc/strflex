{   Private include file for the modules that implement the STRFLEX library.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'strflex.ins.pas';

procedure strflex_block_first (        {add first block to empty string}
  in out  str: strflex_t);             {string to add first block to}
  val_param; extern;

procedure strflex_block_new (          {get a new or free flex string memory block}
  in out  strmem: strflex_mem_t;       {memory state to get the block from}
  out     block_p: strflex_block_p_t); {pointer to new block, block initialized}
  val_param; extern;

procedure strflex_block_remove (       {remove block from string, release block}
  in out  str: strflex_t;              {string the block is in}
  in      block_p: strflex_block_p_t); {pointer to block, copied before use}
  val_param; extern;

procedure strflex_block_unuse (        {indicate a flex string mem block no longer used}
  in out  strmem: strflex_mem_t;       {memory state the block came from}
  in out  block_p: strflex_block_p_t); {pointer to the block, returned NIL}
  val_param; extern;
