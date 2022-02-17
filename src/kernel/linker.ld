ENTRY("kernel_loader")

SECTIONS
{
    .text 0x900 :
    {
		*(.text*)
    }
    .rodata :
    {
        *(.rodata*);
    }
    .bss :
    {
        *(.bss*);
    }
}