bin_PROGRAMS = dydisnix-divide
noinst_HEADERS = divide.h

dydisnix_divide_SOURCES = divide.c main.c
dydisnix_divide_LDADD = ../libservices/libservices.la ../libinfproperties/libinfproperties.la ../libmapping/libmapping.la
dydisnix_divide_CFLAGS = -I../libservices -I../libinfproperties -I../libmapping $(GLIB_CFLAGS) $(DISNIX_CFLAGS) $(LIBXML2_CFLAGS)
