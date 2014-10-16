CC = iverilog
src = $(wildcard *.v)
#src = temp.v temp_tb.v

all:
	@echo $(CC) $(src)
	@$(CC) $(src)
	./a.out
	gtkwave test

clean:
	@echo cleaning ...
	rm -f ./a.out
	rm -f test
