OBJS = main.o
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS = 
endif

%.o:%.s
	as $(DEBUGFLGS) $< -o $@
main: $(OBJS)
	ld -o main $(OBJS)
