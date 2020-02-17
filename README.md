# bmenu

Menu manager for shell, this is a shell script I made in 1992 when Unix(R) systems dominated the world, it is fully compatible with Sculptor® 4gl 1.2 menu system files, but now it is no longer maintained.

By default it opens the menu file "menu.m"

*** Menu files consist of: ***

TITLE HEADER LINE (must be the first line)

any number of line pairs with:

a first line with a option number plus a comma plus the option title a second line with a unix command line or the "menu" word followed with a menu file-name (.m extension not needed)

No white lines are allowed or will fail.

EXAMPLE:

MAIN MENU OPTIONS

1,PROCESS STATUS

ps -ef | more

2,PRINTER STATUS

lpstat ; read x

3,NET OPTIONS

menu submenu1
